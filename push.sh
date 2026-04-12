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

# Ensure required subdirectories exist before syncing
mkdir -p \
  "${TARGET_DIR}/skills" \
  "${TARGET_DIR}/agent"

rm -rf \
  "${TARGET_DIR}/skill/atk" \
  "${TARGET_DIR}/skill/atk-extras" \
  "${TARGET_DIR}/command/atk-extras"

rsync -av --delete "$REPO_ROOT/skills/" "$TARGET_DIR/skills/"

# Don't --delete here to not overwrite user's custom agents
rsync -av "$REPO_ROOT/agent/" "$TARGET_DIR/agent/" --include "general-alpha.md" --include "general-beta.md" --exclude "*"
