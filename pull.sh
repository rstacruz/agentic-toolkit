#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${HOME}/.agents/skills"
OPENCODE_AGENT_DIR="${HOME}/.config/opencode/agent"

echo "Pulling skills from ${SOURCE_DIR}..."

# Check if source directory exists
if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "✗ Error: ${SOURCE_DIR} does not exist"
  exit 1
fi

if [[ ! -d "${OPENCODE_AGENT_DIR}" ]]; then
  echo "✗ Error: ${OPENCODE_AGENT_DIR} does not exist"
  exit 1
fi

mkdir -p "$REPO_ROOT/skills"

rm -rf \
  "$REPO_ROOT/skill/atk" \
  "$REPO_ROOT/skill/atk-extras" \
  "$REPO_ROOT/command/atk-extras"

rsync -av "$SOURCE_DIR/" "$REPO_ROOT/skills/" --include "atk.*" --exclude "*"
rsync -av --delete "$OPENCODE_AGENT_DIR/" "$REPO_ROOT/agent/" --include "general-alpha.md" --include "general-beta.md" --exclude "*"
