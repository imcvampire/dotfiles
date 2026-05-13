# Bootstrap

Idempotent installers for Claude Code and Codex CLI state that lives outside Nix
(plugins, MCP servers, hooks, skills). Wired into home-manager activation via
`home.activation.{claudeSetup,codexSetup}` — runs after every `darwin-rebuild switch`.

Nix manages the binaries (`programs.claude-code.enable`, `programs.codex.enable`,
`rtk`, `nodejs`). These scripts manage everything in `~/.claude/` and `~/.codex/`
that the CLIs themselves write at runtime.

## Manual steps on a new machine

The scripts cannot automate anything that requires browser auth, interactive
trust prompts, or secret material. Run these once after first `darwin-rebuild switch`:

### Codex / ChatGPT

1. **Log in to ChatGPT**

   ```bash
   codex login
   ```

   Opens browser for OAuth. Stores token in `~/.codex/auth.json`. Verify with
   `codex login status`.

2. **Trust hook signatures**

   On first run of `codex`, you'll be prompted to trust the entries in
   `~/.codex/hooks.json` (supermemory + agents-status). Accept each — the
   `[hooks.state.*]` blocks in `~/.codex/config.toml` pin a SHA-256 hash so the
   prompt does not repeat. Re-prompts on every hook file edit.

3. **Authenticate Supermemory**

   First prompt of first session triggers the supermemory `UserPromptSubmit`
   hook. Browser opens to `https://console.supermemory.ai/auth/agent-connect`.
   Approve. API key lands in `~/.codex/supermemory/credentials.json`. Or run
   the skill explicitly: `/supermemory-login` inside Codex TUI.

4. **Enable plugins (no CLI verb exists)**

   In Codex TUI run `/plugin` and toggle on the wanted entries. Persists to
   `~/.codex/config.toml` as `[plugins."NAME@MARKETPLACE"] enabled = true`.
   Current set on this machine:

   - `documents@openai-primary-runtime`
   - `spreadsheets@openai-primary-runtime`
   - `presentations@openai-primary-runtime`
   - `latex-tectonic@openai-bundled`
   - `browser-use@openai-bundled`
   - `alpaca@openai-curated`
   - `codex-security@openai-curated`
   - `binance@openai-curated`
   - `github@openai-curated`

5. **Per-plugin service auth**

   Curated plugins that hit external services require their own logins:

   - `alpaca` — Alpaca API key + secret (paper/live trading)
   - `binance` — Binance API key
   - `github` — `gh auth login` or codex prompt
   - `codex-security` — n/a

6. **Project trust levels**

   On first `codex` invocation inside a new project dir, codex asks whether the
   dir is trusted. Accepted dirs land in `~/.codex/config.toml` as
   `[projects."/path"] trust_level = "trusted"`.

7. **Anytype MCP (optional, has secret)**

   The current machine's `~/.codex/config.toml` has anytype with a hardcoded
   bearer token. Bootstrap script skips it. To restore, either:

   - Set env var `ANYTYPE_MCP_HEADERS` and re-run `codex-setup.sh`, or
   - Manually: `codex mcp add anytype --env "OPENAPI_MCP_HEADERS=..." -- pnpx @anyproto/anytype-mcp`

### Claude Code

1. **Log in**

   ```bash
   claude login
   ```

   OAuth flow. Or set `ANTHROPIC_API_KEY` in shell.

2. **Authenticate Supermemory MCP**

   `mcp-remote` bridge opens browser on first tool call to `supermemory.*`.
   Approve. Token cached under `~/.mcp-auth/` (mcp-remote's own store).

## Notes

### Caveman skills

Caveman skills (`/caveman`, `/cavecrew`, `/caveman-commit`, etc.) come bundled
inside the plugin at `~/.claude/plugins/cache/caveman/caveman/*/skills/` and
load automatically once the plugin is enabled — no separate install step.

`claude-setup.sh` runs `caveman/install.sh --only claude` from `$HOME`:

- `--only claude` constrains the installer to the claude profile. Without it,
  caveman auto-detects every agent framework reachable from cwd (junie, cursor,
  windsurf, copilot, etc.) and writes per-repo skill dirs into `$PWD`, polluting
  whichever directory `darwin-rebuild switch` runs from.
- `cd $HOME` prevents the working-dir-based detection from picking up unrelated
  agents that might live in the current project.

## Files

| File | Purpose |
|------|---------|
| `claude-setup.sh` | Marketplaces, plugins, caveman hooks, supermemory MCP for Claude Code |
| `codex-setup.sh`  | `npx codex-supermemory install` + env-gated MCPs for Codex |

Both safe to re-run. Both no-op when state already correct.
