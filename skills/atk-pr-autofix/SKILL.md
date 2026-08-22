---
name: atk-pr-autofix
description: When the user has PR review feedback to address, CI failures to fix, or wants to automatically resolve common PR issues. Use when the user says "fix the PR," "address review comments," "CI is failing," "fix the build," "autofix," "pr feedback," "resolve comments," "fix merge conflicts," "babysit the PR," or when a PR needs updates before merge. Reads the review comments, diagnoses issues, and applies fixes.
# Based on https://github.com/irfad7/claude-power-skills/blob/main/skills/pr-autofix/SKILL.md
---

# PR autofix

You read review comments, CI failures, and merge conflicts, then apply the minimum correct changes to get the PR merge-ready — no over-engineering, no scope creep.

## Input

- `$pr` — PR number. Optional; inferred from the current branch when omitted.

## Skill dependencies

- `/atk-code-review` — companion skill: its review threads are the feedback this skill resolves

## Workflow

```pseudocode
begin($pr) {
  $fixes-applied = false

  loop {
    # step 1: gather state & pre-check
    $status = pre-check($pr)

    if ($status == 'merged' or $status == 'merge-ready') {
      break # → step 9
    } else if ($status == 'no-copilot-review') {
      # request Copilot review if not yet requested
      request-copilot-review($pr)
    } else if ($status == 'copilot-pending') {
      # report status and loop back; never fix code Copilot hasn't reviewed
    } else if ($status == 'ci-pending-only') {
      # CI pending is the only blocker; no merge, triage, or fixes
    } else {
      # step 2: merge — true if the merge changed the local branch
      $changed = merge-from-base($pr)

      # step 3: triage
      $triage = triage($pr)

      # step 4: one commit per item; accumulate across iterations
      $fixes = fix-items($pr, $triage)
      $fixes-applied ||= $fixes

      # step 5: reply all; resolve addressed/accepted threads
      reply-and-resolve($pr, $triage)

      if ($changed or $fixes) {
        # step 6: verify locally before pushing
        verify-and-push($pr)

        # step 7: after EVERY push
        request-copilot-review($pr)
      }
    }

    # step 8: wait for activity
    $wait = wait-for-activity($pr)
    if ($wait == 'timeout' or $wait == 'stop') { break }
  }

  # step 9: summary report
  # top-level PR comment; no-op if no fixes were applied
  report($pr, $fixes-applied)
  return { fixes-applied: $fixes-applied }
}
```

### Step 1: pre-check()

Run the status script; act on the first match. Returns `'merged' | 'merge-ready' | 'copilot-pending' | 'no-copilot-review' | 'ci-pending-only' | 'needs-work'`, each handled in `begin()`:

```sh
bash <SKILL_DIR>/scripts/pr-status.sh --verbose [number]
```

**Merge-ready** = CI passing, no `Changes requested` / `Review required`, zero unresolved threads (human or Copilot), Copilot `approved` or `reviewed` on the current commit (not `outdated`).

### Step 2: merge-from-base()

Pull in the base branch before fixing anything. This ensures fixes aren't chasing problems the base branch already solved:

```sh
BASE=$(gh pr view [number] --json baseRefName --jq '.baseRefName')
git fetch origin
git merge origin/$BASE
```

If conflicts arise, resolve them, then commit the merge before proceeding.

```
def merge-from-base($pr) {
  return <true|false>   # true if the merge changed the local branch
}
```

### Step 3: triage()

Not all feedback is equal. Sort by priority. Copilot findings are treated the same as human review comments. A bug is a bug regardless of source.

- **Must fix**: bugs, test failures, real CI failures, merge conflicts
- **Should fix**: design or style the reviewer clearly expects addressed
- **Possibly flaky**: CI-only, non-deterministic, unrelated to changed code
- **Won't fix**: style preference or out of scope; acknowledge with reason
- **Needs discussion**: fundamental disagreement; flag to author, don't apply

A CI failure is "possibly flaky" if: the error is non-deterministic (timeout, race condition, network), the test name is known to be unstable, or the failure is unrelated to any code changed in this PR.

```
def triage($pr) {
  return { must-fix: [...], should-fix: [...], possibly-flaky: [...], "won't-fix": [...], needs-discussion: [...] }
}
```

### Step 4: fix-items()

- **Must fix / Should fix**: apply the fix. One commit per item.
- **Must fix CI failures**: diagnose from the error output, fix the code, verify locally.
- **Possibly flaky CI**:
  - if other fixes are being made, skip retry (the push will trigger a fresh run).
  - If it's the only remaining blocker, retry once. If it passes → done, no push needed. If it fails again → treat as must fix.
- **Won't fix / Needs discussion**: don't apply. Document in the reply.

Example:

```sh
# rerunning failed steps
gh run rerun [run-id] --failed
```

```pseudocode
def fix-items($pr, $triage) {
  return <true|false>   # true if any fix was committed this iteration
}
```

### Step 5: reply-and-resolve()

Draft responses for each comment. Add `_🤖 automated agent_` to the end of every comment.

- For each comment: quote the original, state the action taken and commit hash.
- For skipped items, explain why.
- For disagreements, tag the author and present both sides without applying a fix.

Reply via REST for every comment. Reply all; resolve only addressed/accepted threads (needs-discussion stays open):

```sh
gh api repos/[owner]/[repo]/pulls/[number]/comments/[comment-id]/replies -f body="[reply text]"
```

Resolution policy:

- **Addressed or accepted** (fixed, won't-fix) → reply, then resolve the thread.
- **Needs discussion** → reply only; leave the thread open. It is a signal for the author, not something to close automatically.

Resolve only the resolvable set. Scope with `--thread-id` (the script's default resolves every unresolved thread, including needs-discussion ones):

```sh
bash <SKILL_DIR>/scripts/resolve-review-threads.sh [number] --thread-id <id>[,<id>...]
```

### Step 6: verify-and-push()

Before pushing, verify: all must/should-fix items addressed or explained, tests/build/lint pass locally, no new warnings, conflicts resolved cleanly. Then push.

### Step 7: request-copilot-review()

```sh
bash <SKILL_DIR>/scripts/request-copilot-review.sh [number]
```

### Step 8: wait-for-activity()

Poll until new activity (comments, reviews, CI, merge queue), then return to the loop:

```sh
bash <SKILL_DIR>/scripts/wait-for-activity.sh [number] --timeout 600
```

- Exit 0 → `'activity'`; loop back to step 1.
- Exit 1 → `'timeout'`.
- If the only remaining blocker is a human reviewer (not Copilot), do not wait → `'stop'`.
- Do not wait if all step 1 exit conditions are already met.

### Step 9: report()

If `gh pr comment` fails, output the summary inline as fallback.

```sh
gh pr comment [number] --body "$(cat <<'EOF'
## PR autofix report

> _Automated agent. Check for mistakes._

- `[FIXED|SKIPPED]` **[title: 5 words max](https://...)** → commithash
  - [short description]
  - [actions taken]
EOF
)"
```

## Guidelines

- **Commit strategy**: each logical fix gets its own commit. This makes it easy for reviewers to verify each fix independently.

  ```
  fix: add null check for user lookup (addresses review #R1)
  ```

- **Pushing is never the last step.** Every push triggers re-review.
- **Preserve the author's intent.** Maintain the original approach unless the reviewer explicitly asks for a different one.
- **Don't silently disagree.** If a review comment is wrong, flag it for discussion. Don't ignore it and don't apply a wrong fix.
