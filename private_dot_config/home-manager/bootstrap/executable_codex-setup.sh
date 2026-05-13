#!/usr/bin/env bash
# Idempotent Codex CLI bootstrap.
# Wired into home.activation.codexSetup. Safe to re-run.
set -uo pipefail

command -v codex >/dev/null 2>&1 || { echo "codex-setup: codex CLI missing, skipping"; exit 0; }
command -v npx   >/dev/null 2>&1 || { echo "codex-setup: npx missing, skipping"; exit 0; }

# ─── Supermemory for Codex ─────────────────────────────────────────────────
# Installs ~/.codex/supermemory/, hooks in ~/.codex/hooks.json,
# enables codex_hooks feature flag, drops supermemory-* skills.
# Idempotent: re-running re-applies cleanly. Browser auth on first use.
npx -y codex-supermemory install >/dev/null 2>&1 || true

# ─── MCP servers (codex mcp add idempotent — errors on dup, swallowed) ────
mcp_has() { codex mcp list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$1"; }

# Example slot — add MCPs without secrets here:
# mcp_has "context7"      || codex mcp add context7 -- npx -y @upstash/context7-mcp >/dev/null 2>&1 || true
# mcp_has "linear"        || codex mcp add linear --url https://mcp.linear.app/mcp >/dev/null 2>&1 || true

# anytype needs OPENAPI_MCP_HEADERS bearer token — only add when env present.
if [ -n "${ANYTYPE_MCP_HEADERS:-}" ] && ! mcp_has "anytype"; then
  codex mcp add anytype --env "OPENAPI_MCP_HEADERS=${ANYTYPE_MCP_HEADERS}" -- pnpx @anyproto/anytype-mcp >/dev/null 2>&1 || true
fi

# ─── Plugin enables (config.toml-only, no CLI verb) ───────────────────────
# Codex has no `plugin enable` command — flips live in ~/.codex/config.toml
# as `[plugins."NAME@MKT"] enabled = true`. Either enable via /plugin in TUI
# once per machine, or extend this script with a TOML-aware mutator
# (dasel/tomlq) once the list stabilises.

echo "codex-setup: done"
