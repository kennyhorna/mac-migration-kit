# Mac Migration Kit

Move from one MacBook to another without Migration Assistant. You get a clean machine with your setup on it, and a repeatable process for next time.

Written after a full migration. The warnings are things that actually broke.

```bash
git clone https://github.com/<you>/mac-migration-kit.git ~/mac-migration-kit
cd ~/mac-migration-kit
bin/inventory            # what's on this Mac, and what re-cloning would lose
bin/migrate              # pick what you use, get a PLAN.md
bin/progress --todo      # track it
```

## Why not Migration Assistant

It copies everything, including years of cruft: old runtimes, dead package managers, stale login items, caches. Setting up fresh and copying only your data takes a few hours more and leaves you with a machine you understand.

## How it works

Sort everything into three groups:

1. **Declarable.** Packages, dotfiles, editor settings, macOS defaults. These belong in a git repo.
2. **Copyable.** Uncommitted work, local databases, app data, `.env` files, personal folders. Nothing regenerates these, so this is where migrations lose data.
3. **Re-createable.** Logins, licenses, privacy permissions. These need your hands.

`bin/inventory` exists to find everything in group 2 before you start.

## What's here

| Path | What it is |
|---|---|
| `bin/migrate` | Interactive planner. Asks what you use, writes a `PLAN.md` with only the relevant steps |
| `bin/inventory` | Audits the old Mac: packages, shells, keys, repos with unpushed work, app data, AI tooling |
| `bin/transfer` | Copies a folder to the other Mac over SSH, with the macOS pitfalls handled |
| `bin/verify-copy` | Confirms a copy arrived: same files, same sizes, same git state |
| `bin/repo-report` | Lists repos holding work that exists nowhere else |
| `bin/ssh-audit` | Shows which SSH keys you still use, so dead ones stay behind |
| `bin/docker-volumes` | Exports and restores named Docker volumes |
| `bin/progress` | Progress per phase from your `PLAN.md` |
| `docs/` | The guides. Start with [`docs/01-principles.md`](docs/01-principles.md) |
| `templates/` | A dotfiles starter: install and link scripts, Brewfile, macOS defaults, AI config layout |
| `tasks/` | Task fragments the planner assembles into your plan |

## Use it with an AI agent

[`AGENTS.md`](AGENTS.md) (also readable as `CLAUDE.md`) tells a coding agent how to help: what to verify, what never to do unattended, and which steps only you can perform.

```bash
"Read AGENTS.md and run the inventory, then help me plan the migration."
```

## Use a USB-C cable between the two Macs

Fastest transport, no Wi-Fi involved, nothing to configure. macOS brings up a private network between the machines as soon as you connect them.

- A Thunderbolt cable moves tens of Gbit/s. A plain USB-C data cable usually negotiates 100 Mbit/s, which still copies 15 GB in about 20 minutes.
- Company and guest Wi-Fi often block machines from reaching each other, so a network copy may not work at all.
- Copying to an external drive means copying everything twice.

[`docs/02-transport.md`](docs/02-transport.md) has the setup, plus a copy pitfall that loses data while reporting success.

## Ground rules

- **The old Mac stays untouched until the end.** Copy, never move. Wipe it only after the new machine has carried real work for a couple of weeks.
- **Verify every copy.** Exit code 0 proves the command ran, not that your files arrived.
- **Secrets never enter git.** See [`docs/04-secrets.md`](docs/04-secrets.md).
- **One change at a time on the new Mac**, so a failure has an obvious cause.

## Nothing is assumed

The planner asks what you use and drops the rest:

- **Secrets:** a password manager with an SSH agent, or plain SSH key files.
- **Dev environment:** Homebrew, and any of Node, PHP, Ruby, Python, Rust, Go, Java, Docker.
- **Local PHP:** Herd, Valet, Docker, or Homebrew PHP.
- **Editors:** JetBrains IDEs, VS Code, Cursor, Zed, Sublime, Xcode.
- **AI tooling:** Claude Code, Codex, Gemini, Copilot, Cursor and others, including MCP servers, skills and agent instruction files.

A minimal setup produces a plan of about 65 steps; selecting everything produces about 120.

## Credits

The dotfiles half of this (symlinked config, a Brewfile as the source of truth, one idempotent install script) follows [A tour of my dotfiles](https://freek.dev/3054-a-tour-of-my-dotfiles) by Freek Van der Herten. This kit adds the parts a repo can't hold: the data, and the checklist to move it safely.

## License

MIT. See [LICENSE](LICENSE).
