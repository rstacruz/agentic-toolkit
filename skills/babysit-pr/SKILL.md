---
name: babysit-pr
description: Use when the user asks to monitor, watch, or babysit a PR until CI passes or requires intervention. Polls CI status, delegates failure log analysis to a subagent, auto-fixes branch-related issues, and stops when the PR is green or blocked.
---

# babysit-pr

Monitor a PR's CI status in a loop. Delegate log analysis to a subagent to keep the main context lean. Fix branch-related failures and push. Stop when CI passes or a blocker requires user input.

## Inputs

Accept any of:
- No argument — auto-detect PR from current branch
- PR number
- PR URL

## Setup

Find the directory containing this SKILL.md at runtime — that is `SKILL_DIR`. The polling script lives at `$SKILL_DIR/scripts/poll-pr.sh`.

Run it as:
```bash
bash "$SKILL_DIR/scripts/poll-pr.sh" [<pr-number-or-url>]
```

Requires `gh` (≥ 2.32) and `jq`.

After finding the PR, request a Copilot review using the GraphQL API (works for both initial requests and re-requests after pushes):
```bash
PR_NODE_ID=$(gh pr view <PR> --json id -q .id)
gh api graphql -f query='mutation { requestReviews(input: { pullRequestId: "'"$PR_NODE_ID"'", botIds: ["BOT_kgDOCnlnWA"] }) { pullRequest { id } } }'
```
`BOT_kgDOCnlnWA` is the stable node ID for `copilot-pull-request-reviewer`. The `gh pr edit --add-reviewer @copilot` REST path does not support re-requests.

## Main loop

```
LOOP:
  snapshot = poll-pr.sh [<pr>]

  status=merged  → "PR #<n> merged." — STOP
  status=closed  → "PR #<n> closed without merging." — STOP
  status=passing →
    Proceed to REVIEW-WAIT phase (see below)

  status=pending →
    unchanged_count += 1
    interval = min(60 × 2^(floor(unchanged_count / 3)), 300) seconds
    wait interval, loop

  status=failing →
    unchanged_count = 0
    Spawn ONE subagent with ALL failing_run_ids:
      """
      Analyse CI failures for PR #{{PR_NUM}}.
      For each run ID in {{FAILING_RUN_IDS}}, run:
        gh run view <id> --log-failed
      Classify the overall failure set as branch-related OR flaky/infra.
      - Branch-related: compile errors, test failures, lint violations,
        type errors in files touched by this branch.
      - Flaky/infra: network timeouts, runner provisioning failures,
        GitHub Actions outages, rate limits.
      If branch-related: describe exactly what to fix and in which file(s).
      If flaky: confirm no changed code is implicated.
      """

    Read classification:
      branch-related →
        Check worktree: if unrelated uncommitted changes exist → STOP, ask user
        Fix the code
        git add, commit, and push
        If push rejected (non-fast-forward, protected branch, etc.) → STOP, report
        Re-request Copilot review (GraphQL mutation, same as Setup)
        unchanged_count = 0, loop

      flaky/infra →
        For each failing run_id:
          retry_count[run_id] += 1
          if retry_count[run_id] > 3 → STOP, "Flaky retry budget exhausted: <workflow_name>"
        gh run rerun <run-id> --failed  (for each failing run)
        loop
```

## Review-wait phase

After CI goes green, poll for review feedback for up to 10 minutes.

```
REVIEW-WAIT:
  deadline = now + 600s
  poll_interval = 30s

  LOOP until deadline:
    reviews = gh pr view <PR> --json reviews
    
    new_reviews = reviews where state in [CHANGES_REQUESTED, COMMENTED]
                  AND not already triaged this session
    
    if new_reviews → proceed to REVIEW-TRIAGE
    
    wait poll_interval, loop

  if timeout → "CI green. No review feedback received in 10m. PR #<n> ready to merge." — STOP
```

## Review-triage phase

Spawn ONE subagent with the full review payload:

```
Triage review comments for PR #{{PR_NUM}}.

Fetch inline comments for each review:
  gh api repos/{{OWNER}}/{{REPO}}/pulls/{{PR_NUM}}/reviews/{{REVIEW_ID}}/comments

For each comment, classify:
  APPLY   — clear, actionable code fix that is correct and in-scope
  REPLY   — subjective, out-of-scope, already handled, or requires explanation

Return a structured list:
  [{review_id, comment_id, reviewer, file, line, body, classification, suggested_fix_or_reply}]
```

Act on results in order:

- **APPLY items:**
  - Edit the file as suggested
  - `git add`, commit, push
  - Reply to the comment via `gh api` POST: `"Applied in <commit-sha>."`
  - After all APPLY items are pushed → `unchanged_count = 0`, loop back to MAIN LOOP

- **REPLY items:**
  - Post reply via `gh api repos/<owner>/<repo>/pulls/<PR>/comments/<comment_id>/replies` with the suggested reasoning
  - Continue to next item

After all items handled with no code changes → "CI green. Review feedback addressed. PR #<n> ready to merge." — STOP

## Git safety

- Verify no unrelated uncommitted changes before editing (`git status --short`)
- Work only on the PR head branch
- Never force-push; if `git push` is rejected, stop and report the reason
- Flaky retry budget: 3 per run ID, tracked independently

## Output cadence

- Emit a progress update only on status changes (pending → failing → pushing, etc.)
- Emit a heartbeat every 5 unchanged pending polls ("still pending, next check in Xs…")
- On stop: output a final summary — PR number, final status, commits pushed, retries used

## Stop conditions

1. `merged` or `closed`
2. CI green + review-wait timeout (10m, no feedback)
3. CI green + all review feedback addressed
4. Branch-related failure where fix attempt fails or push is rejected
5. Flaky retry budget (3) exhausted for any run
6. Unrelated uncommitted changes in worktree
7. Auth or permission failure (`gh` auth errors, push access denied)
