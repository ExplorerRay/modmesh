#!/bin/bash
# .claude/statusline.sh
#
# Status line for Claude Code. Reads the session JSON on stdin and
# prints a single line with model, project name, branch (with `*`
# if dirty), and (if available) context-window usage percentage.
# Falls back gracefully if `jq` is not installed.

input=$(cat)

if command -v jq >/dev/null 2>&1; then
    model=$(printf '%s' "$input" | jq -r '.model.display_name // "?"')
    dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // ""')
    pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
else
    model="?"
    dir=""
    pct=""
fi

[ -z "$dir" ] && dir="$PWD"
proj=$(basename "$dir")
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo no-branch)
dirty=""
if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    dirty="*"
fi

if [ -n "$pct" ]; then
    printf '%s | %s | %s%s | ctx %s%%' "$model" "$proj" "$branch" "$dirty" "$pct"
else
    printf '%s | %s | %s%s' "$model" "$proj" "$branch" "$dirty"
fi
