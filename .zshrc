# History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

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

# Workstation
unset work_me
if [[ "$(hostname)" == "workstation" ]]; then; work_me= ; fi
work_host='dsamar.in'
work_user='dsamarin'
work_root='/srv/dsamar.in'

######################
# Workstation access #
######################

export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=screen-256color

if (( ${+work_me} )); then
	function irc {
		tmux attach-session -t irc
		if (( $? )); then
			tmux new-session -s irc irssi
		fi
	}
else
	alias work="ssh -C -X $work_user@$work_host"

	function tunnel {
		local host port
		host="$work_user@$work_host"
		port='6666'
		# If we have an argument, we are changing our host
		if [[ $# -ge 1 ]]; then host=$1 fi

		# Set proxy configuration
		if (( ${+commands[gsettings]} )); then
			print -P "Setting proxy configuration to %Bmanual%b (localhost:%B$port%b)."
			gsettings set org.gnome.system.proxy.socks host localhost
			gsettings set org.gnome.system.proxy.socks port $port
			gsettings set org.gnome.system.proxy mode 'manual'
		else
			print "GNOME environment not available, skipping proxy configuration."
		fi

		# Start tunnel
		print -P "Connecting to %B$host%b..."

		ssh -C2TNv -D $port $host 2>&1 \
			| sed -n "s/.*direct-tcpip: listening port [0-9]* for \\([-0-9a-zA-Z.]*\\) port \\([0-9]*\\).*/Serving $(tput smul)\1$(tput sgr0) \2/p" \
			| while read data; do print -P "%D{%l:%M:%S%P} -- $data"; done

		print "Shutting down..."

		# Reset proxy configuration
		if (( ${+commands[gsettings]} )); then
			print -P "Setting proxy configuration to %Bnone%b."
			gsettings set org.gnome.system.proxy mode 'none'
		fi
	}
fi

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
		tmux list-sessions
	fi
}

_@() {
	reply=( $(tmux list-sessions | cut -d: -f1) )
}
compctl -K _@ @

if (( ${+commands[xclip]} )); then
	alias pbcopy='xclip -selection clipboard'
	alias pbpaste='xclip -selection clipboard -o'
else
	alias pbcopy='echo "sudo apt-get install xclip"'
	alias pbpaste='pbcopy'
fi

function search { grep -niI -C 1 --color=auto -R "$@" .; }

function sloc {
	find . -name '*.[hc]' -print0 | xargs -0 wc -l | sort -n
}

function fileup {
	local name url path

	name="${@:t}"
	path="uploads"

	url="https://$work_host/$path/$name"

	if (( ${+work_me} )); then
		cp "$@" "$work_root/$path/$name"
		chmod 0777 "$work_root/$path/$name"
	else
		scp "$@" "$work_user@$work_host:$work_root/$path"
	fi

	echo "$url"
	echo -n "$url" | pbcopy && echo "Copied to clipboard."
}

function shotup {
	local name="$(date +shot-%F-t%H%M.png)"

	if (( !${+commands[scrot]} )); then
		echo 'sudo apt-get install scrot'
		return
	fi

	touch "/tmp/$name"
	chmod 0777 "/tmp/$name"

	echo '!countdown'; sleep 1
	echo -e '3...\a'; sleep 1
	echo -e '2...\a'; sleep 1
	echo -e '1...\a'; sleep 1

	echo -e 'Go!\a'
	scrot "$@" "/tmp/$name"
	echo -e 'Uploading...\a'

	fileup "/tmp/$name"
	rm -f "/tmp/$name"

	echo -en '\a'
}

function shorten {
	node -e 'process.stdout.write(JSON.stringify({longUrl:process.argv[1]}))' "$@" | curl --silent 'https://www.googleapis.com/urlshortener/v1/url' -H 'Content-Type: application/json' -d @- | node -e 'var j="",i=process.stdin;i.setEncoding("utf8");i.resume();i.on("data",function(b){j+=b});i.on("end",function(){process.stdout.write(JSON.parse(j).id)})'
}

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

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias tmux='tmux -2'
alias vim='vim -p'

alias /='cd /'
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/gowork
