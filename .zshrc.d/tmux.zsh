# Define a function called "@" for managing tmux sessions
function @ {
  # Check if any arguments are passed to the function
  if (( $# )); then
    # Check if a tmux session with the name provided as the first argument exists
    tmux has-session -t "$1" 2>/dev/null

    # If the session does not exist (tmux returns a non-zero status)
    if (( $? )); then
      # Create a new tmux session with the name provided as the first argument
      # and optionally execute any additional commands passed as arguments
      tmux new-session -d -s "$1" "${@:2}"
    fi

    # If inside an active tmux session
    if [[ ! -z $TMUX ]]; then
      # Switch to the target tmux session specified by the first argument
      tmux switch -t "$1" "${@:2}"
    else
      # If not inside tmux, attach to the specified session
      tmux attach -t "$1" "${@:2}"
    fi
  else
    # If no arguments are passed, list all tmux sessions
    tmux list-sessions 2> /dev/null
  fi
}

# Define a completion function for the "@" command
_@() {
  # Use compadd to add the names of existing tmux sessions to the completion options
  local sessions
  sessions=( $(tmux list-sessions -F '#S' 2> /dev/null) )  # Use -F '#S' to directly list session names
  compadd -- "${sessions[@]}"
}

# Register the completion function for the "@" command
compdef _@ @
