login() { cd ~/dev/prod; `make login ENVIRONMENT=development MFA=$1`; }
loginprod() { cd ~/dev/prod; `make login ENVIRONMENT=production MFA=$1`; }

work() {
  # Ensure we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not a git repository."
    return 1
  fi

  # Fetch and update the master branch
  echo "Updating master branch..."
  git fetch origin  || { echo "Error: Failed to fetch from origin."; return 1; }
  git branch --force master origin/master || { echo "Error: Failed to pull updates for master branch."; return 1; }

  # Generate a random 16-digit number
  local random_number=$(LC_ALL=C tr -dc '0-9' < /dev/urandom | head -c 16)

  # Create and checkout the new branch
  local new_branch="ds-${random_number}"
  git checkout -b "${new_branch}" master || { echo "Error: Failed to create and checkout branch ${new_branch}."; return 1; }

  echo "New branch '${new_branch}' created and checked out."
}
