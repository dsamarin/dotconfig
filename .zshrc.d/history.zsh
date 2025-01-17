# History settings

# File where the shell history is stored
HISTFILE=~/.zsh_history

# Number of commands to keep in memory for the current session
HISTSIZE=1000

# Maximum number of commands to save to the history file
SAVEHIST=1000

# Save a timestamp with each command in the history file
setopt EXTENDED_HISTORY

# Expire duplicate entries in history, keeping the most recent one
setopt HIST_EXPIRE_DUPS_FIRST

# Do not record consecutive duplicate commands in history
setopt HIST_IGNORE_DUPS

# Remove all previous occurrences of a command in history when it's re-entered
setopt HIST_IGNORE_ALL_DUPS

# Do not save commands that begin with a space
setopt HIST_IGNORE_SPACE

# Prevent duplicates from showing up when searching history with `Ctrl+R`
setopt HIST_FIND_NO_DUPS

# Prevent saving duplicate commands to the history file
setopt HIST_SAVE_NO_DUPS

# Play a beep sound if attempting to access an invalid history entry
setopt HIST_BEEP
