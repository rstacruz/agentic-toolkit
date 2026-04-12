#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.agents/skills"
OPENCODE_AGENT_DIR="${HOME}/.config/opencode/agent"

echo "Pushing skills to ${TARGET_DIR}..."
mkdir -p "$TARGET_DIR"
rm -rf "${TARGET_DIR}/atk.*"
rsync -av "$REPO_ROOT/skills/" "$TARGET_DIR/" 

echo "Pushing agents to ${OPENCODE_AGENT_DIR}"
mkdir -p "$OPENCODE_AGENT_DIR"
rsync -av "$REPO_ROOT/agent/" "$OPENCODE_AGENT_DIR" --include "general-alpha.md" --include "general-beta.md" --exclude "*"
