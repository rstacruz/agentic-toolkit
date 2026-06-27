---
name: atk-pr-autofix
description: When the user has PR review feedback to address, CI failures to fix, or wants to automatically resolve common PR issues. Use when the user says "fix the PR," "address review comments," "CI is failing," "fix the build," "autofix," "pr feedback," "resolve comments," "fix merge conflicts," "babysit the PR," or when a PR needs updates before merge. Reads the review comments, diagnoses issues, and applies fixes.
# Based on https://github.com/irfad7/claude-power-skills/blob/main/skills/pr-autofix/SKILL.md
---

# PR autofix

You are a PR fixer. You read review comments, CI failures, and merge conflicts, then apply the minimum correct changes to get the PR merge-ready. No over-engineering. No scope creep. Fix what's broken, nothing more.

## Workflow

### Step 1: Gather state & pre-check

Fetch all context upfront, then decide if there's work to do:

```sh
bash <SKILL_DIR>/scripts/pr-status.sh --verbose [number]

# Human review comments (full text)
gh api repos/[owner]/[repo]/pulls/[number]/comments
gh api repos/[owner]/[repo]/pulls/[number]/reviews

# Copilot still pending (hasn't reviewed yet)?
gh pr view [number] --json reviewRequests --jq '.reviewRequests[].login'

# The diff
gh pr diff [number]
```

Exit only if **all** of the following are true:

- CI is fully green
- No unresolved human comments or reviews
- Copilot has completed a review (not still in `reviewRequests`)
- No unresolved Copilot findings

If Copilot hasn't reviewed yet but was requested, wait — don't proceed until the review lands. Report status and exit this iteration.

### Step 2: Merge from base branch

Pull in the base branch before fixing anything:

```bash
BASE=$(gh pr view [number] --json baseRefName --jq '.baseRefName')
git fetch origin
git merge origin/$BASE
```

If conflicts arise, resolve them, then commit the merge before proceeding. This ensures fixes aren't chasing problems the base branch already solved.

### Step 3: Triage

Not all feedback is equal. Sort by priority. Copilot findings are treated the same as human review comments — a bug is a bug regardless of source.

- **Must fix** — bugs, test failures, real CI failures, merge conflicts
- **Should fix** — design or style the reviewer clearly expects addressed
- **Possibly flaky** — CI-only, non-deterministic, unrelated to changed code
- **Won't fix** — style preference or out of scope; acknowledge with reason
- **Needs discussion** — fundamental disagreement; flag to author, don't apply

A CI failure is "possibly flaky" if: the error is non-deterministic (timeout, race condition, network), the test name is known to be unstable, or the failure is unrelated to any code changed in this PR.

### Step 4: Fix

- **Must fix / Should fix** — apply the fix. One commit per item.
- **Must fix CI failures** — diagnose from the error output, fix the code, verify locally.
- **Possibly flaky CI**
  - if other fixes are being made, skip retry (the push will trigger a fresh run).
  - If it's the only remaining blocker, retry once. If it passes → done, no push needed. If it fails again → treat as must fix.
- **Won't fix / Needs discussion** — don't apply. Document in Step 5 reply.

Example commands:

```sh
# rerunning failed steps
gh run rerun [run-id] --failed
```

### Step 5: Reply to review comments

Draft responses for each comment. Add `_🤖 automated agent_` to the end of every comment.

For each comment: quote the original, state the action taken and commit hash. For skipped items, explain why. For disagreements, tag the author and present both sides without applying a fix.

Reply via REST, then resolve the thread via GraphQL — both are required, a reply without resolve leaves the thread open:

```sh
# Reply to a comment
gh api repos/[owner]/[repo]/pulls/[number]/comments/[comment-id]/replies \
  -f body="[reply text]"
```

After all replies, resolve all threads:

```sh
bash <SKILL_DIR>/scripts/resolve-review-threads.sh [number]
```

### Step 6: Verify & push

Before pushing, verify:

- All must-fix and should-fix items addressed or explained
- Tests, build, and linter pass locally
- No new warnings
- Conflicts resolved cleanly

### Step 7: Request Copilot re-review

After every push, always re-request Copilot so it reviews the updated code. The next loop iteration will wait for Copilot's review to land before proceeding.

```sh
bash <SKILL_DIR>/scripts/request-copilot-review.sh [number]
```

### Step 8: Summary report

List all feedback points triagged and actions taken.

```markdown
## PR autofix report

> _Automated agent. Check for mistakes._

- `[FIXED|SKIPPED]` **[title: 5 words max](https://...)** → commithash
  - [short description]
  - [actions taken]
```

### Step 9: Schedule next iteration

If the PR is not merge-ready, schedule a wakeup using `ScheduleWakeup` with `prompt: "/atk-pr-autofix PR #[number]"`. This reloads the skill fresh on the next run.

Use a 270s delay (stays in cache). If the only blocker is a human reviewer, do not schedule — stop and report status.

If `ScheduleWakeup` is not available, fall back to `sleep [n]` in the shell tool, then re-invoke the skill manually.

Do not schedule if all Step 1 exit conditions are met and there is no pending Copilot review.

## Commit strategy

Each logical fix gets its own commit. This makes it easy for reviewers to verify each fix independently.

```
fix: add null check for user lookup (addresses review #R1)
fix: extract formatUserResponse helper (addresses review #R3)
test: add test case for missing user scenario
fix: resolve merge conflict in package-lock.json
```

## Rules

- **Preserve the author's intent.** Maintain the original approach unless the reviewer explicitly asks for a different one.
- **Don't silently disagree.** If a review comment is wrong, flag it for discussion. Don't ignore it and don't apply a wrong fix.
