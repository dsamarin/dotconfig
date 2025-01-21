# Use precmd to display the exit code of the last command
exec_precmd() {
  # Save the exit code of the last executed command
  local last_exit_code=$?

  # Check if the last command exited with a non-zero status
  if [[ $last_exit_code -ne 0 ]]; then
    log_fail "Last command exited with code $last_exit_code"
  fi
}

precmd_functions+=(exec_precmd)
