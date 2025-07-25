# Prompt

function prompt_left() {
	echo '%F{cyan}%n%f@%B%M%b %~%(!/#/:) '
}
function prompt_right() {
	git branch --no-color 2> /dev/null | \
		sed -e '/^[^*]/d' -e 's/* \(.*\)/%F{yellow}(\1)%f/'
}

# Reset common terminal settings without clearing the scrollback
function prompt_precmd() {
  # Disable all common Xterm mouse tracking modes:
  # \e[?1000l - Disable basic mouse click tracking
  # \e[?1002l - Disable mouse drag tracking (button press + movement)
  # \e[?1003l - Disable all motion tracking (even without button press)
  # \e[?1006l - Disable SGR (extended coordinate mode) mouse reporting
  echo -ne '\e[?1000l\e[?1002l\e[?1003l\e[?1006l'

  # Clear to end of line to remove prompt artifacts, if any
  echo -ne "\033[0K"

  # Restore normal cursor visibility
  tput cnorm

  # Restore sane terminal input settings (canonical mode, echo, etc.)
  stty sane
}

# Enables prompt substitution, allowing the shell to evaluation commands and variable expansions inside PROMPT
setopt prompt_subst

# Enable the automatic redrawing of the prompt when a command is entered
setopt prompt_sp

# Enable extended globbing for pattern matching more powerful than the standard globbing syntax (e.g., *, ?, and []).
setopt extendedglob

PROMPT='$(prompt_left)'
RPROMPT='$(prompt_right)'

precmd_functions+=(prompt_precmd)
