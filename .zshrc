
###########
# History #
###########

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000


##############
# Completion #
##############

zstyle :compinstall filename '/home/eboyjr/.zshrc'
autoload -Uz compinit
compinit


################
# Key bindings #
################

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

function zle-line-init {
	if (( ${+terminfo[smkx]} ))
	then
		echoti smkx
	fi
}

function zle-line-finish {
	if (( ${+terminfo[rmkx]} ))
	then
		echoti rmkx
	fi
}

zle -N zle-line-init
zle -N zle-line-finish


###########
# Prompts #
###########

setopt prompt_subst

PROMPT='%(?::(exit %F{red}%?%f%)
)%F{cyan}%n%f@%B%M%b:%~%(!/#/:) '

RPROMPT='$(zsh_prompt_git_branch)'

function zsh_prompt_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/%F{yellow}(\1)%f/'
}


#########
# Title #
#########

function title {
	if [[ $TERM == "screen" ]]; then
		print -nR $'\033k'$1$'\033'\\
		print -nR $'\033]0;'$2$'\a'
	elif [[ $TERM == "xterm" || $TERM == "rxvt" ]]; then
		print -nR $'\033]0;'$*$'\a'
	fi
}

function precmd {
	title "$(hostname)"
}

function preexec {
	emulate -L zsh
	local -a cmd; cmd=(${(z)1})
	title "$(hostname): $cmd[1]:t $cmd[2,-1]"
}


########################
# Identify Dell server #
########################

unset DELL
if [[ "$(hostname)" == "server" ]]; then
	DELL=
fi


#######################
# Dell access and IRC #
#######################

if (( ${+DELL} )); then
	function irc {
		screen -qr irssi
		if (( $? ))
		then
			screen -qx irssi
			if (( $? ))
			then
				screen -qS irssi irssi
				if (( $? ))
				then
					echo 'Could not create irssi session.'
				fi
			fi
		fi
	}
else
	alias dell='ssh -X eboyjr@192.168.2.8'
	alias dellr='ssh -C -X eboyjr@eboyjr.oftn.org'
fi


##################
# Clipboard shit #
##################

if (( ${+commands[xclip]} )); then
	alias pbcopy='xclip -selection clipboard'
	alias pbpaste='xclip -selection clipboard -o'
else
	alias pbcopy='echo "xlip is not available on this system"'
	alias pbpaste='pbcopy'
fi


##################
# Volume control #
##################

function volume {
	local argument="$1"
	if [[ -z "$argument" ]]; then
		argument="100%"
	else
		argument="$argument%"
	fi
	if (( ${+commands[pactl]} )); then
		print "pactl set-sink-volume 0 \"$argument\""
		pactl set-sink-volume 0 -- "$argument"
	else
		print "volume: pactl command not available" 1>&2
	fi
}


##################
# Color commands #
##################

alias ls='ls --color=auto'
alias grep='grep --color=auto'

function colors {
	local -a colors
	colors=(default black red green yellow blue magenta cyan white)

	print -n -- "\n           "
	for color in $colors; do
		print -n " ${(r:7:: :)color}  "
	done

	# Print each row
	for fg in $colors; do
		print -n -- "\n\n  ${(l:7:: :)fg}  "
		for bg in $colors; do
			print -nP -- " %K{$bg}%F{$fg}abc %Babc%b%f%k  "
		done
	done

	print -n -- "\n\n"
}


###########
# Editing #
###########

alias vim='vim -p'


#######################
# Directory traversal #
#######################

alias /='cd /'
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
