#!/usr/bin/env bash
# Usage: check-mermaid.sh <file.md>
# Extracts every ```mermaid block from a Markdown file and parses each one
# with mermaid-cli. Exits non-zero if any block fails.
set -u

[ $# -eq 1 ] || { echo "usage: $0 <file.md>" >&2; exit 2; }
[ -f "$1" ] || { echo "not a file: $1" >&2; exit 2; }

dir=$(mktemp -d "/tmp/mmd-check-$$-XXXX")
trap 'rm -rf "$dir"' EXIT

awk -v d="$dir" '
  /^[[:space:]]*```mermaid/ { n++; f = sprintf("%s/block-%02d.mmd", d, n); inb = 1; next }
  /^[[:space:]]*```/ && inb { inb = 0; next }
  inb { print > f }
' "$1"

fail=0
found=0
for f in "$dir"/*.mmd; do
  [ -e "$f" ] || break
  found=1
  if npx -y @mermaid-js/mermaid-cli@latest -i "$f" -o "${f%.mmd}.svg" >"$f.log" 2>&1; then
    echo "ok   $(basename "$f")"
  else
    echo "FAIL $(basename "$f")"
    head -20 "$f.log"
    echo "--- source"
    cat "$f"
    fail=1
  fi
done

[ "$found" -eq 1 ] || echo "no mermaid blocks"
exit "$fail"
