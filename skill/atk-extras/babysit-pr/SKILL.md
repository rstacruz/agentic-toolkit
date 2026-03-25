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
    CHANGED_FILES=$(gh pr view {{PR_NUM}} --json files --jq '.files[].path')
    Spawn ONE @general subagent with ALL failing_run_ids and CHANGED_FILES:
      """
      Analyse CI failures for PR #{{PR_NUM}}.

      Files changed by this PR:
      {{CHANGED_FILES}}

      For each run ID in {{FAILING_RUN_IDS}}, run:
        gh run view <id> --log-failed
        gh run view <id> --json jobs,workflowName,headSha,url --jq '{workflowName,headSha,url,jobs:[.jobs[]|{name,conclusion,steps:[.steps[]|select(.conclusion=="failure")|{name,conclusion}]}]}'

      Classify the overall failure set as: branch-related, flaky/infra, OR uncertain.

      CLASSIFICATION SIGNALS

      Strong branch-related signals (if any present → classify branch-related):
      - Compile, type, build, or lint errors (regardless of which file is reported — errors surface in downstream files too)
      - Stack traces or error messages referencing files from CHANGED_FILES
      - New logical assertion failures in code introduced by this PR

      Strong flaky/transient signals: transient infra errors (timeouts, connection refused, resource exhaustion, runner startup failures)

      Weak/ambiguous signals (supporting evidence only — not sufficient alone):
      - UNKNOWN STEP in logs (can be a gh CLI log-association limitation)
      - No step logs (can be a gh fetch artifact, not necessarily infra failure)
      - Test file not in CHANGED_FILES (most real regressions break untouched tests)

      DECISION RULE (conservative — bias toward caution):
        Any strong branch-related signal present?
          → branch-related: describe exactly what to fix and in which file(s)
        Strong flaky/transient signals only, no strong branch-related signals?
          → flaky/infra: confirm no changed code is implicated
        Mixed signals or ambiguous?
          → uncertain: summarise what was found and why it's unclear

      Note: gh run view --log-failed output can be lossy (truncated logs, misattributed steps).
      If evidence is insufficient for confidence, classify as uncertain.
      """

    Read classification:
      branch-related →
        Check worktree: if unrelated uncommitted changes exist → STOP, ask user
        Fix the code
        git add, commit, and push
        If push rejected or auth/permission error → STOP, report
        unchanged_count = 0, loop

      flaky/infra →
        For each failing run_id:
          retry_count[run_id] += 1
          if retry_count[run_id] > 3 → STOP, "Flaky retry budget exhausted: <workflow_name>"
        gh run rerun <run-id> --failed  (for each failing run)
        loop

      uncertain →
        STOP — report what was found and ask user to classify manually
```

## Output cadence

- Emit a progress update only on status changes (pending → failing → pushing, etc.)
- Emit a heartbeat every 5 unchanged pending polls ("still pending, next check in Xs…")
- On stop: output a final summary — PR number, final status, commits pushed, retries used
