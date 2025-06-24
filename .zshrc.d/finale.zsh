confirm_command() {
  if confirm "Do you want to run '$*'?"; then
    "$@"
    if [[ $? -eq 0 ]]; then
      log_info "Command '$*' executed successfully"
    else
      log_fail "Command '$*' failed"
    fi
  else 
    log_info "Skipped running '$*'"
  fi
}

finale_login() { cd ~/dev/prod; `make login ENVIRONMENT=development MFA=$1`; }
finale_loginprod() { cd ~/dev/prod; `make login ENVIRONMENT=production MFA=$1`; }

finale_whowrote() {
  if [[ -z "$1" ]]; then
    echo "Usage: whowrote <file_name>"
    return 1
  fi

  # Get the GitHub URL from the remote origin
  local remote_url=$(git remote get-url origin)
  local base_url=""
  if [[ "$remote_url" =~ git@github.com:(.*)\.git ]]; then
    base_url="https://github.com/${match[1]}"
  elif [[ "$remote_url" =~ https://github.com/(.*)\.git ]]; then
    base_url="https://github.com/${match[1]}"
  fi

  if [[ -z "$base_url" ]]; then
    log_fail "Unable to parse GitHub repository URL from '${remote_url}'"
    return 1
  fi

  git blame --line-porcelain "$1" | \
    awk '
      /^[0-9a-f]{40} / {commit = $1} 
      /^author / {name = substr($0, 8)} 
      /^author-time / {
          time = $2
          if (!latest_time[name] || time > latest_time[name]) {
              latest_time[name] = time
              latest_commit[name] = commit
          }
          count[name]++
      } 
      END {
          for (name in count) {
              print count[name], latest_commit[name], name
          }
      }' | \
    sort -rn | \
    while read -r count commit author; do
      printf "%d lines by %s\n" "$count" "$author"
      printf "    %s\n" "$(git log -1 --format="(%ar): %s" "$commit")"
      printf "    %s\n" "https://github.com/search?type=pullrequests&q=$commit"
    done | less -FRX
}


finale_autoship() {
  # Use subshell so environment variables are not leaked
  (
    local variables_development
    local variables_production
    local finale_config
    local aws_mfa_name

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
      read_match "Enter Amazon Web Services TOTP (${aws_mfa_name})" "[0-9]{6}" MFA

      # Capture the output of `make login` for development
      if variables_development=$(make login ENVIRONMENT=development MFA="$MFA"); then
        break
      fi
      log_fail "Failed to login to development"

      # Capture the output of `make login` for production
      if variables_production=$(make login ENVIRONMENT=production MFA="$MFA"); then
        break
      fi
      log_fail "Failed to login to production"
      return 1
    done

    # Evaluate the development credentials variables in the current subshell
    eval "${(f)variables_development}"
    confirm_command make ssm-send-make-build
    
    # Evaluate the production credential variables in the current subshell
    eval "${(f)variables_production}"
    confirm_command make ssm-send-deploy-source
    confirm_command make ssm-send-app-pm2-reload-not-account
  )
}

finale_branch() {
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

  # Create and checkout the new branch
  local new_branch="ds-${random_number}"
  git checkout -b "${new_branch}" origin/master || {
    log_fail "Failed to create and checkout branch ${new_branch} from origin/master."
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
