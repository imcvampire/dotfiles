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

# ─── Shared skills dir (~/.agents/skills) ──────────────────────────────────
# Claude Code discovers user skills in ~/.claude/skills only. Verified with
# `claude --debug`:
#   Loading skills from: managed=/Library/Application Support/ClaudeCode/...,
#                        user=/Users/<u>/.claude/skills, project=[]
# There is no ~/.agents/skills in its search path and no setting to add one,
# so bridge the two with a symlink. Codex reads ~/.agents/skills natively —
# see codex-setup.sh.
AGENTS_SKILLS="$HOME/.agents/skills"
link_agents_skills() {
  local target="$HOME/.claude/skills"

  # The source dir is created elsewhere. Link it anyway if it is not there
  # yet — a dangling symlink is harmless (Claude Code just logs a failed
  # stat) and starts working the moment the directory appears, which keeps
  # this independent of activation ordering.
  [ -d "$AGENTS_SKILLS" ] || log "  note: $AGENTS_SKILLS does not exist yet"

  # Already pointing where we want it.
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$AGENTS_SKILLS" ]; then
    log "  already linked"
    return 0
  fi

  # A real directory holding skills is user data — never clobber it.
  if [ -d "$target" ] && [ ! -L "$target" ]; then
    if [ -n "$(ls -A "$target" 2>/dev/null)" ]; then
      log "  $target is a non-empty real dir; move its contents into"
      log "  $AGENTS_SKILLS and re-run to finish the switch"
      return 1
    fi
    rmdir "$target"
  fi

  ln -sfn "$AGENTS_SKILLS" "$target"
}
step "link ~/.agents/skills -> ~/.claude/skills" link_agents_skills

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
