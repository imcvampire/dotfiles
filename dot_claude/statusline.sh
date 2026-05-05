#!/usr/bin/env bash
# Claude Code status line script
# Receives JSON on stdin from Claude Code

input=$(cat)

# --- Fields from JSON ---
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- Shorten cwd: replace $HOME with ~ ---
home="$HOME"
cwd_display="${cwd/#$home/\~}"

# --- Git branch (skip optional locks, operate in session cwd) ---
branch=$(GIT_OPTIONAL_LOCKS=0 git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# --- Build output ---
# Segment colors (will be dimmed by the terminal):
#   cyan  = user@host
#   blue  = directory
#   green = git branch
#   yellow= model
#   red   = context

printf ' \033[34m%s\033[0m' "$cwd_display"

if [ -n "$branch" ]; then
  printf ' \033[32m(%s)\033[0m' "$branch"
fi

printf ' \033[33m[%s]\033[0m' "$model"

if [ -n "$remaining" ]; then
  printf ' \033[31m%.0f%% ctx\033[0m' "$remaining"
fi

printf '\n'
