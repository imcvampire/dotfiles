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

Cross-agent skill directory. Drop a `<name>/SKILL.md` in there and both CLIs
pick it up.

| CLI | Support | Wiring |
| --- | --- | --- |
| Codex | native | none — reads `~/.agents/skills` directly |
| Claude Code | none | `~/.claude/skills` → `~/.agents/skills` symlink |

Claude Code searches only `managed`, `user` (`~/.claude/skills`) and `project`
(`.claude/skills`) roots, with no setting to add another, so `claude-setup.sh`
symlinks the user root at `~/.agents/skills`. The link is skipped (with a
warning) if `~/.claude/skills` already exists as a non-empty real directory.

Neither script creates `~/.agents/skills` — it is provisioned separately. The
symlink is made regardless of whether the directory exists yet; a dangling
link is harmless and starts working as soon as the directory appears, so
activation ordering does not matter.

Caveat: Claude Code's own skill writes (`.trash/`, `synced/`) land in
`~/.agents/skills` once the symlink is in place.

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
