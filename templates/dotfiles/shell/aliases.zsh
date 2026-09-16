# Aliases. Sourced by ~/.zshrc.
alias gs='git status'
alias gp='git pull'
alias dotfiles='cd "$DOTFILES"'
command -v eza >/dev/null && alias ls='eza --group-directories-first'
command -v bat >/dev/null && alias cat='bat --style=plain'
