#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.config/opencode"

echo "Pushing files to ${TARGET_DIR}..."

# Check if target directory exists
if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "✗ Error: ${TARGET_DIR} does not exist"
  exit 1
fi

rsync -av --delete "$REPO_ROOT/skill/atk/" "$TARGET_DIR/skill/atk/"
rsync -av --delete "$REPO_ROOT/skill/atk-extras/" "$TARGET_DIR/skill/atk-extras/"
rsync -av --delete "$REPO_ROOT/command/atk/" "$TARGET_DIR/command/atk/"
rm -f "$TARGET_DIR/agent/general-opus.md" "$TARGET_DIR/agent/general-gpt-5-3-codex.md"
rsync -av "$REPO_ROOT/agent/" "$TARGET_DIR/agent/" --include "general-alpha.md" --include "general-beta.md" --exclude "*"
