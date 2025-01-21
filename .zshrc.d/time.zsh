# Save the start time at the beginning of each prompt
time_preexec() {
  export time_start=$SECONDS
}

# Use precmd to display the running time of the last command
time_precmd() {
  if [[ -n $time_start ]]; then
    # Calculate the elapsed time in seconds
    local elapsed_time=$((SECONDS - time_start))

    # Only proceed if the elapsed time is greater than 0
    if (( elapsed_time > 0 )); then
      # Calculate days, hours, minutes, and seconds
      local days=$((elapsed_time / 86400))  # 86400 seconds in a day
      local hours=$(((elapsed_time % 86400) / 3600))  # 3600 seconds in an hour
      local minutes=$(((elapsed_time % 3600) / 60))  # 60 seconds in a minute
      local seconds=$((elapsed_time % 60))

      # Build the time string using an array
      local time_parts=()
      [[ $days -gt 0 ]] && time_parts+="$days"d
      [[ $days -gt 0 || $hours -gt 0 ]] && time_parts+="$hours"h
      [[ $days -gt 0 || $hours -gt 0 || $minutes -gt 0 ]] && time_parts+="$minutes"m
      time_parts+="$seconds"s  # Always include seconds

      # Print the formatted elapsed time
      log_info "Last command took ${(j: :)time_parts}, completed $(date +"%I:%M:%S %p")"
    fi

    unset time_start
  fi
}

preexec_functions+=(time_preexec)
precmd_functions+=(time_precmd)
