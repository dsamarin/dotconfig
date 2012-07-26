#!/bin/bash

# Identify Dell computer
DELL=false
if [[ "$(hostname)" == "server" ]]; then
	DELL=true
fi

# Dell access
if ! $DELL; then
	alias dell='ssh -X 192.168.2.8'
	alias dellr='ssh -C -X eboyjr.oftn.org'
	alias irc='dell -t irc'
	alias ircr='dellr -t irc'
fi

# Alert alias
alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
alias alert='notify-send -i /usr/share/icons/gnome/32×32/apps/gnome-terminal.png "[$?] $(alert_helper)"'

# Clipboard shit
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# Cool cwd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Searching
search() {
	grep -niI -C 1 --color=auto -R "$@" .
}

# Uploading temporary files
fileup() {
	local basename="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$(basename "$@")")"
	local url="http://eboyjr.oftn.org:8080/tmp/$basename"
	if $DELL; then
		cp "$@" "/var/www/main/tmp/$@"
		chmod 0777 "/var/www/main/tmp/$@"
	else
		scp "$@" eboyjr@eboyjr.oftn.org:/var/www/main/tmp/
	fi
	local url=$(shorten "$url")
	echo -n "$url" | pbcopy
	echo "Copied $url to clipboard."
}

shotup() {
	local tmp="$(mktemp screenshot-XXXX.png)"
	local url="http://eboyjr.oftn.org:8080/tmp/$tmp"

	chmod 0777 "$tmp"

	echo '!countdown'; sleep 1
	echo -e '3...\a'; sleep 1
	echo -e '2...\a'; sleep 1
	echo -e '1...\a'; sleep 1
	echo -e 'Go!\a'

	scrot "$@" "$tmp"
	fileup "$tmp"
	rm -f "$tmp"
}

# URL shortening
shorten() {
	node -e 'process.stdout.write(JSON.stringify({longUrl:process.argv[1]}))' "$@" | curl --silent 'https://www.googleapis.com/urlshortener/v1/url' -H 'Content-Type: application/json' -d @- | node -e 'var j="",i=process.stdin;i.setEncoding("utf8");i.resume();i.on("data",function(b){j+=b});i.on("end",function(){process.stdout.write(JSON.parse(j).id)})'
}

# Editing
alias vim='vim -p'
