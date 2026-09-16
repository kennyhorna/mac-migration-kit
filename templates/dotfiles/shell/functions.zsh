# Functions. Sourced by ~/.zshrc.

# mkcd <dir> — create a directory and enter it
mkcd() { mkdir -p "$1" && cd "$1"; }
