# Development environment

## Packages: one Brewfile

```bash
brew bundle dump --describe --file=~/.dotfiles/Brewfile     # on the old Mac
brew bundle --file=~/.dotfiles/Brewfile                     # on the new one
brew bundle check --file=~/.dotfiles/Brewfile               # verify
```

**Curate it before you use it.** A dump reflects years of experiments. Remove what you no longer use, and add the apps you installed by hand. Check `/Applications` against `brew list --cask`, since hand-installed apps won't be in the dump.

Points that bite:

- **Apps installed by hand** make `brew bundle` fail with "already an App at ...". Let Homebrew adopt them: `brew install --cask --adopt <name>`.
- **Deprecated or removed formulae** stop a bundle run. Check yours: `brew info <formula> | head -2`.
- **Taps that merged into Homebrew** fail to tap at all. If a tap's folder only contains a README, it's probably obsolete, so remove it from the Brewfile.
- **App Store apps** need `mas` plus being signed in to the App Store: `mas list` gives you the ids.
- **Global npm/cargo packages don't belong in a Brewfile**: they need their toolchains installed first. Put them in your install script after the toolchain step.

## Language toolchains

Install the version manager from Homebrew, then the runtime, then global packages, in that order, in your install script.

| Language | Common setup | Migration notes |
|---|---|---|
| Node | nvm, fnm, volta, asdf/mise | Install one LTS by default; per-project `.nvmrc` handles the rest. Reinstall global packages explicitly |
| PHP | Herd, Valet, Docker, Homebrew PHP | See below |
| Ruby | rbenv, chruby, asdf/mise | Check whether anything still needs it before carrying versions over |
| Python | pyenv, uv, Homebrew | `pipx` apps are declared with `pipx list`; reinstall them |
| Rust | rustup | `rustup default stable`, then `cargo install` your tools. Homebrew's rustup is keg-only, so it needs a PATH entry |
| Go, Java | Homebrew, sdkman | Straightforward |

Two ordering traps:

- Scripts that run with `set -eu` break when they source a version manager's shell script (`nvm.sh` doesn't tolerate `set -u`). Relax the flags around it.
- A toolchain installed by Homebrew may not be on `PATH` until your shell config is linked. Set the PATH explicitly inside the install step rather than relying on the shell.

## PHP with Herd or Valet (optional)

If you serve sites locally with Herd or Valet, capture more than the app:

- **Which folders are parked**, and which sites are **linked** individually
- **Which sites use a non-default PHP version** ("isolated" sites)
- **Which sites are secured** (HTTPS)
- **Your `php.ini` overrides** per version
- **The default PHP version**, easily forgotten, and the cause of a confusing class of failures where Composer resolves for the wrong version

`bin/inventory` captures all of this into a snapshot, and `templates/dotfiles/bin/herd-restore` replays it. Watch for:

- **Case sensitivity:** these tools lowercase site names while folders may be capitalized. Match case-insensitively when restoring, or some sites silently keep the default version.
- **Extra link names:** a folder can be served under several hostnames; pinning the PHP version for one name doesn't pin the others.
- **Missing PHP versions:** install every version your sites use, or they fall back to the default.
- **Running `php` in a terminal** doesn't necessarily use a site's pinned version. Use the tool's wrapper (`herd composer`, `valet php`) when installing dependencies.

## Rebuilding project dependencies

If you excluded `vendor` and `node_modules` from the transfer, every project needs a rebuild:

```bash
composer install     # or `herd composer install` / `valet composer install`
npm ci               # or npm install when there's no lockfile
```

Before you start:

- **Private package credentials** (`~/.composer/auth.json`, `~/.npmrc`) must be in place, or installs fail on the first private package.
- **Company package servers may need VPN.**
- **Projects that run in Docker** should install inside their container, not on the host; they often need extensions the host doesn't have.
- **`npm ci` requires a lockfile.** Fall back to `npm install` when there isn't one.

Automate the sweep and log the result per project, so you can see which ones failed and why instead of watching 20 installs scroll past.

## Local databases

Decide per project: re-seed (usually best) or move the data.

- **Re-seed:** start the services, then `migrate --seed` or the project's equivalent.
- **Move:** dump and restore (`mysqldump`, `pg_dump`) or move the Docker volume ([`docs/06-apps.md`](06-apps.md)).
- **Production data** should come from a fresh snapshot on the new machine, not from a copy of your old laptop.

Remember that services must be running before any of this: Docker containers, Homebrew services (`brew services list`), or your PHP tool's bundled MySQL/Postgres.

## Your code folder

- **Copy it; don't rely on re-cloning.** `bin/repo-report` shows what re-cloning would lose: uncommitted changes, stashes, branches never pushed, and repos with no remote at all.
- **Excluding dependency folders** makes the copy much smaller and faster. Keep `.git`, `.env` and local database files.
- **A migration is a good moment to reorganize** (say, grouping web projects under one parent folder). If you do, update anything that stores absolute paths: local site definitions, IDE run configs, per-project AI tool config, and assistant memory folders.
- **Archive rather than carry** projects you haven't touched in a year but that hold unique work: one `.tar.gz` each, stored with your documents.
