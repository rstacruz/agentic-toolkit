#!/usr/bin/env bash
# Resolves all unresolved review threads for a PR.
# Usage: resolve-review-threads.sh [pr-number]

set -euo pipefail

PR_NUMBER="${1:-$(gh pr view --json number -q .number 2>/dev/null)}"

if [[ -z "$PR_NUMBER" ]]; then
  echo "Error: could not infer PR number. Pass it explicitly." >&2
  exit 1
fi

REPO_NWO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
OWNER="${REPO_NWO%/*}"
REPO="${REPO_NWO#*/}"

THREAD_IDS=()
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
