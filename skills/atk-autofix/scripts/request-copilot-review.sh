#!/usr/bin/env bash
# Requests (or re-requests) a Copilot review for a PR.
# Usage: request-copilot-review.sh [pr-number]
# Note: gh pr edit --add-reviewer does not support re-requests; GraphQL does.

set -euo pipefail

PR="${1:-$(gh pr view --json number -q .number 2>/dev/null)}"

if [[ -z "$PR" ]]; then
  echo "Error: could not infer PR number. Pass it explicitly." >&2
  exit 1
fi

PR_NODE_ID=$(gh pr view "$PR" --json id -q .id)

gh api graphql -f query='mutation($prId: ID!) {
  requestReviews(input: { pullRequestId: $prId, botIds: ["BOT_kgDOCnlnWA"] }) {
    pullRequest { id }
  }
}' -F prId="$PR_NODE_ID" >/dev/null

echo "Copilot review requested for PR #$PR"
