# Set the terminal title dynamically
function title {
  # If the terminal is a `screen` session
  if [[ $TERM == "screen" ]]; then
    # Set the window title (for GNU Screen) using escape sequences
    print -nR $'\033k'$1$'\033'\\
    # Set the screen title with an additional escape sequence
    print -nR $'\033]0;'$2$'\a'
  # If the terminal is `xterm` or `rxvt`
  elif [[ $TERM == "xterm" || $TERM == "rxvt" ]]; then
    # Set the terminal title using escape sequences
    print -nR $'\033]0;'$*$'\a'
  fi
}

# Hook that runs before each prompt is displayed
title_precmd() {
  # Update the terminal title to the hostname before showing the prompt
  title "$(hostname)"
}

# Hook that runs before each command is executed
title_preexec() {
  # Ensure the function executes in a clean, Zsh-compatible environment
  emulate -L zsh

  # Split the full command into an array of words
  local -a cmd
  cmd=(${(z)1})

  # Update the terminal title to show the hostname and the command being run
  title "$(hostname): $cmd[1]:t $cmd[2,-1]"
}

preexec_functions+=(title_preexec)
precmd_functions+=(title_precmd)
