#!/usr/bin/env bash
# Idempotent Codex CLI bootstrap.
# Wired into home.activation.codexSetup. Safe to re-run.
set -uo pipefail

# Neutralize ~/.gitconfig + /etc/gitconfig for child git invocations.
# Activation sandbox lacks ssh on PATH; user's insteadOf rewrites
# https://github.com/ → git@github.com: and breaks every clone here.
# Pointing these at /dev/null makes git skip both files entirely.
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_SYSTEM=/dev/null
export GIT_TERMINAL_PROMPT=0

log() { printf "[%s] codex-setup: %s\n" "$(date +%H:%M:%S)" "$*"; }
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

command -v codex >/dev/null 2>&1 || { log "codex CLI missing, skipping"; exit 0; }
command -v npx   >/dev/null 2>&1 || { log "npx missing, skipping"; exit 0; }

log "start"

# ─── Caveman skills for Codex ──────────────────────────────────────────────
# Direct `skills add` invocation, bypassing caveman's `install.sh` wrapper.
# Wrapper omits `-y` on the inner `skills add` call → may prompt and hang on
# fresh invocations. Direct call adds `-y --copy -g` and closes stdin via
# `</dev/null`. 60s timeout caps worst case. `-a codex` targets only codex.
# Skills land in ~/.agents/skills/ (open agent skills ecosystem).
step "skills add caveman -a codex" \
  bash -c "cd \"\$HOME\" && timeout 60 npx -y skills@latest add JuliusBrussee/caveman -a codex -y --copy -g </dev/null"

# ─── MCP servers (codex mcp add idempotent — errors on dup, swallowed) ────
mcp_has() { codex mcp list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$1"; }

if mcp_has "context7"; then
  log "skip context7: already present"
else
  step "codex mcp add context7" \
    codex mcp add context7 -- npx -y @upstash/context7-mcp
fi

# anytype needs OPENAPI_MCP_HEADERS bearer token — only add when env present.
if [ -n "${ANYTYPE_MCP_HEADERS:-}" ]; then
  if mcp_has "anytype"; then
    log "skip anytype: already present"
  else
    step "codex mcp add anytype" \
      codex mcp add anytype --env "OPENAPI_MCP_HEADERS=${ANYTYPE_MCP_HEADERS}" -- pnpx @anyproto/anytype-mcp
  fi
else
  log "skip anytype: ANYTYPE_MCP_HEADERS env not set"
fi

# ─── Plugin enables (config.toml-only, no CLI verb) ───────────────────────
# Codex has no `plugin enable` command — flips live in ~/.codex/config.toml
# as `[plugins."NAME@MKT"] enabled = true`. Either enable via /plugin in TUI
# once per machine, or extend this script with a TOML-aware mutator
# (dasel/tomlq) once the list stabilises.

log "done"
