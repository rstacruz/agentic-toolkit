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

mkdir -p \
  "$REPO_ROOT/command/atk" \
  "$REPO_ROOT/command/atk-extras"

rsync -av --delete "$SOURCE_DIR/command/atk/" "$REPO_ROOT/command/atk/"
rsync -av --delete "$SOURCE_DIR/command/atk-extras/" "$REPO_ROOT/command/atk-extras/"
rsync -av --delete "$SOURCE_DIR/agent/" "$REPO_ROOT/agent/" --include "general-alpha.md" --include "general-beta.md" --exclude "*"
