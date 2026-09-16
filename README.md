# Mac Migration Kit

A practical, checklist-driven way to move from one MacBook to another **without Migration Assistant** — so the new machine gets your setup, not your accumulated mess.

Built from a real migration. Every warning in here corresponds to something that actually went wrong.

```bash
git clone https://github.com/<you>/mac-migration-kit.git ~/mac-migration-kit
cd ~/mac-migration-kit
bin/inventory            # what's on this Mac, and what would be lost by only re-cloning
bin/migrate              # pick what you use → writes a PLAN.md tailored to you
bin/progress --todo      # track it
```

## Why not Migration Assistant?

It copies everything, including years of cruft: old language runtimes, dead package managers, stale login items, caches. A fresh setup plus a deliberate copy of your data gives you a clean machine and, as a by-product, a repeatable setup you can reuse next time.

The trade-off is a few hours of work. This kit removes most of it.

## The idea

1. **Declare** what can be declared: packages, dotfiles, editor settings, macOS defaults. These live in a git repo you keep.
2. **Copy** what can't: work in progress, local databases, app data, anything the app encrypts per device.
3. **Re-create** what neither can hold: logins, licenses, permissions. These need hands.

Anything in category 2 is the migration's real risk, and `bin/inventory` is built to find it.

## What's here

| Path | What it is |
|---|---|
| `bin/migrate` | Interactive planner. Asks what you use, writes a `PLAN.md` with only the relevant steps |
| `bin/inventory` | Audits the old Mac: packages, shells, keys, git repos with unpushed work, app data, AI tooling |
| `bin/transfer` | Copies a folder to the other Mac over SSH, with the macOS pitfalls handled |
| `bin/verify-copy` | Confirms a copy arrived: same files, same sizes |
| `bin/repo-report` | Lists git repos holding work that exists nowhere else |
| `bin/ssh-audit` | Shows which SSH keys you actually still use, so you don't carry dead ones over |
| `bin/progress` | Progress bars per phase from your `PLAN.md` |
| `docs/` | The guides. Start with [`docs/01-principles.md`](docs/01-principles.md) |
| `templates/` | Starting points: dotfiles layout, `Brewfile`, `.gitignore`, secrets template |
| `tasks/` | Task fragments the planner assembles into your `PLAN.md` |

## Use it with an AI agent

The repo is written so a coding agent (Claude Code, Codex, Copilot CLI, Cursor, …) can drive the migration with you. [`AGENTS.md`](AGENTS.md) is the playbook: what to check, what to never do unattended, and how to verify each step.

```bash
# in the repo, with your agent of choice
"Read AGENTS.md and run the inventory, then help me plan the migration."
```

## Recommended: connect the two Macs with a USB-C cable

The fastest and simplest transport, and it avoids Wi-Fi entirely.

- A **Thunderbolt** cable gives you tens of Gbit/s; a plain **USB-C data** cable typically gives 100 Mbit/s or more. Both beat copying to an external drive twice.
- macOS brings up a private network between the two Macs automatically. Nothing to configure.
- Company Wi-Fi often isolates devices from each other, so a direct copy over the network may not work at all.

See [`docs/02-transport.md`](docs/02-transport.md) for the setup, and for a copy pitfall that silently loses data.

## Ground rules

- **The old Mac stays untouched until the end.** Copy, never move. Wipe only after the new machine has carried your work for a couple of weeks.
- **Verify every copy.** "The command exited 0" is not evidence. Compare file counts and sizes; for git repos compare commits, branches and stashes.
- **Secrets never enter git.** See [`docs/04-secrets.md`](docs/04-secrets.md).
- **One change at a time on the new Mac**, so you can tell what broke.

## Optional by design

Nothing here assumes your exact stack. The planner asks, and skips what you don't use:

- **Secrets:** a password manager with an SSH agent, or plain SSH keys with a passphrase.
- **Dev environment:** Homebrew, and any of Node, PHP, Ruby, Python, Rust, Go, Java, Docker.
- **PHP:** Herd, Valet, Docker, or plain Homebrew PHP.
- **Editors:** JetBrains IDEs, VS Code, Cursor, Zed, Sublime, Xcode.
- **AI tooling:** Claude Code, Codex CLI, Gemini CLI, Copilot, Cursor, and others — including MCP servers and agent instruction files.

## Credits

The dotfiles approach here — a repo of symlinked config, a `Brewfile` as the single source of truth for
packages, and one idempotent install script that sets up a Mac in minutes — is inspired by
[**A tour of my dotfiles**](https://freek.dev/3054-a-tour-of-my-dotfiles) by Freek Van der Herten.
Read it: it's a short post and a good model for the "declarable" half of a migration.

This kit adds the other half — the data that no repo can hold, and the checklist to move it safely.

## License

MIT. See [LICENSE](LICENSE).
