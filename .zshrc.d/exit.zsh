# Define a mapping of exit codes to reasons
typeset -A exit_reasons
exit_reasons=(
  [0]="Success"
  [1]="General error"
  [2]="Misuse of shell built-ins"
  [126]="Permission denied"
  [127]="Command not found"
  [128]="Invalid exit argument"
  [129]="SIGHUP"
  [130]="SIGINT"
  [131]="SIGQUIT"
  [137]="SIGKILL"
  [139]="SIGSEGV"
  [141]="SIGPIPE"
  [143]="SIGTERM"
)

# Use precmd to display the exit code of the last command
exit_precmd() {
  # Save the exit code of the last executed command
  local last_exit_code=$?

  # Check if the last command exited with a non-zero status
  if [[ $last_exit_code -ne 0 ]]; then
    # Look up the reason for the exit code
    local reason="${exit_reasons[$last_exit_code]:-Unknown reason}"

    # Log the failure with the exit code and reason
    log_fail "Last command exited with code $last_exit_code ($reason)"
  fi
}

precmd_functions+=(exit_precmd)
