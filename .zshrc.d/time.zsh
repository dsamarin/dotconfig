# Save the start time at the beginning of each prompt
time_preexec() {
  export time_start=$SECONDS
}

# Use precmd to display the running time of the last command
time_precmd() {
  if [[ -n $time_start ]]; then
    # Calculate the elapsed time in seconds
    elapsed_time=$((SECONDS - time_start))

    # Only proceed if the elapsed time is greater than 0
    if (( elapsed_time > 0 )); then
      # Calculate days, hours, minutes, and seconds
      days=$((elapsed_time / 86400))  # 86400 seconds in a day
      hours=$(((elapsed_time % 86400) / 3600))  # 3600 seconds in an hour
      minutes=$(((elapsed_time % 3600) / 60))  # 60 seconds in a minute
      seconds=$((elapsed_time % 60))

      # Build the time string
      time_string=""
      [[ $days -gt 0 ]] && time_string+="$days"d" "
      [[ $hours -gt 0 ]] && time_string+="$hours"h" "
      [[ $minutes -gt 0 ]] && time_string+="$minutes"m" "
      [[ $seconds -gt 0 ]] && time_string+="$seconds"s

      # Print the formatted elapsed time
      log_info "Last command took $time_string, completed $(date +"%I:%M:%S %p")"
    fi
  fi
}

preexec_functions+=(time_preexec)
precmd_functions+=(time_precmd)
