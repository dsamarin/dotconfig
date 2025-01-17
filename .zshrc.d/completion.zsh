# Load the `compinit` function, and initialize completion system
autoload -Uz compinit
compinit

# Enable automatic description of completion items based on their directory name
zstyle ':completion:*' auto-description 'specify: %d'
# Specify the order of completion actions: expand, complete, correct, and approximate
zstyle ':completion:*' completer _expand _complete _correct _approximate
# Format the completion menu header to display "Completing <directory>"
zstyle ':completion:*' format 'Completing %d'
# Set the group name for completion items to an empty string (disable grouping)
zstyle ':completion:*' group-name ''
# Enable a menu selection with a limit of 2 entries before automatically scrolling
zstyle ':completion:*' menu select=2
# Enable the `dircolors` command to set up colorized output for directory listings
eval "$(dircolors -b)"
# Set the completion list colors based on the `LS_COLORS` environment variable
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# Disable the default list colors for completion
zstyle ':completion:*' list-colors ''
# Customize the prompt for more options during completion, showing current selection and offering to press TAB for more
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
# Define custom completion matching rules:
# 1. Match letters case-insensitively (e.g., 'foo' matches 'FOO')
# 2. Treat dots, underscores, and hyphens as interchangeable (e.g., 'file-name' matches 'file_name')
# 3. Fuzzy matching: Allow partial matches from both sides of the string
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
# Set the completion menu style to 'long', which shows more detailed information
zstyle ':completion:*' menu select=long
# Customize the select prompt message while scrolling through completion options
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
# Disable the use of the old `compctl` system for completions
zstyle ':completion:*' use-compctl false
# Enable verbose output for completion, showing more detailed information
zstyle ':completion:*' verbose true
# Customize list colors for completion when in the 'kill' context, applying red color to process IDs
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
# Set a custom command for completing the 'kill' context, listing processes for the current user
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
