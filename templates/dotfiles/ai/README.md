# AI tooling, defined once

One set of instructions, MCP servers and skills, projected into whichever assistants you use.
See [`docs/05-ai-tools.md`](../../../docs/05-ai-tools.md) for the reasoning.

```
ai/
├── AGENTS.md     your global instructions — symlinked into each tool
├── mcp.json      MCP servers, defined once, with ${VAR} references instead of secrets
├── skills/       skills/prompts you wrote
└── settings/     per-tool settings worth versioning
```

## Instructions

```bash
ln -sfn ~/.dotfiles/ai/AGENTS.md ~/.claude/CLAUDE.md
ln -sfn ~/.dotfiles/ai/AGENTS.md ~/.codex/AGENTS.md
ln -sfn ~/.dotfiles/ai/AGENTS.md ~/.gemini/GEMINI.md
# Cursor and IDE assistants read their own rules files — point them at the same content
```

Some tools only create their config folder at first launch, so start each one once before linking.

## MCP servers

Keep one definition and render it per tool. The shapes differ but the fields map cleanly:

```json
{
  "mcpServers": {
    "example-http": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": { "API_KEY": "${EXAMPLE_API_KEY}" }
    },
    "example-stdio": {
      "type": "stdio",
      "command": "node",
      "args": ["${HOME}/Code/example-mcp/dist/index.js"],
      "env": { "TOKEN": "${EXAMPLE_TOKEN}" }
    }
  }
}
```

- **Secrets stay as `${VAR}` references.** Values come from your environment or password manager.
- **Absolute paths** (`${HOME}/...`) break if you reorganize folders during the migration — check them afterwards.
- **Some tools read another tool's config** through a compatibility mode. Check before defining the same server twice; duplicates can shadow each other.

## Skills and prompts

- Keep your own in `skills/` here and symlink them where each tool expects them.
- Track third-party ones in a list (name plus source) and re-install them on the new Mac.
- **Never let a script write that list back from local state:** a partial install then shrinks the list, and later runs think there's nothing to do.
