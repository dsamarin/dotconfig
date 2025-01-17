# Source all configuration files from ~/.zshrc.d/
if [ -d "$HOME/.zshrc.d" ]; then
  for file in "$HOME/.zshrc.d/"*; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
  done
fi
