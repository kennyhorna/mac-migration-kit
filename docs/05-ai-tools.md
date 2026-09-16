# AI tools: agents, instructions, MCP servers and memory

AI coding tools spread configuration across several dotfolders, and most of it isn't synced anywhere. This guide covers what to move, and how to stop the same setup drifting apart across tools.

## What each tool keeps, and where

Paths change as these tools evolve — check yours before copying. Common locations:

| Tool | Config | Typically holds |
|---|---|---|
| Claude Code | `~/.claude/`, `~/.claude.json` | settings, instructions (`CLAUDE.md`), skills, MCP servers, per-project history and memory |
| Codex CLI | `~/.codex/` | `config.toml` (incl. MCP servers), instructions (`AGENTS.md`), sessions, auth |
| Gemini CLI | `~/.gemini/` | `settings.json` (incl. MCP servers), instructions (`GEMINI.md`), auth |
| Copilot (CLI / IDE) | `~/.config/github-copilot/`, IDE settings | auth, per-IDE settings |
| Cursor | `~/.cursor/`, `~/Library/Application Support/Cursor/` | rules, MCP (`mcp.json`), editor settings, extensions |
| Other agent CLIs | `~/.<tool>/` | usually the same shape: config file, instructions file, auth, sessions |

**Rules of thumb:**

- **Auth files are per-device.** Don't copy them; log in again. Copying them often fails silently or logs you out everywhere.
- **Instructions and MCP definitions are the valuable part.** They're small text files: version them.
- **History and memory are copyable**, and worth it if your assistant remembers project context. They're keyed by absolute project path (see below).
- **Skills/prompt libraries** are usually plain folders: version the ones you wrote, re-install third-party ones from source.

## One source of truth beats per-tool copies

If you use more than one assistant, keep a single set of instructions and MCP servers and project them into each tool. A layout that works:

```
~/.dotfiles/ai/
├── AGENTS.md            # your global instructions, shared by every tool
├── mcp.json             # MCP servers, defined once
├── skills/              # your own skills/prompts
└── settings/            # per-tool settings you want versioned
```

Then:

- **Instructions:** symlink each tool's instruction file to `AGENTS.md`
  ```bash
  ln -sfn ~/.dotfiles/ai/AGENTS.md ~/.claude/CLAUDE.md
  ln -sfn ~/.dotfiles/ai/AGENTS.md ~/.codex/AGENTS.md
  ln -sfn ~/.dotfiles/ai/AGENTS.md ~/.gemini/GEMINI.md
  ```
- **MCP servers:** keep one definition and render it into each tool's format. Claude and Cursor use JSON, Codex uses TOML, others vary — the fields (command, args, env, url, headers) map cleanly between them.
- **Secrets in MCP definitions:** always `${VAR}` references, never literal tokens, with the values coming from your shell environment or password manager.

Some tools read another tool's config directly (a compatibility mode for Claude's config files is common). Check before defining the same server twice: duplicates can shadow each other.

## Multiple profiles or accounts (optional)

If you keep separate setups (work and personal, say), most CLIs support pointing at a different config directory through an environment variable, e.g. a wrapper alias per profile. When migrating:

- Repeat each step per profile.
- Remember that "start the tool once" is usually required before its config file exists — several tools only create it at first launch, so scripted config writing must happen **after** that.

If you only use one profile, ignore all of this.

## Memory and history are keyed by absolute path

Assistants that remember per-project context store it in a folder named after the project's path, e.g. `-Users-you-Code-project`.

**If you reorganize projects during the migration** (say `~/Code/foo` becomes `~/Code/web/foo`), rename those folders to match, or the memory is orphaned:

```
~/.claude/projects/-Users-you-Code-foo   →   -Users-you-Code-web-foo
```

Same reasoning applies to per-project MCP definitions and IDE run configs: they store absolute paths. Reorganize deliberately, then fix the references in one pass.

## Skills, prompts and plugins

- **Your own:** move them into your dotfiles and symlink them into each tool's folder. They're worth keeping across machines.
- **Third-party:** re-install from source on the new Mac. Keep the list (a lock file, or just a text file of names and repos) in your dotfiles.
- **Plugins/marketplaces:** usually re-installed from a list in the tool's settings file, so version that file.

**A trap worth knowing:** if your setup script both installs from a list *and* writes the list back from local state, a partial install can overwrite the list with fewer entries, and later runs then "have nothing to do". Keep the list in the repo as the source of truth and never write it back automatically.

## Editor-based assistants

- **Copilot in an IDE:** settings live with the IDE (see [`docs/06-apps.md`](06-apps.md)); auth is per-device, so sign in again.
- **Cursor:** it's a VS Code fork — settings, keybindings and extensions export the same way. Its rules and MCP files are worth versioning.
- **Continue/others:** config is usually a single JSON/YAML file, easy to version.

## Verify on the new Mac

1. Each CLI starts and is logged in.
2. Instructions load: ask the assistant to state a rule only your instructions contain.
3. MCP servers connect: list them in each tool. A server that needs a token proves your secret injection works.
4. Skills appear in the tool's skill list.
5. Memory: open a project you've worked on and check whether the assistant recalls prior context.
