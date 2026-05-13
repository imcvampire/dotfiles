# Bootstrap

Idempotent setup scripts wired into home-manager activation
(`home.activation.{claudeSetup,codexSetup}`). Run on every `darwin-rebuild switch`.

## Tools installed

- **caveman**
  - Claude Code → plugin + hooks + statusline (via `caveman/install.sh --only claude`)
  - Codex → skills in `~/.agents/skills/` (via `caveman/install.sh --only codex`)
- **caveman-shrink** — MCP
  - Claude Code (registered automatically by `caveman/install.sh`)
  - Claude Desktop (via `install-mcp caveman-shrink --client claude`)
- **trading-ideas** — plugin
  - Claude Code (via `quant-sentiment-ai/claude-equity-research` marketplace)
- **context7**
  - Claude Code → plugin (via `claude-plugins-official` marketplace)
  - Claude Desktop → MCP (via `install-mcp @upstash/context7-mcp --client claude`)
  - Codex → MCP server (`npx -y @upstash/context7-mcp`)
- **supermemory** — MCP via `install-mcp`, endpoint `https://mcp.supermemory.ai/mcp`, project `default`
  - Claude Code
  - Claude Desktop
  - Codex
- **anytype** — MCP (env-gated on `ANYTYPE_MCP_HEADERS`)
  - Codex

## Scripts

- `claude-setup.sh` — Claude Code + Claude Desktop
- `codex-setup.sh` — Codex

## Manual steps on new machine

- `claude login` — Claude Code OAuth
- `codex login` — ChatGPT OAuth
- First MCP tool call per client → browser opens for supermemory.ai OAuth
- First codex run → trust `~/.codex/hooks.json` entries
- Enable codex plugins via `/plugin` in TUI (no CLI verb)
- Per-service auth for codex curated plugins (alpaca, binance, github)
- Codex project trust accepted per-dir on first invocation
