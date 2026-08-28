# Bootstrap

Idempotent setup scripts wired into home-manager activation
(`home.activation.{claudeSetup,codexSetup}`). Run on every `darwin-rebuild switch`.

## Tools installed

- **trading-ideas** — plugin
  - Claude Code (via `quant-sentiment-ai/claude-equity-research` marketplace)
- **context7**
  - Claude Code → plugin (via `claude-plugins-official` marketplace)
  - Claude Desktop → MCP (via `install-mcp @upstash/context7-mcp --client claude`)
  - Codex → MCP server (`npx -y @upstash/context7-mcp`)
- **anytype** — MCP (env-gated on `ANYTYPE_MCP_HEADERS`)
  - Codex

## Shared skills (`~/.agents/skills`)

Cross-agent skill directory. Drop a `<name>/SKILL.md` in there, run
`skills-sync`, and both CLIs pick it up — while each keeps its own
specialized skills alongside.

```
~/.agents/skills/<name>/SKILL.md          shared — source of truth
~/.claude/skills/                         real dir
  ├── <claude-only>/SKILL.md              Claude-specific
  └── <name> -> ~/.agents/skills/<name>   one symlink per shared skill
~/.codex/skills/                          real dir
  ├── .system/                            codex built-ins (untouched)
  ├── <codex-only>/SKILL.md               Codex-specific
  └── <name> -> ~/.agents/skills/<name>   one symlink per shared skill
```

`skills-sync.sh` maintains the symlinks (idempotent): it links every shared
dir containing a `SKILL.md`, prunes links whose shared skill is gone, and
never touches anything that is not a symlink into `~/.agents/skills`. It runs
on every `darwin-rebuild switch` (`home.activation.skillsSync`, after
`claudeSetup`/`codexSetup`) and is on `PATH` as `skills-sync` for use between
rebuilds.

### Discovery models

| CLI | Roots read | Follows symlinked skill dirs | De-dupes by |
| --- | --- | --- | --- |
| Claude Code | `~/.claude/skills` only (+ managed, project) | yes | n/a — single root |
| Codex | `~/.codex/skills` **and** `~/.agents/skills` | yes | resolved path |

Verified 2026-08-28 with `claude --debug` (root list) plus a live probe skill,
and `codex debug prompt-input` (`<skills_instructions>` listing).

Consequences:

- Claude Code has no setting to add a skills root, which is why the fan-out
  exists at all.
- Codex would see shared skills without any symlinks. They are created anyway
  to keep both roots symmetric and self-describing, and cost nothing: Codex
  de-dupes by resolved path, so a symlinked skill is still listed once.
  (An earlier comment in `codex-setup.sh` claimed symlinks double-register.
  That was wrong.)
- **Overriding** a shared skill by name works cleanly only in Claude Code:
  replace the symlink with a real dir and `skills-sync` leaves it alone. In
  Codex the same move registers the name **twice** (own root + native shared
  read are different files); `skills-sync` prints a WARNING. Rename the
  override, or drop the shared copy.

Neither script creates `~/.agents/skills` — it is provisioned separately. A
missing shared dir is not an error; `skills-sync` just logs and links nothing.

Superseded: `~/.claude/skills` used to be a whole-dir symlink to
`~/.agents/skills`. That blocked Claude-specific skills entirely and let
Claude Code's own writes (`.trash/`, `synced/`) land in the shared dir.
`skills-sync` migrates the old symlink to a real dir automatically.

## Scripts

- `claude-setup.sh` — Claude Code + Claude Desktop
- `codex-setup.sh` — Codex

## Manual steps on new machine

- `claude login` — Claude Code OAuth
- `codex login` — ChatGPT OAuth
- First codex run → trust `~/.codex/hooks.json` entries
- Enable codex plugins via `/plugin` in TUI (no CLI verb)
- Per-service auth for codex curated plugins (alpaca, binance, github)
- Codex project trust accepted per-dir on first invocation
