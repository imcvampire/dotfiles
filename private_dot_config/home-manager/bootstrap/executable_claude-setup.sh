#!/usr/bin/env bash
# Idempotent Claude Code plugin + MCP bootstrap.
# Wired into home.activation.claudeSetup. Safe to re-run.
set -uo pipefail

log() { printf "[%s] claude-setup: %s\n" "$(date +%H:%M:%S)" "$*"; }
step() {
  local name="$1"; shift
  log "→ $name"
  local t0=$(date +%s)
  if "$@"; then
    log "✓ $name ($(($(date +%s) - t0))s)"
  else
    local rc=$?
    log "✗ $name (rc=$rc, $(($(date +%s) - t0))s)"
  fi
}

command -v claude >/dev/null 2>&1 || { log "claude CLI missing, skipping"; exit 0; }

log "start"

# ─── Marketplaces ──────────────────────────────────────────────────────────
MARKETPLACES=(
  "JuliusBrussee/caveman"
  "quant-sentiment-ai/claude-equity-research"
)
for mp in "${MARKETPLACES[@]}"; do
  step "marketplace $mp" \
    claude plugin marketplace add "$mp"
done

# ─── Plugins ───────────────────────────────────────────────────────────────
PLUGINS=(
  "caveman@caveman"
  "context7@claude-plugins-official"
  "trading-ideas@claude-equity-research-marketplace"
)
for p in "${PLUGINS[@]}"; do
  step "plugin $p" \
    claude plugin install "$p"
done

# ─── Caveman hooks/statusline/skills ───────────────────────────────────────
# Plugin ships own install.sh. `--only claude` constrains to claude profile
# (otherwise auto-detects junie/cursor/copilot from cwd and dumps per-repo
# skill dirs into $PWD). Run from $HOME for safety. Claude skills come
# bundled inside the plugin dir itself — no separate copy needed.
CAVEMAN_DIR=$(ls -dt ~/.claude/plugins/cache/caveman/caveman/*/ 2>/dev/null | head -1)
if [ -n "${CAVEMAN_DIR:-}" ] && [ -x "${CAVEMAN_DIR}install.sh" ]; then
  step "caveman --only claude" \
    bash -c "cd \"\$HOME\" && bash \"${CAVEMAN_DIR}install.sh\" --only claude"
else
  log "skip caveman: plugin dir not found at ~/.claude/plugins/cache/caveman/caveman/*/"
fi

# ─── MCP servers via install-mcp ───────────────────────────────────────────
# Registers MCPs in Claude Code (~/.claude.json) and Claude Desktop
# (~/Library/Application Support/Claude/claude_desktop_config.json).
# Idempotent. Default project for supermemory: "default".

# Official supermemory.ai (HTTP+OAuth via mcp-remote bridge).
step "install-mcp supermemory --client claude-code" \
  npx -y install-mcp@latest https://mcp.supermemory.ai/mcp --client claude-code --oauth=yes --project default --yes
step "install-mcp supermemory --client claude" \
  npx -y install-mcp@latest https://mcp.supermemory.ai/mcp --client claude --oauth=yes --project default --yes

# context7 — Desktop only (Claude Code already has it as plugin).
step "install-mcp context7 --client claude" \
  npx -y install-mcp@latest @upstash/context7-mcp --client claude --yes

# caveman-shrink — Desktop only (Claude Code gets it via caveman/install.sh).
step "install-mcp caveman-shrink --client claude" \
  npx -y install-mcp@latest caveman-shrink --client claude --yes

log "done"
