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

rsync -av --delete "$REPO_ROOT/command/atk/" "$TARGET_DIR/command/atk/"
rsync -av --delete "$REPO_ROOT/skill/atk/" "$TARGET_DIR/skill/atk/"
rsync -av --delete "$REPO_ROOT/skill/atk2/" "$TARGET_DIR/skill/atk2/"
