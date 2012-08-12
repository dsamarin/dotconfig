# History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Completion
zstyle :compinstall filename '/home/eboyjr/.zshrc'
autoload -Uz compinit
compinit

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

function zle-line-init () { echoti smkx; }
function zle-line-finish () { echoti rmkx; }
zle -N zle-line-init
zle -N zle-line-finish

# Prompts
setopt prompt_subst

PROMPT='%(?::(exit %F{red}%?%f%)
)%F{cyan}%n%f@%B%M%b:%~%(!/#/:) '

RPROMPT='$(zsh_prompt_git_branch)'

zsh_prompt_git_branch() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/%F{yellow}(\1)%f/'
}

# Color commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Editing
alias vim='vim -p'

# Directory traversal
alias /='cd /'
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
