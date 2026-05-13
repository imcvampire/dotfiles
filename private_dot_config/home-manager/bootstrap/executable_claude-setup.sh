#!/usr/bin/env bash
# Idempotent Claude Code plugin + MCP bootstrap.
# Wired into home.activation.claudeSetup. Safe to re-run.
set -uo pipefail

command -v claude >/dev/null 2>&1 || {
  echo "claude-setup: claude CLI missing, skipping"
  exit 0
}

# ─── Marketplaces ──────────────────────────────────────────────────────────
MARKETPLACES=(
  "JuliusBrussee/caveman"
  "quant-sentiment-ai/claude-equity-research"
)
for mp in "${MARKETPLACES[@]}"; do
  claude plugin marketplace add "$mp" >/dev/null 2>&1 || true
done

# ─── Plugins ───────────────────────────────────────────────────────────────
PLUGINS=(
  "caveman@caveman"
  "context7@claude-plugins-official"
  "trading-ideas@claude-equity-research-marketplace"
)
for p in "${PLUGINS[@]}"; do
  claude plugin install "$p" >/dev/null 2>&1 || true
done

# ─── Caveman hooks/statusline/skills ───────────────────────────────────────
# Plugin ships own install.sh. `--only claude` constrains to claude profile
# (otherwise auto-detects junie/cursor/copilot from cwd and dumps per-repo
# skill dirs into $PWD). Run from $HOME for safety. Claude skills come
# bundled inside the plugin dir itself — no separate copy needed.
CAVEMAN_DIR=$(ls -dt ~/.claude/plugins/cache/caveman/caveman/*/ 2>/dev/null | head -1)
if [ -n "${CAVEMAN_DIR:-}" ] && [ -x "${CAVEMAN_DIR}install.sh" ]; then
  (cd "$HOME" && bash "${CAVEMAN_DIR}install.sh" --only claude >/dev/null 2>&1) || true
fi

# ─── MCP servers (user scope = available everywhere) ───────────────────────
mcp_has() { claude mcp list 2>/dev/null | grep -q "^$1:"; }

# Official supermemory.ai (HTTP+OAuth) via mcp-remote bridge.
# Matches `npx -y install-mcp@latest https://mcp.supermemory.ai/mcp --client claude-code --oauth=yes`.
mcp_has "supermemory" || claude mcp add --scope user supermemory -- npx -y mcp-remote@latest https://mcp.supermemory.ai/mcp >/dev/null 2>&1 || true

echo "claude-setup: done"
