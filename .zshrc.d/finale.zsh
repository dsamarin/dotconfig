export PATH="/var/fwcs/bin/node/bin:$HOME/.tfenv/bin:$PATH"
local finale_developer="dsamarin"

retry_command() {
  while true; do
    time_preexec
    "$@"
    if [[ $? -eq 0 ]]; then
      log_info "Command '$*' executed successfully"
      time_precmd
      break
    else
      log_fail "Command '$*' failed"
      time_precmd
      if ! confirm "Do you want to retry '$*'?"; then
        log_fail "Aborting"
        exit 1
      fi
    fi
  done
}

finale_login() { eval "$(cd ~/dev/prod && make login ENVIRONMENT=development MFA=$1)"; }
finale_loginprod() { eval "$(cd ~/dev/prod && make login ENVIRONMENT=production MFA=$1)"; }
finale_logout() { eval "$(cd ~/dev/prod && make logout)"; }

finale_autoship() {
  # Use subshell so environment variables are not leaked
  (
    local variables_development
    local variables_production
    local finale_config
    local aws_mfa_name
    local run_reload_command="no"

    cd ~/dev/prod || { log_fail "Failed to change directory to ~/dev/prod"; return 1; }

    log_info "Updating production repository"
    git pull || { log_fail "Failed to update production repository"; return 1; }
    
    if ! finale_config=$(<~/.aws/finale_config); then
      log_fail "Error: Failed to read the file ~/.aws/finale_config" >&2
      return 1  # Exit with an error status (or use `exit 1` if outside a function)
    fi

    # Extract MFA device name from config from the last forward slash (/) to the last quotation (")
    aws_mfa_name=${${finale_config##*/}%\"*}

    while true; do
      # Prompt for the MFA code
      local MFA
      read_match "Enter AWS TOTP for development (${aws_mfa_name})" "[0-9]{6}" MFA

      # Capture the output of `make login` for development
      if variables_development=$(make login ENVIRONMENT=development MFA="$MFA"); then
        break
      fi
      log_fail "Failed to login to development"
    done

    while true; do
      # Prompt for the MFA code
      local MFA
      read_match "Enter AWS TOTP for production (${aws_mfa_name})" "[0-9]{6}" MFA

      # Capture the output of `make login` for production
      log_info "Logging into production"
      if variables_production=$(make login ENVIRONMENT=production MFA="$MFA"); then
        break
      fi
      log_fail "Failed to login to production"
    done

    if confirm "Do you want to run 'make ssm-send-app-pm2-reload-not-account' at the end?"; then
      run_reload_command="yes"
    fi

    # Evaluate the development credentials variables in the current subshell
    eval "${(f)variables_development}"
    retry_command make ssm-send-make-build
    
    # Evaluate the production credential variables in the current subshell
    eval "${(f)variables_production}"
    retry_command make ssm-send-deploy-source

    if [[ $run_reload_command == "yes" ]]; then
      retry_command make ssm-send-app-pm2-reload-iterator
      retry_command make ssm-send-app-pm2-reload-graphql
      retry_command make ssm-send-app-pm2-reload-stock-calc
      retry_command make ssm-send-app-pm2-reload-api-rest
      retry_command make ssm-send-app-pm2-reload-doc
      retry_command make ssm-send-wfe-restart
    fi
  )
}

finale_branch() {
  # Check for required argument
  if [[ "$1" != "master" && "$1" != "current" ]]; then
    log_fail "Usage: $0 [master|current]"
    return 1
  fi

  # Ensure we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    log_fail "Not a git repository."
    return 1
  fi

  # Fetch and update from the origin
  log_info "Updating from origin..."
  git fetch origin || { log_fail "Failed to fetch from origin."; return 1; }

  # Generate a random 16-digit number
  local random_number=$(LC_ALL=C tr -dc '0-9' < /dev/urandom | head -c 16)

  # Determine base branch
  local base_branch=""
  if [[ "$1" == "master" ]]; then
    base_branch="origin/master"
  else
    local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -z "$current_branch" ]]; then
      log_fail "Failed to determine current branch."
      return 1
    fi
    base_branch="${current_branch}"
  fi

  # Create and checkout the new branch
  local new_branch="ds-${random_number}"
  git checkout -b "${new_branch}" "${base_branch}" || {
    log_fail "Failed to create and checkout branch ${new_branch} from ${base_branch}."
    return 1
  }

  log_info "New branch '${new_branch}' created and checked out."
}

finale_push() {
  # Ensure we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    log_fail "Not a git repository."
    return 1
  fi

  # Check if the branch name starts with "ds-"
  if [[ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" != ds-* ]]; then
    log_fail "The current branch does not have the prefix 'ds-'."
    return 1
  fi

  git push -u origin HEAD || { log_fail "Failed to push current branch to origin"; return 1; }
}

finale_branches() {
      git branch --format='%(refname:short)' | while read -r branch; do
        # Declare local variables
        local branch_name="$branch"
        local branch_status=""
        local commit_msg=""

        # Get the latest commit of the branch
        local latest_commit=$(git rev-parse "$branch_name" 2>/dev/null)
        local parent_count=$(git rev-list --parents -n 1 "$latest_commit" 2>/dev/null | awk '{print NF-1}')

        # Determine branch status based on parent count
        if [[ "$parent_count" -eq 1 ]]; then
            if git rev-list --count origin/master.."$branch_name" 2>/dev/null | grep -q '^0$'; then
                branch_status="merged"
            else
                branch_status="open"
            fi
            commit_msg=$(git log -1 --format='%s' "$branch_name" 2>/dev/null)
            if [[ -z "$commit_msg" ]]; then
                commit_msg="(No commits)"
            fi
        else
            branch_status="empty"
        fi
        
        printf "%-30s %-10s %s\n" "$branch_name" "[$branch_status]" "$commit_msg"
    done
}


finale_start() { eval "$(cd ~/dev/prod && make start-dev-session DEVELOPER=$finale_developer)"; }
finale_stop() { ( cd ~/dev/prod && make stop-dev-instance DEVELOPER=$finale_developer; ); }

finale_forward() { sudo iptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 8080; }

# The finale function
f() {
  if [[ -n $1 ]]; then
    local func_name="finale_$1"
    shift  # Remove the first argument ($1) so remaining arguments can be passed

    # Check if the function exists
    if typeset -f "$func_name" >/dev/null; then
      # Call the custom function with the remaining arguments
      "$func_name" "$@"
      return $?
    fi

    log_fail "Subcommand '${func_name#finale_}' does not exist."
  fi

  log_info "Available subcommands:"
  for func in ${(ko)functions}; do
    [[ $func == finale_* ]] && log_info "  ${func#finale_}"
  done

  return 1
}
