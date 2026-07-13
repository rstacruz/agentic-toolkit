#!/usr/bin/env bash
set -euo pipefail

# Poll a PR until new activity (comments, reviews, CI, or merge queue changes) is detected.
#
# Usage: wait-for-activity.sh [pr-number] [options]
#
# Options:
#   --timeout SECONDS   Max wait time (default: 600)
#   --interval SECONDS  Poll interval (default: 60)
#
# Exit codes:
#   0 — activity detected (prints JSON summary)
#   1 — timeout
#   2 — usage/error

PR_NUMBER=""
TIMEOUT=600
INTERVAL=60

while [[ $# -gt 0 ]]; do
  case "$1" in
    --timeout)  TIMEOUT="$2"; shift 2 ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    -h|--help)  head -15 "$0"; exit 0 ;;
    *) PR_NUMBER="$1"; shift ;;
  esac
done

if [[ -z "$PR_NUMBER" ]]; then
  echo "Usage: wait-for-activity.sh <pr-number> [--timeout SECONDS] [--interval SECONDS]" >&2
  exit 2
fi

REPO_NWO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
OWNER="${REPO_NWO%/*}"
REPO="${REPO_NWO#*/}"

emit_result() {
  echo >&2
  echo "$1"
  exit 0
}

get_merge_queue() {
  gh api graphql \
    -f query='query($owner: String!, $repo: String!, $number: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $number) { mergeQueueEntry { state position } }
      }
    }' \
    -F owner="$OWNER" -F repo="$REPO" -F number="$PR_NUMBER" \
    --jq '.data.repository.pullRequest.mergeQueueEntry | if . == null then "" else "\(.state):\(.position)" end' \
    2>/dev/null || echo ""
}

# --- Capture initial state ---

init_comments=$(gh api "repos/$REPO_NWO/pulls/$PR_NUMBER/comments" --jq 'length' 2>/dev/null || echo 0)
init_reviews=$(gh api "repos/$REPO_NWO/pulls/$PR_NUMBER/reviews" --jq 'length' 2>/dev/null || echo 0)
init_review_requests=$(gh pr view "$PR_NUMBER" --repo "$REPO_NWO" --json reviewRequests --jq '[.reviewRequests[].login] | join(",")' 2>/dev/null || echo "")
init_ci=$(gh pr checks "$PR_NUMBER" --repo "$REPO_NWO" 2>/dev/null | awk -F'\t' '{print $2}' | sort | tr '\n' ',' || echo "")
init_mq=$(get_merge_queue)

echo "Waiting for activity on PR #$PR_NUMBER (timeout ${TIMEOUT}s, interval ${INTERVAL}s)..." >&2

elapsed=0
while [[ $elapsed -lt $TIMEOUT ]]; do
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))

  # --- Check new reviews (Copilot finishes even without comments) ---
  cur_reviews=$(gh api "repos/$REPO_NWO/pulls/$PR_NUMBER/reviews" --jq 'length' 2>/dev/null || echo "$init_reviews")
  if [[ "$cur_reviews" -gt "$init_reviews" ]]; then
    new_count=$((cur_reviews - init_reviews))
    emit_result "{\"reason\":\"new_reviews\",\"count\":$new_count,\"total\":$cur_reviews,\"elapsed\":$elapsed}"
  fi

  # --- Check new comments ---
  cur_comments=$(gh api "repos/$REPO_NWO/pulls/$PR_NUMBER/comments" --jq 'length' 2>/dev/null || echo "$init_comments")
  if [[ "$cur_comments" -gt "$init_comments" ]]; then
    new_count=$((cur_comments - init_comments))
    emit_result "{\"reason\":\"new_comments\",\"count\":$new_count,\"total\":$cur_comments,\"elapsed\":$elapsed}"
  fi

  # --- Check review requests cleared ---
  cur_review_requests=$(gh pr view "$PR_NUMBER" --repo "$REPO_NWO" --json reviewRequests --jq '[.reviewRequests[].login] | join(",")' 2>/dev/null || echo "")
  if [[ -n "$init_review_requests" && -z "$cur_review_requests" ]]; then
    emit_result "{\"reason\":\"review_completed\",\"was\":\"$init_review_requests\",\"elapsed\":$elapsed}"
  fi

  # --- Check CI changes ---
  cur_ci=$(gh pr checks "$PR_NUMBER" --repo "$REPO_NWO" 2>/dev/null | awk -F'\t' '{print $2}' | sort | tr '\n' ',' || echo "")
  if [[ "$cur_ci" != "$init_ci" ]]; then
    emit_result "{\"reason\":\"ci_changed\",\"was\":\"$init_ci\",\"now\":\"$cur_ci\",\"elapsed\":$elapsed}"
  fi

  # --- Check merge queue changes (entered, left, or state change) ---
  cur_mq=$(get_merge_queue)
  if [[ "$cur_mq" != "$init_mq" ]]; then
    emit_result "{\"reason\":\"merge_queue_changed\",\"was\":\"$init_mq\",\"now\":\"$cur_mq\",\"elapsed\":$elapsed}"
  fi

  echo "  [${elapsed}s] no activity yet" >&2
done

echo "{\"reason\":\"timeout\",\"elapsed\":$elapsed}" >&2
exit 1
