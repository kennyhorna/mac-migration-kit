# Dotfiles starter

Copy this folder to `~/.dotfiles`, make it a git repo, and adapt. It's deliberately small: a few
symlinks, an idempotent install script and a place for secrets that never get committed.

```bash
cp -R templates/dotfiles ~/.dotfiles
cd ~/.dotfiles && git init && git add -A && git commit -m "Initial dotfiles"
bin/link            # dry run: shows what would be linked
bin/link --apply    # link, backing up whatever it replaces
```

## Layout

| Path | Purpose |
|---|---|
| `bin/install` | Bootstrap a machine. Named steps, safe to re-run: `bin/install brew link macos` |
| `bin/link` | Symlink `home/` and `config/` into place, backing up what it replaces |
| `Brewfile` | Packages, casks and App Store apps |
| `home/` | Files symlinked into `~` |
| `shell/` | Modules sourced by `.zshrc`: aliases, functions, exports |
| `config/` | App configs symlinked into `~/.config` or app folders |
| `macos/defaults.sh` | Dock, Finder, keyboard, trackpad, shortcuts |
| `ai/` | Shared agent instructions, MCP definitions, your own skills |
| `secrets.env.tpl` | Template of secret **references**, rendered at setup time |

## Rules that keep it working

- **Secrets never get committed.** Machine-local values live in `~/.dotfiles-custom/*.zsh`, which
  `home/.zshrc` sources if present, or come from a password manager CLI.
- **Let installers keep their own lines.** Tools that append to `~/.zshrc` look for their own markers;
  keep theirs and delete your duplicate, or they'll re-add it forever.
- **Everything is idempotent.** You will run `bin/install` on a half-set-up machine.
- **Capture changes back.** When you change a setting you care about, put it in here and push.
