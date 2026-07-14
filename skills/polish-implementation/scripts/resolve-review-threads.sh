#!/usr/bin/env bash
# Resolves review threads for a PR.
# Usage: resolve-review-threads.sh [pr-number] [--thread-id ID[,ID...]]
#
# No --thread-id: resolves all unresolved threads (default; used by atk-pr-autofix).
# --thread-id set: resolves only the given thread ID(s), regardless of current
#   resolved state — used by polish-implementation to scope resolution to the
#   specific self-review threads it just handled, leaving any other (human/
#   Copilot) threads untouched.

set -euo pipefail

PR_NUMBER=""
THREAD_ID_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --thread-id) [[ $# -ge 2 ]] || { echo "Error: --thread-id requires a value" >&2; exit 1; }
      THREAD_ID_ARG="$2"; shift ;;
    -*) echo "Error: unknown option '$1'" >&2; exit 1 ;;
    *) PR_NUMBER="$1" ;;
  esac
  shift
done
PR_NUMBER="${PR_NUMBER:-$(gh pr view --json number -q .number 2>/dev/null)}"

if [[ -z "$PR_NUMBER" ]]; then
  echo "Error: could not infer PR number. Pass it explicitly." >&2
  exit 1
fi

REPO_NWO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
OWNER="${REPO_NWO%/*}"
REPO="${REPO_NWO#*/}"

THREAD_IDS=()
if [[ -n "$THREAD_ID_ARG" ]]; then
  IFS=',' read -r -a THREAD_IDS <<< "$THREAD_ID_ARG"
else

  while IFS= read -r id; do
    THREAD_IDS+=("$id")
  done < <(
    gh api graphql \
      -f query='query($owner: String!, $repo: String!, $number: Int!) {
        repository(owner: $owner, name: $repo) {
          pullRequest(number: $number) {
            reviewThreads(first: 100) {
              nodes { id isResolved }
            }
          }
        }
      }' \
      -F owner="$OWNER" -F repo="$REPO" -F number="$PR_NUMBER" \
      --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | .id'
  )
fi

if [[ ${#THREAD_IDS[@]} -eq 0 ]]; then
  echo "No unresolved threads for PR #$PR_NUMBER"
  exit 0
fi

for id in "${THREAD_IDS[@]}"; do
  gh api graphql \
    -f query='mutation($threadId: ID!) {
      resolveReviewThread(input: { threadId: $threadId }) {
        thread { id isResolved }
      }
    }' \
    -F threadId="$id" >/dev/null
done

echo "Resolved ${#THREAD_IDS[@]} thread(s) for PR #$PR_NUMBER"
