#!/usr/bin/env bash
# poll-pr.sh — Snapshot PR CI status and return structured JSON
#
# Usage:
#   ./poll-pr.sh               # auto-detect PR from current branch
#   ./poll-pr.sh <pr-number>   # explicit PR number
#   ./poll-pr.sh <pr-url>      # explicit PR URL
#
# Output: JSON object with keys:
#   status          — "pending" | "failing" | "passing" | "merged" | "closed"
#   number          — PR number
#   title           — PR title
#   headRefName     — branch name
#   mergeable       — "MERGEABLE" | "CONFLICTING" | "UNKNOWN"
#   mergeStateStatus — GitHub merge state (BLOCKED, CLEAN, etc.)
#   failing_run_ids — array of databaseIds for failed workflow runs
#   failing_runs    — array of {databaseId, workflowName, url} for failed runs
#   checks          — raw array from gh pr checks
#
# Requires: gh (>= 2.32), jq

set -euo pipefail

PR_ARG="${1:-}"

# ── 1. PR details ─────────────────────────────────────────────────────────────
if [[ -n "$PR_ARG" ]]; then
  PR_JSON=$(gh pr view "$PR_ARG" --json number,title,url,headRefName,state,mergeable,mergeStateStatus)
else
  PR_JSON=$(gh pr view --json number,title,url,headRefName,state,mergeable,mergeStateStatus)
fi

PR_STATE=$(echo "$PR_JSON" | jq -r '.state')
BRANCH=$(echo "$PR_JSON"   | jq -r '.headRefName')

# ── 2. Terminal PR states ──────────────────────────────────────────────────────
if [[ "$PR_STATE" == "MERGED" ]]; then
  echo "$PR_JSON" | jq '. + {status: "merged", failing_run_ids: [], failing_runs: [], checks: []}'
  exit 0
fi

if [[ "$PR_STATE" == "CLOSED" ]]; then
  echo "$PR_JSON" | jq '. + {status: "closed", failing_run_ids: [], failing_runs: [], checks: []}'
  exit 0
fi

# ── 3. Check statuses (gh pr checks --json, state is uppercase) ───────────────
# Available fields: bucket, completedAt, description, event, link, name, startedAt, state, workflow
CHECKS_JSON=$(gh pr checks --json name,state,bucket,link,workflow 2>/dev/null || echo "[]")

# ── 4. Compute overall CI status ──────────────────────────────────────────────
# Terminal failure states from gh pr checks: FAILURE, ERROR, TIMED_OUT, CANCELLED, ACTION_REQUIRED
# Pending states: PENDING, IN_PROGRESS, QUEUED, REQUESTED, WAITING
# Success states: SUCCESS, NEUTRAL, SKIPPED
FAILING_COUNT=$(echo "$CHECKS_JSON" | jq \
  '[.[] | select(.state == "FAILURE" or .state == "ERROR" or .state == "TIMED_OUT" or .state == "CANCELLED" or .state == "ACTION_REQUIRED")] | length')

PENDING_COUNT=$(echo "$CHECKS_JSON" | jq \
  '[.[] | select(.state == "PENDING" or .state == "IN_PROGRESS" or .state == "QUEUED" or .state == "REQUESTED" or .state == "WAITING")] | length')

if [[ "$FAILING_COUNT" -gt 0 ]]; then
  STATUS="failing"
elif [[ "$PENDING_COUNT" -gt 0 ]]; then
  STATUS="pending"
else
  STATUS="passing"
fi

# ── 5 & 6. Failing workflow run IDs (conclusion is lowercase in gh run list) ──
# Cross-reference with currently-failing check names so we don't return stale
# run IDs for workflows that have since been retried and passed.
FAILING_CHECK_NAMES=$(echo "$CHECKS_JSON" | jq \
  '[.[] | select(.state == "FAILURE" or .state == "ERROR" or .state == "TIMED_OUT" or .state == "CANCELLED" or .state == "ACTION_REQUIRED") | .name]')

RUNS_JSON=$(gh run list --branch "$BRANCH" --limit 40 \
  --json databaseId,name,workflowName,conclusion,status,url,displayTitle 2>/dev/null || echo "[]")

# Keep only runs that (a) failed AND (b) whose workflowName is still failing per gh pr checks.
# Deduplicate: take only the first (most recent) run per workflowName.
FAILING_RUNS=$(echo "$RUNS_JSON" | jq \
  --argjson names "$FAILING_CHECK_NAMES" \
  '[ .[] | select(
       (.conclusion == "failure" or .conclusion == "startup_failure" or .conclusion == "timed_out") and
       (.workflowName as $wn | $names | index($wn) != null)
     )
  ] |
  reduce .[] as $r (
    {"seen": [], "result": []};
    if (.seen | index($r.workflowName)) == null
    then {"seen": (.seen + [$r.workflowName]), "result": (.result + [$r])}
    else .
    end
  ) | .result | .[0:5]')

FAILING_RUN_IDS=$(echo "$FAILING_RUNS" | jq '[.[].databaseId]')

# ── 7. Compose output ─────────────────────────────────────────────────────────
echo "$PR_JSON" | jq \
  --arg      status          "$STATUS"        \
  --argjson  failing_run_ids "$FAILING_RUN_IDS" \
  --argjson  failing_runs    "$FAILING_RUNS"  \
  --argjson  checks          "$CHECKS_JSON"   \
  '. + {
    status:          $status,
    failing_run_ids: $failing_run_ids,
    failing_runs:    $failing_runs,
    checks:          $checks
  }'
