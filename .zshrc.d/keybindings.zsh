# Key bindings for terminal keys using terminfo database entries

# Bind 'home' key to move to the beginning of the line
[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line

# Bind 'end' key to move to the end of the line
[[ -n "${terminfo[kend]}"  ]] && bindkey "${terminfo[kend]}"  end-of-line

# Bind 'insert' key to toggle overwrite mode
[[ -n "${terminfo[kich1]}" ]] && bindkey "${terminfo[kich1]}" overwrite-mode

# Bind 'delete' key to delete the character under the cursor
[[ -n "${terminfo[kdch1]}" ]] && bindkey "${terminfo[kdch1]}" delete-char

# Bind 'up arrow' key to move up one line or through history
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-history

# Bind 'down arrow' key to move down one line or through history
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-history

# Bind 'left arrow' key to move backward one character
[[ -n "${terminfo[kcub1]}" ]] && bindkey "${terminfo[kcub1]}" backward-char

# Bind 'right arrow' key to move forward one character
[[ -n "${terminfo[kcuf1]}" ]] && bindkey "${terminfo[kcuf1]}" forward-char

# Bind 'shift+left arrow' to move backward one word
[[ -n "${terminfo[kLFT5]}" ]] && bindkey "${terminfo[kLFT5]}" backward-word

# Bind 'shift+right arrow' to move forward one word
[[ -n "${terminfo[kRIT5]}" ]] && bindkey "${terminfo[kRIT5]}" forward-word

# Function to enable application keypad mode when starting a line
function zle-line-init { 
  # Check if the terminal supports the 'smkx' (enter keypad mode) capability and enable it
  if (( ${+terminfo[smkx]} )); then 
    echoti smkx; 
  fi; 
}

# Function to disable application keypad mode when finishing a line
function zle-line-finish { 
  # Check if the terminal supports the 'rmkx' (exit keypad mode) capability and disable it
  if (( ${+terminfo[rmkx]} )); then 
    echoti rmkx; 
  fi; 
}

# Initialize the 'zle-line-init' function to be called on line initialization
zle -N zle-line-init

# Initialize the 'zle-line-finish' function to be called on line finish
zle -N zle-line-finish

# Disable the bell sound in the terminal
setopt no_beep
