#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.config/opencode"

# Directories to sync
SYNC_DIRS=("agent" "command" "skill")

echo "Pushing files to ${TARGET_DIR}..."

# Create target directory if needed
mkdir -p "${TARGET_DIR}"

# Sync each directory
for dir in "${SYNC_DIRS[@]}"; do
  if [[ -d "${REPO_ROOT}/${dir}" ]]; then
    echo "  → Syncing ${dir}/"
    mkdir -p "${TARGET_DIR}/${dir}"
    # Check if directory has files before copying
    if compgen -G "${REPO_ROOT}/${dir}/*" >/dev/null; then
      cp -r "${REPO_ROOT}/${dir}"/* "${TARGET_DIR}/${dir}/"
    fi
  else
    echo "  ⚠ Warning: ${dir}/ not found in repository"
  fi
done

echo "✓ Push complete"
