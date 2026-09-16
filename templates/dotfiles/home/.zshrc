# ~/.zshrc → ~/.dotfiles/home/.zshrc
export DOTFILES="$HOME/.dotfiles"

# Framework (optional): Oh My Zsh, starship, pure zsh — your call
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  plugins=(git)
  source "$ZSH/oh-my-zsh.sh"
fi

# Modules from the repo
for file in exports aliases functions; do
  [ -f "$DOTFILES/shell/$file.zsh" ] && source "$DOTFILES/shell/$file.zsh"
done

# Machine-local config and secrets — never committed
for file in "$HOME"/.dotfiles-custom/*.zsh(N); do source "$file"; done

# Tool installers append their own blocks BELOW this line.
# Keep their markers and their exact lines: they re-add them otherwise. Delete your duplicates instead.
