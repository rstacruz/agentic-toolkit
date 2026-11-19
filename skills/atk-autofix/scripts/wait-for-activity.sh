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

get_collection() {
  gh api --paginate --slurp "repos/$REPO_NWO/$1" |
    jq -ce 'if all(.[]; type == "array") then add // [] else error("invalid response") end |
      if all(.[]; type == "object" and (.id | type == "number")) then sort_by(.id) else error("invalid item") end'
}

get_pr_state() {
  gh pr view "$PR_NUMBER" --repo "$REPO_NWO" --json reviewRequests,statusCheckRollup |
    jq -ce 'if (.reviewRequests | type) != "array" or
      (has("statusCheckRollup") | not) or
      ((.statusCheckRollup | type) != "array" and .statusCheckRollup != null) or
      (all(.reviewRequests[]; ((.login // .name) | type) == "string") | not)
      then error("invalid PR state") else . end |
      {requests: [.reviewRequests[] | .login // .name] | sort,
       checks: [(.statusCheckRollup // [])[] | {name: (.name // .context), status, conclusion, state}] | sort_by(.name, .status, .conclusion, .state)} |
      if all(.checks[]; (.name | type) == "string") then . else error("invalid check") end'
}

get_merge_queue() {
  gh api graphql \
    -f query='query($owner: String!, $repo: String!, $number: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $number) { mergeQueueEntry { state position } }
      }
    }' \
    -F owner="$OWNER" -F repo="$REPO" -F number="$PR_NUMBER" |
    jq -c 'if .errors or (.data.repository.pullRequest | type) != "object" or
      (.data.repository.pullRequest | has("mergeQueueEntry") | not) then error("invalid merge queue response")
      else .data.repository.pullRequest.mergeQueueEntry |
        if . == null or (type == "object" and (.state | type) == "string" and (.position | type) == "number")
        then . else error("invalid merge queue entry") end end'
}

capture_state() {
  reviews=$(get_collection "pulls/$PR_NUMBER/reviews") &&
    inline_comments=$(get_collection "pulls/$PR_NUMBER/comments") &&
    issue_comments=$(get_collection "issues/$PR_NUMBER/comments") &&
    pr_state=$(get_pr_state) &&
    mq=$(get_merge_queue)
}

# A failed initial snapshot must not become an empty baseline.
if ! capture_state; then
  echo "Failed to capture PR activity; GitHub data unavailable" >&2
  exit 2
fi
init_reviews=$reviews
init_inline_comments=$inline_comments
init_issue_comments=$issue_comments
init_pr_state=$pr_state
init_mq=$mq

echo "Waiting for activity on PR #$PR_NUMBER (timeout ${TIMEOUT}s, interval ${INTERVAL}s)..." >&2

elapsed=0
while [[ $elapsed -lt $TIMEOUT ]]; do
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))

  # Compare only complete snapshots; API failures are not activity.
  if ! capture_state; then
    echo "  [${elapsed}s] unable to fetch PR activity; retrying" >&2
    continue
  fi

  if [[ "$reviews" != "$init_reviews" ]]; then
    init_count=$(jq 'length' <<<"$init_reviews")
    cur_count=$(jq 'length' <<<"$reviews")
    if (( cur_count > init_count )); then
      emit_result "{\"reason\":\"new_reviews\",\"count\":$((cur_count - init_count)),\"total\":$cur_count,\"elapsed\":$elapsed}"
    fi
    emit_result "{\"reason\":\"reviews_changed\",\"elapsed\":$elapsed}"
  fi

  if [[ "$inline_comments" != "$init_inline_comments" || "$issue_comments" != "$init_issue_comments" ]]; then
    init_count=$(jq -n --argjson inline "$init_inline_comments" --argjson issue "$init_issue_comments" '$inline | length + ($issue | length)')
    cur_count=$(jq -n --argjson inline "$inline_comments" --argjson issue "$issue_comments" '$inline | length + ($issue | length)')
    if (( cur_count > init_count )); then
      emit_result "{\"reason\":\"new_comments\",\"count\":$((cur_count - init_count)),\"total\":$cur_count,\"elapsed\":$elapsed}"
    fi
    emit_result "{\"reason\":\"comments_changed\",\"elapsed\":$elapsed}"
  fi

  init_requests=$(jq -c '.requests' <<<"$init_pr_state")
  cur_requests=$(jq -c '.requests' <<<"$pr_state")
  if [[ "$init_requests" != "[]" && "$cur_requests" == "[]" ]]; then
    emit_result "$(jq -nc --argjson requests "$init_requests" --argjson elapsed "$elapsed" '{reason:"review_completed",was:($requests | join(",")),elapsed:$elapsed}')"
  fi

  init_ci=$(jq -c '.checks' <<<"$init_pr_state")
  cur_ci=$(jq -c '.checks' <<<"$pr_state")
  if [[ "$cur_ci" != "$init_ci" ]]; then
    emit_result "$(jq -nc --arg was "$init_ci" --arg now "$cur_ci" --argjson elapsed "$elapsed" '{reason:"ci_changed",was:$was,now:$now,elapsed:$elapsed}')"
  fi

  if [[ "$mq" != "$init_mq" ]]; then
    emit_result "$(jq -nc --argjson was "$init_mq" --argjson now "$mq" --argjson elapsed "$elapsed" '{reason:"merge_queue_changed",was:($was | if . == null then "" else "\(.state):\(.position)" end),now:($now | if . == null then "" else "\(.state):\(.position)" end),elapsed:$elapsed}')"
  fi

  echo "  [${elapsed}s] no activity yet" >&2
done

echo "{\"reason\":\"timeout\",\"elapsed\":$elapsed}" >&2
exit 1
