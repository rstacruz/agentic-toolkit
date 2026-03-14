#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${HOME}/.config/opencode"

echo "Pulling files from ${SOURCE_DIR}..."

# Check if source directory exists
if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "✗ Error: ${SOURCE_DIR} does not exist"
  exit 1
fi

rsync -av --delete "$SOURCE_DIR/skill/atk/" "$REPO_ROOT/skill/atk/"
rsync -av --delete "$SOURCE_DIR/skill/atk-extras/" "$REPO_ROOT/skill/atk-extras/"
mkdir -p "$REPO_ROOT/command/atk"
if [[ -d "$SOURCE_DIR/command/atk" ]]; then
  rsync -av --delete "$SOURCE_DIR/command/atk/" "$REPO_ROOT/command/atk/"
else
  echo "Note: $SOURCE_DIR/command/atk not found, skipping (run push.sh first)"
fi
rm -f "$REPO_ROOT/agent/general-opus.md" "$REPO_ROOT/agent/general-gpt-5-3-codex.md"
rsync -av "$SOURCE_DIR/agent/" "$REPO_ROOT/agent/" --include "general-alpha.md" --include "general-beta.md" --exclude "*"
