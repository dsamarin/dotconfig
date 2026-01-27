if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -A -G'
else
    alias ls='ls --format=vertical --almost-all --group-directories-first --color=auto'
fi
alias grep='grep --color=auto'
alias tmux='tmux -2'
