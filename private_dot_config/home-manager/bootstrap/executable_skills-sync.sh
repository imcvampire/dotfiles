#!/usr/bin/env bash
# Fan the shared skill set (~/.agents/skills) out into each agent's own skill
# root as ONE SYMLINK PER SKILL, instead of symlinking the whole root.
#
# Why per-skill and not a whole-dir symlink:
#   - ~/.claude/skills stays a real directory, so Claude-only skills can live
#     beside the shared ones. Same for ~/.codex/skills (which also holds the
#     codex built-ins in .system/).
#   - Agent-managed writes (Claude Code drops .trash/ and synced/ into its
#     skills root) land in that agent's own dir instead of polluting the
#     shared dir.
#   - A shared skill can be overridden per agent: create a real directory of
#     the same name and the sync leaves it alone.
#
# Discovery models differ, and it matters here (both verified 2026-08-28):
#   Claude Code reads ONLY its own root (~/.claude/skills) — `claude --debug`
#     shows managed/user/project roots and there is no setting to add another.
#     It follows symlinked skill dirs. An override there is clean: the real
#     dir simply replaces the symlink.
#   Codex reads ~/.agents/skills NATIVELY, in addition to ~/.codex/skills.
#     It de-duplicates by RESOLVED PATH, not by name (`codex debug
#     prompt-input`), so the symlinks below cost nothing — each shared skill
#     is still listed once. But a codex-side override registers the name
#     TWICE, since the shared copy is a different file. The sync warns.
#
# Wired into home.activation.skillsSync and installed on PATH as
# `skills-sync`. Idempotent — safe to re-run any time you add or remove a
# shared skill.
set -uo pipefail

SHARED="${AGENTS_SKILLS:-$HOME/.agents/skills}"
TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
)

log() { printf "[%s] skills-sync: %s\n" "$(date +%H:%M:%S)" "$*"; }

# A skills root must be a real directory. Migrate the legacy whole-dir
# symlink (~/.claude/skills -> ~/.agents/skills) in place; it holds no data
# of its own, so dropping it loses nothing.
ensure_real_dir() {
  local dir="$1"
  if [ -L "$dir" ]; then
    log "  migrating legacy whole-dir symlink -> real dir ($(readlink "$dir"))"
    rm -f "$dir"
  fi
  mkdir -p "$dir"
}

# True when $1 is a symlink we own, i.e. one pointing into $SHARED.
# Anything else in the target dir is the agent's own data — never touched.
is_shared_link() {
  local dest
  [ -L "$1" ] || return 1
  dest=$(readlink "$1")
  case "$dest" in
    "$SHARED"/*) return 0 ;;
    *) return 1 ;;
  esac
}

sync_one() {
  local dir="$1"
  local src name target linked=0 shadowed=0 pruned=0

  # Does this agent ALSO read $SHARED on its own? (see header)
  local reads_shared_natively=0
  case "$dir" in
    "$HOME/.codex/skills") reads_shared_natively=1 ;;
  esac

  ensure_real_dir "$dir"

  # ─── Link every shared skill in ──────────────────────────────────────────
  if [ -d "$SHARED" ]; then
    for src in "$SHARED"/*/; do
      src="${src%/}"
      [ -d "$src" ] || continue          # no match -> literal glob
      name=$(basename "$src")
      case "$name" in .*) continue ;; esac
      # A skill is a dir with a SKILL.md. This also filters out agent
      # bookkeeping dirs (.trash/, synced/) left in the shared dir.
      [ -f "$src/SKILL.md" ] || continue

      target="$dir/$name"
      if [ -e "$target" ] && ! [ -L "$target" ]; then
        if [ "$reads_shared_natively" = 1 ]; then
          log "  WARNING: $name is a real dir here AND in $SHARED. This agent"
          log "           reads both roots, so the skill registers TWICE."
          log "           Rename the override or drop the shared copy."
        else
          log "  shadowed: $name — agent-specific version wins over shared"
        fi
        shadowed=$((shadowed + 1))
        continue
      fi
      ln -sfn "$src" "$target"
      linked=$((linked + 1))
    done
  else
    log "  note: $SHARED does not exist yet — nothing to link"
  fi

  # ─── Prune links whose shared skill is gone ──────────────────────────────
  # -d follows the link, so a dangling one (skill deleted or renamed
  # upstream) fails the test and gets removed.
  local link
  while IFS= read -r link; do
    is_shared_link "$link" || continue
    [ -d "$link" ] && continue
    log "  prune: $(basename "$link") — shared skill no longer exists"
    rm -f "$link"
    pruned=$((pruned + 1))
  done < <(find "$dir" -maxdepth 1 -type l 2>/dev/null)

  log "✓ $dir — $linked linked, $shadowed shadowed, $pruned pruned"
}

log "start (shared: $SHARED)"
for t in "${TARGETS[@]}"; do
  sync_one "$t"
done
log "done"
