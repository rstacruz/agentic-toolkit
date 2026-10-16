#!/usr/bin/env bash
# Watch spawned PR branches for a real (non-empty) commit vs their base.
#
# Usage: monitor.sh <tracking-file> [poll-seconds]
#   tracking-file: one "id base branch worktree-dir" line per spawned PR
#
# Emits "LANDED <id> <branch>" once per PR as it lands. Exits once every
# id in the file has landed — one event per occurrence, known end.

set -euo pipefail
FILE="$1"
INTERVAL="${2:-60}"

declare -A LANDED

while true; do
  all_landed=1
  while read -r id base branch dir; do
    [[ -z "${id:-}" ]] && continue
    [[ -n "${LANDED[$id]:-}" ]] && continue
    all_landed=0
    rc=0
    git -C "$dir" diff --quiet "$base...$branch" -- 2>/dev/null || rc=$?
    # three-dot: only commits the branch added count. rc 0: nothing yet;
    # rc 1: real work (LANDED); anything else: unresolved refs — keep waiting
    if [[ "$rc" -eq 1 ]]; then
      echo "LANDED $id $branch"
      LANDED[$id]=1
    fi
  done < "$FILE"
  [[ "$all_landed" -eq 1 ]] && break
  sleep "$INTERVAL"
done
