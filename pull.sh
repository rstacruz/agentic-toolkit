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

if [[ ! -d "${SOURCE_DIR}/skills" ]]; then
  echo "✗ Error: ${SOURCE_DIR}/skills does not exist"
  echo "Run the migrated ./push.sh first to install the new skills layout."
  exit 1
fi

mkdir -p "$REPO_ROOT/skills"

rm -rf \
  "$REPO_ROOT/skill/atk" \
  "$REPO_ROOT/skill/atk-extras" \
  "$REPO_ROOT/command/atk-extras"

rsync -av --delete "$SOURCE_DIR/skills/" "$REPO_ROOT/skills/"
rsync -av --delete "$SOURCE_DIR/agent/" "$REPO_ROOT/agent/" --include "general-alpha.md" --include "general-beta.md" --exclude "*"
