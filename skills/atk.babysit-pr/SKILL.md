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

## Main loop

```
LOOP:
  snapshot = poll-pr.sh [<pr>]

  status=merged  → "PR #<n> merged." — STOP
  status=closed  → "PR #<n> closed without merging." — STOP
  status=passing → "CI green. PR #<n> is ready to merge." — STOP

  status=pending →
    unchanged_count += 1
    interval = min(60 × 2^(floor(unchanged_count / 3)), 300) seconds
    wait interval, loop

  status=failing →
    unchanged_count = 0
    Spawn ONE @general-alpha subagent with ALL failing_run_ids:
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
        unchanged_count = 0, loop

      flaky/infra →
        For each failing run_id:
          retry_count[run_id] += 1
          if retry_count[run_id] > 3 → STOP, "Flaky retry budget exhausted: <workflow_name>"
        gh run rerun <run-id> --failed  (for each failing run)
        loop
```

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
2. `passing` — all checks green
3. Branch-related failure where fix attempt fails or push is rejected
4. Flaky retry budget (3) exhausted for any run
5. Unrelated uncommitted changes in worktree
6. Auth or permission failure (`gh` auth errors, push access denied)
