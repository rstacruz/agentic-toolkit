#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${HOME}/.agents/skills"
OPENCODE_AGENT_DIR="${HOME}/.config/opencode/agent"

echo "Pulling skills from ${SOURCE_DIR}..."

if [[ -d "${SOURCE_DIR}" ]]; then
  mkdir -p "$REPO_ROOT/skills"

  rm -rf \
    "$REPO_ROOT/skill/atk" \
    "$REPO_ROOT/skill/atk-extras"
  rsync -av "$SOURCE_DIR/" "$REPO_ROOT/skills/" --include "atk.*" --exclude "*"
fi

if [[ -d "${OPENCODE_AGENT_DIR}" ]]; then
  rsync -av --delete "$OPENCODE_AGENT_DIR/" "$REPO_ROOT/agent/" --include "general-alpha.md" --include "general-beta.md" --exclude "*"
fi
