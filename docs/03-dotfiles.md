# Dotfiles: the part you keep forever

A dotfiles repo turns "set up my Mac" into a command. You don't need a fancy one — a folder, some symlinks and an install script beat any framework.

For a well-explained example of the whole idea, see [A tour of my dotfiles](https://freek.dev/3054-a-tour-of-my-dotfiles)
by Freek Van der Herten, which inspired the layout below.

If you already have one, skip to [installers fight your dotfiles](#installers-fight-your-dotfiles); it's the failure mode people hit during a migration.

## A layout that scales

```
~/.dotfiles/
├── bin/install           # bootstrap a new Mac, idempotent, re-runnable
├── bin/link              # symlink files into place, dry-run by default
├── Brewfile              # packages, casks, App Store apps
├── home/                 # files that get symlinked into ~
│   ├── .zshrc
│   ├── .gitconfig
│   └── .ssh/config
├── shell/                # sourced modules: aliases, functions, exports
├── config/               # app configs symlinked into ~/.config or app folders
├── macos/defaults.sh     # Dock, Finder, keyboard, shortcuts
└── PLAN.md               # your migration checklist (from this kit)
```

`templates/dotfiles/` in this repo has a working starting point.

## Symlinks, not copies

```bash
ln -sfn ~/.dotfiles/home/.zshrc ~/.zshrc
```

Editing `~/.zshrc` then edits the file in the repo, so every change is version-controlled without you thinking about it. Always back up what you replace:

```bash
[ -e "$target" ] && mv "$target" ~/.dotfiles-backups/$(date +%F)/
```

`bin/link` in this kit does that, and is a dry run unless you pass `--apply`.

## Make the install script idempotent

You will run it more than once, and on a half-set-up machine. Every step should check first and be safe to repeat:

```bash
command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file="$DOTFILES/Brewfile"
```

Split it into named steps you can run individually (`bin/install brew`, `bin/install link`). During a migration you'll want to re-run exactly one of them.

## Installers fight your dotfiles

Many installers append lines to `~/.zshrc` or `~/.zprofile`. They check whether their own lines are present, and if not, add them again. When your `.zshrc` is a symlink into the repo, the result is a repo that keeps getting dirty and duplicated config.

Seen in practice with several tools: a PHP environment manager re-adding per-version `*_INI_SCAN_DIR` exports, a CLI re-adding its completions block, Docker Desktop re-adding its `PATH` line, a runtime re-adding its completion line.

**Fix: keep the installer's exact lines in your `.zshrc`, and delete your own equivalent.**

```bash
# >>> some-tool installer >>>
export PATH="$HOME/.some-tool/bin:$PATH"
# <<< some-tool installer <<<
```

Keep the marker comments and the exact variable names. The installer then finds its block and leaves your file alone. Trying to be tidier than the installer means fighting it forever.

After setting up the new Mac, check for this:

```bash
cd ~/.dotfiles && git status --short      # anything modified you didn't touch?
git diff                                  # who appended what
```

## Secrets never go in

Even in a private repo, keep credentials out. Three patterns that work:

1. **A machine-local file**, sourced if present and never committed:
   ```bash
   for f in ~/.dotfiles-custom/*.zsh(N); do source "$f"; done
   ```
2. **A password manager template** rendered at setup time (see [`docs/04-secrets.md`](04-secrets.md)).
3. **Git-crypt or similar** if you insist on one repo, though it's more machinery than most people need.

Scan the repo before making it public or sharing it:

```bash
git log -p --all | grep -nE '(sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|glpat-|AKIA[0-9A-Z]{16}|-----BEGIN)'
```

## macOS defaults worth scripting

```bash
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock autohide -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
killall Dock Finder
```

To find the key for a setting you changed: `defaults read > before.txt`, change it in System Settings, `defaults read > after.txt`, then `diff`.

**Keyboard shortcuts** can be exported and imported as a whole domain:

```bash
defaults export com.apple.symbolichotkeys macos/symbolichotkeys.plist   # old Mac
defaults import com.apple.symbolichotkeys macos/symbolichotkeys.plist   # new Mac
```

**Modifier remapping** (Caps Lock → Control/Command) is stored **per keyboard**, keyed by the keyboard's vendor and product id — which differ between Macs. Copying the setting does nothing. Detect the keyboards present and write the mapping for each:

```bash
hidutil list | awk '$1 ~ /^0x/ && $1 != "0x0" && $4 == 1 && $5 == 6 {print $1, $2}' | sort -u
```

`templates/dotfiles/macos/defaults.sh` includes a working version. Note that `hidutil list --matching '{...}'` is ignored on some macOS builds, so filter the columns yourself.

## App preferences

Many apps keep everything in a preferences domain, which is one command to export and one to import:

```bash
defaults export com.example.app macos/apps/example.plist
defaults import com.example.app macos/apps/example.plist
```

Do the import **before the app's first launch** where possible: some apps write defaults on first run and then ignore your imported file.

Check any exported plist for tokens before committing it.
