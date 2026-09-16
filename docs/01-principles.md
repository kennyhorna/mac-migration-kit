# Principles: what moves, what doesn't

Sort everything you own into three buckets before you copy a single byte. The middle bucket is where migrations go wrong.

## 1. Declarable: belongs in a git repo

Rebuildable from a text file, so it should never be copied by hand:

- Installed packages and apps (`Brewfile`, App Store apps via `mas`)
- Shell config, aliases, functions, `PATH`
- Editor settings, keymaps, snippets
- macOS defaults: Dock, Finder, keyboard, trackpad, keyboard shortcuts
- Per-project configuration that's already committed to the project's repo

Keep these in a dotfiles repo (see [`docs/03-dotfiles.md`](03-dotfiles.md)). A private repo is fine and usually wise.

## 2. Copyable: exists only on this machine

This is the dangerous bucket. Nothing regenerates it:

- **Uncommitted work**: modified files, stashes, branches never pushed, whole repos without a remote
- **Local databases**: Docker volumes, SQLite files, seeded dev data
- **App data**: notes, project files, terminal history, AI assistant memory and chat history
- **`.env` files** and other ignored-but-essential files
- **Documents, Pictures, Downloads** and other personal folders

`bin/inventory` and `bin/repo-report` exist to enumerate this bucket. Do that before you plan anything.

## 3. Re-createable: needs hands and accounts

Not copyable, or not safely copyable:

- **Logins and sessions** for every app and website
- **Licenses**, especially ones locked to a device
- **Privacy permissions**: Accessibility, Screen Recording, Full Disk Access. macOS ties these to the machine, deliberately
- **Keychain entries**, including passwords apps store on your behalf

Budget time for this bucket. It's mostly clicking, and it's the part people forget.

## The Keychain rule

**Any password an app "remembers" for you probably lives in the macOS Keychain, not in the app's config folder.** Copying the config gives you the entries without the passwords.

This hits database clients, IDE database connections, mail accounts and more. Two options:

1. Use the app's own **export** feature, which usually offers to include passwords behind a passphrase.
2. Store the passwords in a password manager beforehand, and re-enter them.

Related: **encrypted app data**. Browsers encrypt cookies and saved logins with a per-device key. Copying a browser profile to another Mac yields history and bookmarks, but dead sessions.

## The license rule

Licenses come in three shapes:

- **Account-based** (sign in, done): JetBrains, most subscriptions. Easiest.
- **Key-based** (a key you paste): keep the key in your password manager. If you don't have it, find it before you wipe anything.
- **Device-bound** (an activation file on disk): must be deactivated on the old machine and re-activated on the new one. Copying the file does nothing.

Check each paid app while the old Mac still works. Deactivate where the app offers it.

## Don't carry over what you don't use

A migration is the cheapest moment to drop things:

- Packages you installed once for an experiment
- Repos already pushed and untouched for years. Re-clone if you ever need them
- SSH keys nothing accepts any more (`bin/ssh-audit` finds these)
- Apps you haven't opened in a year

Archive rather than delete when unsure: pack old projects into `.tar.gz` files that live with your documents, not in your working folder.

## Same username, fewer surprises

Create the first account on the new Mac with the **same short username** as the old one. Absolute paths appear in more config files than you'd expect: database clients, IDE run configs, MCP server definitions, service files. Matching usernames makes those paths keep working.

## Verify, always

After every copy:

- **Files:** same count, same sizes on both sides (`bin/verify-copy`)
- **Git repos:** same commit, same branches, same stashes, same list of modified files
- **Apps:** open one and look at real data, not just the splash screen

Exit code 0 means the command ran, not that your data arrived. See [`docs/02-transport.md`](02-transport.md) for a case where the copy tool reports success and transfers nothing.
