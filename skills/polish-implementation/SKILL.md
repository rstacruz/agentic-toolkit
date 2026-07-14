---
name: polish-implementation
description: Iterative code review loop against a GitHub PR — atk-code-review posts findings as self-review threads, this skill fixes, replies, and resolves them, up to 10 passes.
---

Run an iterative review loop on an implementation, fixing and replying to self-review threads on GitHub each pass.

This skill pushes commits and posts/resolves GitHub PR comments autonomously across passes — same posture as `atk-pr-autofix`. Invoking it is the opt-in; it won't ask before each push or comment.

## Workflow

1. **Ensure the PR is up to date.**
   - Commit any staged changes, then push: `git push` (first run on a new branch: `git push -u origin HEAD`).
   - Check for an existing PR: `gh pr view --json number -q .number 2>/dev/null`.
   - If none: `gh pr create --draft`.
   - The PR is now the change set — `atk-code-review` reviews it directly, no separate diff-scoping step needed here.

2. **Subagent review.** Spawn a subagent against the PR from step 1 and the plan (if available), using the `atk-code-review` skill. It gathers PR context, dedups against existing threads (any author), and posts a single batched self-review to the PR — returning the new thread IDs it created (empty if nothing new was found).

3. **If no new threads:** done — go to step 6 (report).

4. **Triage and fix.** For each thread ID returned by step 2:
   - Triage using `atk-pr-autofix`'s categories: must fix / should fix / won't fix / needs discussion.
   - Apply must-fix and should-fix changes — one commit per item.
   - Reply to the thread via GraphQL `addPullRequestReviewThreadReply` (takes `threadId` + `body` directly, no comment-id lookup needed): quote the finding, state the action taken and commit hash (or the reason for not fixing).
   - Resolve fixed and won't-fix threads:
     `bash <SKILL_DIR>/scripts/resolve-review-threads.sh [number] --thread-id <id>[,<id>...]`
   - Leave "needs discussion" threads open — that's a signal for the human reviewer, not something to resolve automatically.
   - Never touch a thread not returned by step 2 — those belong to a human or Copilot, and are `atk-pr-autofix`'s job to handle later.

5. **Push**, then return to step 2. Repeat up to 10 passes.

6. Report.

Notes:

- If using Claude Code: use *general-purpose* subagent with model=Opus
- If *oracle* type is available: for Agent tool, use subagent_type=oracle max_turns=35

Reporting:

- Summarise fixes applied and threads left open for discussion (link them).
- If the pass cap (10) was hit and new threads were still appearing, recommend another `$polish-implementation` run — there may be more to find.
