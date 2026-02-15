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
rsync -av "$REPO_ROOT/agent/" "$TARGET_DIR/agent/" --include "general-opus.md" --include "general-gpt-5-3-codex.md" --exclude "*"
