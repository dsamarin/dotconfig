finale_login() { cd ~/dev/prod; `make login ENVIRONMENT=development MFA=$1`; }
finale_loginprod() { cd ~/dev/prod; `make login ENVIRONMENT=production MFA=$1`; }

finale_branch() {
  # Ensure we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    log_fail "Not a git repository."
    return 1
  fi

  # Fetch and update the master branch
  log_info "Updating master branch..."
  git fetch origin || { log_fail "Failed to fetch from origin."; return 1; }

  # Check if 'master' is already set up as 'origin/master'
  if [ "$(git rev-parse master)" = "$(git rev-parse origin/master)" ]; then
    log_info "Branch 'master' is already up to date with 'origin/master'."
  else
    # Force update the branch if it's not up to date
    git branch --force master origin/master || {
      log_fail "Failed to fast-forward updates to master branch."
      return 1
    }
  fi

  # Generate a random 16-digit number
  local random_number=$(LC_ALL=C tr -dc '0-9' < /dev/urandom | head -c 16)

  # Create and checkout the new branch
  local new_branch="ds-${random_number}"
  git checkout -b "${new_branch}" master || { log_fail "Failed to create and checkout branch ${new_branch}."; return 1; }

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
