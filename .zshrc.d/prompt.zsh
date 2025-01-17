# Prompt
if [[ ! -z $TMUX ]]; then printf '\n'; fi
function prompt_left() {
	echo '%(?::(exit %F{red}%?%f%)
)%F{cyan}%n%f@%B%M%b:%~%(!/#/:) '
}
function prompt_right() {
	#git branch --no-color 2> /dev/null | \
	#	sed -e '/^[^*]/d' -e 's/* \(.*\)/%F{yellow}(\1)%f/'
	#echo ' %D{%l:%M:%S%P}'
}

# Enables prompt substitution, allowing the shell to evaluation commands and variable expansions inside PROMPT
setopt prompt_subst

# Enable the automatic redrawing of the prompt when a command is entered
setopt prompt_sp

# Enable extended globbing for pattern matching more powerful than the standard globbing syntax (e.g., *, ?, and []).
setopt extendedglob

PROMPT='$(prompt_left)'
RPROMPT='$(prompt_right)'
