# Verification

Treat every copy as unproven until you've checked it. This page is the list of checks worth running.

## Files

```bash
bin/verify-copy ~/Pictures user@169.254.x.y Pictures
```

It compares file paths and sizes as **sets** on both machines. Two details matter:

- **Don't `diff` two sorted listings.** The two Macs can sort filenames differently, producing mismatches that don't exist.
- **Ignore `.DS_Store`** and files you intentionally excluded, or you'll chase ghosts.

Spot-check content too, not just sizes: open a few documents, play a video, check an image thumbnail.

## Git repositories

For each project, compare on both machines:

```bash
git rev-parse HEAD          # same commit
git status --porcelain      # same modified files
git stash list              # same stashes
git for-each-ref refs/heads # same branches
```

`bin/verify-copy --git ~/Code user@host Code` does this for every repo in a folder and prints only the differences. Expect two harmless classes of difference:

- `.DS_Store` files
- Files ignored through a **global** gitignore that isn't on the new Mac yet (`git config --global core.excludesfile`) — put that file in your dotfiles

## Shell and environment

```bash
zsh -l -c 'echo $PATH' | tr ':' '\n'      # expected entries, no duplicates
which node php python3 ruby               # the versions you expect
env | grep -c .                           # sanity check
```

Open a **new terminal window** for this, not the one you've been working in.

## Secrets and access

```bash
ssh -T git@github.com            # authenticates as you
git -C ~/some/repo pull          # real operation through your agent
aws sts get-caller-identity      # or your cloud equivalent
```
Then start the apps that need credentials and confirm each connects.

## Development environment

```bash
brew bundle check --file=~/.dotfiles/Brewfile     # everything installed
```
Then, per project type: run the test suite of 2–3 projects, start a dev server, open a local site over HTTPS. Tests passing is the strongest signal that toolchain, dependencies and databases all work.

## AI tooling

- Each CLI starts and is authenticated.
- Instructions load (ask for a rule only your instructions contain).
- MCP servers connect, including one that needs a token.
- Skills are listed.
- Project memory is found for a project you've worked on.

## macOS settings

- Dock position and behaviour
- Keyboard: modifier remapping, key repeat, custom shortcuts
- Trackpad: tap to click, gestures
- Privacy permissions: Accessibility, Screen Recording, Full Disk Access — each app that needs them

## A habit worth keeping

After the migration, when you change something meaningful (a new tool, an MCP server, a macOS default), capture it back into your dotfiles and push:

```bash
cd ~/.dotfiles && git status --short
```

A dotfiles repo that drifts for a year is a dotfiles repo you won't trust next time.
