#!/usr/bin/env bash
# Idempotent Claude Code plugin + MCP bootstrap.
# Wired into home.activation.claudeSetup. Safe to re-run.
set -uo pipefail

# Neutralize ~/.gitconfig + /etc/gitconfig for child git invocations.
# Activation sandbox lacks ssh on PATH; user's insteadOf rewrites
# https://github.com/ → git@github.com: and breaks every clone here.
# Pointing these at /dev/null makes git skip both files entirely.
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_SYSTEM=/dev/null
export GIT_TERMINAL_PROMPT=0

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
  "quant-sentiment-ai/claude-equity-research"
)
for mp in "${MARKETPLACES[@]}"; do
  step "marketplace $mp" \
    claude plugin marketplace add "$mp"
done

# ─── Plugins ───────────────────────────────────────────────────────────────
PLUGINS=(
  "context7@claude-plugins-official"
  "trading-ideas@claude-equity-research-marketplace"
)
for p in "${PLUGINS[@]}"; do
  step "plugin $p" \
    claude plugin install "$p"
done

# ─── Shared skills ─────────────────────────────────────────────────────────
# Claude Code discovers user skills in ~/.claude/skills only. Verified with
# `claude --debug`:
#   Loading skills from: managed=/Library/Application Support/ClaudeCode/...,
#                        user=/Users/<u>/.claude/skills, project=[]
# There is no setting to add another root. It DOES follow symlinked skill
# dirs inside that root, so ~/.claude/skills stays a real directory holding
# Claude-only skills plus one symlink per shared skill. That fan-out lives in
# skills-sync.sh (home.activation.skillsSync, also on PATH as `skills-sync`),
# shared with Codex — not here.

# ─── Statusline ──────────────────────────────────────────────────────────────
# Point Claude Code at ~/.claude/statusline.sh. Idempotent jq merge into
# settings.json (preserves all other keys). Skipped if jq missing.
set_statusline() {
  local settings="$HOME/.claude/settings.json"
  command -v jq >/dev/null 2>&1 || { log "jq missing, skip statusline"; return 0; }
  mkdir -p "$(dirname "$settings")"
  [ -s "$settings" ] || echo '{}' > "$settings"
  local tmp
  tmp=$(mktemp)
  jq '.statusLine = {"type":"command","command":"bash ~/.claude/statusline.sh"}' \
    "$settings" > "$tmp" && mv "$tmp" "$settings"
}
step "statusline" set_statusline

# ─── MCP servers via install-mcp ───────────────────────────────────────────
# Registers MCPs in Claude Code (~/.claude.json) and Claude Desktop
# (~/Library/Application Support/Claude/claude_desktop_config.json).
# Idempotent.

# context7 — Desktop only (Claude Code already has it as plugin).
step "install-mcp context7 --client claude" \
  npx -y install-mcp@latest @upstash/context7-mcp --client claude --yes

log "done"
