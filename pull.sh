#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${HOME}/.config/opencode"

# Directories to scan
SYNC_DIRS=("agent" "command" "skills")

echo "Pulling files from ${SOURCE_DIR}..."

# Check if source directory exists
if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "✗ Error: ${SOURCE_DIR} does not exist"
  exit 1
fi

file_count=0

# Sync each directory
for dir in "${SYNC_DIRS[@]}"; do
  if [[ ! -d "${REPO_ROOT}/${dir}" ]]; then
    echo "  ⚠ Skipping ${dir}/ (not in repository)"
    continue
  fi
  
  echo "  ← Checking ${dir}/"
  
  # Find all files in repo for this directory (relative paths)
  while IFS= read -r -d '' repo_file; do
    # Get relative path from the directory
    rel_path="${repo_file#${REPO_ROOT}/${dir}/}"
    source_file="${SOURCE_DIR}/${dir}/${rel_path}"
    
    # Dereference if it's a symlink
    if [[ -L "${source_file}" ]] && [[ -e "${source_file}" ]]; then
      source_file="$(readlink -f "${source_file}")"
    fi
    
    if [[ -f "${source_file}" ]]; then
      echo "    ${rel_path}"
      cp "${source_file}" "${repo_file}"
      file_count=$((file_count + 1))
    else
      echo "    ⚠ ${rel_path} (not found in config)"
    fi
  done < <(find "${REPO_ROOT}/${dir}" -type f -print0)
done

echo "✓ Pull complete (${file_count} files)"
