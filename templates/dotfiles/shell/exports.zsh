# PATH and environment. Sourced by ~/.zshrc.
export EDITOR="${EDITOR:-nano}"
export PATH="$HOME/.local/bin:$PATH"        # pipx apps and single-binary CLIs
export PATH="$DOTFILES/bin:$PATH"

# Example: a keg-only Homebrew tool that isn't on PATH by default
[ -d /opt/homebrew/opt/rustup/bin ] && export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
