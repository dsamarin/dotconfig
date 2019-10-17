# History
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP
unsetopt PROMPT_SP

# Completion
zstyle :compinstall filename '/home/eboyjr/.zshrc'
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Key bindings
[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}"  ]] && bindkey "${terminfo[kend]}"  end-of-line
[[ -n "${terminfo[kich1]}" ]] && bindkey "${terminfo[kich1]}" overwrite-mode
[[ -n "${terminfo[kdch1]}" ]] && bindkey "${terminfo[kdch1]}" delete-char
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-history
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-history
[[ -n "${terminfo[kcub1]}" ]] && bindkey "${terminfo[kcub1]}" backward-char
[[ -n "${terminfo[kcuf1]}" ]] && bindkey "${terminfo[kcuf1]}" forward-char
[[ -n "${terminfo[kLFT5]}" ]] && bindkey "${terminfo[kLFT5]}" backward-word
[[ -n "${terminfo[kRIT5]}" ]] && bindkey "${terminfo[kRIT5]}" forward-word

function zle-line-init { if (( ${+terminfo[smkx]} )); then echoti smkx; fi; }
function zle-line-finish { if (( ${+terminfo[rmkx]} )); then echoti rmkx; fi; }

zle -N zle-line-init
zle -N zle-line-finish

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

setopt prompt_subst
PROMPT='$(prompt_left)'
RPROMPT='$(prompt_right)'

# Terminal title
function title {
	if [[ $TERM == "screen" ]]; then
		print -nR $'\033k'$1$'\033'\\
		print -nR $'\033]0;'$2$'\a'
	elif [[ $TERM == "xterm" || $TERM == "rxvt" ]]; then
		print -nR $'\033]0;'$*$'\a'
	fi
}
function precmd { title "$(hostname)"; }
function preexec { emulate -L zsh; local -a cmd; cmd=(${(z)1}); title "$(hostname): $cmd[1]:t $cmd[2,-1]" }

# Tmux Command
function @ {
	if (( $# )); then
		tmux has-session -t "$1" 2>/dev/null
		if (( $? )); then
			tmux new-session -d -s "$1" "${@:2}"
		fi
		if [[ ! -z $TMUX ]]; then
			tmux switch -t "$1" "${@:2}"
		else
			tmux attach -t "$1" "${@:2}"
		fi
	else
		tmux list-sessions 2> /dev/null
	fi
}

_@() {
	reply=( $(tmux list-sessions | cut -d: -f1) )
}
compctl -K _@ @

# -- Functions -- #

# search scans the current directory recursively for files containing matching regex
function search { grep -niI -C 1 --color=auto -R "$@" .; }

# -- Aliases -- #
alias ls='ls --format=vertical --almost-all --group-directories-first --color=auto'
alias grep='grep --color=auto'
alias tmux='tmux -2'

alias /='cd /'
alias ~='cd ~'

# Private binaries
export PATH=$HOME/bin:$HOME/.yarn/bin:$PATH

# Golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME

setopt extendedglob
alias apt-cyg='/cygdrive/c/Users/Devin/Downloads/Software/cygwinsetup-x86_64.exe -q -P'
