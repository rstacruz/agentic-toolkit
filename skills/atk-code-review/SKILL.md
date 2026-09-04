---
name: atk-code-review
description: Review code changes and return a prioritised list of issues — posted as GitHub PR review threads when a PR exists, or as plain text otherwise. Use when asked to review a PR, diff, or implementation for correctness, code quality, reuse, efficiency, safety, or test quality. When invoking, pass available details - the plan, git change range, files to review.
---

Review the code with the following guidelines.

## Workflow

1. Determine change set. Based on conversation history, determine the review scope. Ask if unsure. Consider:
  - Files changed in this conversation
  - Staged changes (eg, `git diff --cached`)
  - Branch (eg, `git diff main...HEAD`)
  - Set of commits (eg, `git diff commit1...commitN`)

2. Gather context:
  - Read the plan (if given) and files to review.
  - Review CI/CD status (if PR).
  - Check whether a PR exists for the current branch: `gh pr view --json number -q .number 2>/dev/null`.
    - If one exists, run `bash <SKILL_DIR>/../atk-pr-autofix/scripts/pr-status.sh --verbose --comments [number]` (reuse `atk-pr-autofix`'s script — sibling skill directory) for the PR description and top-level comments.
    - Also fetch every review thread — any author, resolved or not — for dedup and to snapshot "before" thread IDs:

    ```sh
    gh api graphql -f query='query($owner: String!, $repo: String!, $number: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $number) {
          headRefOid
          reviewThreads(first: 100) {
            nodes {
              id isResolved
              comments(first: 50) { nodes { databaseId path line body author { login } } }
            }
          }
        }
      }
    }' -F owner=[owner] -F repo=[repo] -F number=[number]
    ```

3. Review based on scope below. Skip any finding already covered by an existing thread (any author, resolved or not) at the same file/line with the same concern — don't repost what's already been raised.

4. Report or post findings (see below).

## Scope

Start from this baseline:

> Perform a deep code quality audit of the changes.
> Rethink how to structure / implement the changes to meaningfully improve code quality without impacting behavior.
> Work to improve abstractions, modularity, reduce Spaghetti code, improve succinctness and legibility.
> Be ambitious, if there is a clear path to improving the implementation that involves restructuring some of the codebase, go for it.
> Be extremely thorough and rigorous.
> Measure twice, cut once.

Consider:

**Behaviour/Correctness**
- Correctness (inaccuracies, edge cases, missing error handling)
- Same pure expression (serialization, hashing, expensive call) duplicated in sibling branches
- Claimed invariants: when code asserts a property ("last write wins", "idempotent") verify the code actually upholds it — a comment is not evidence
- Gaps: What happens in failure cases? Missing fallbacks?
- Backward compatibility

**Structure/Quality**
- Code reuse (existing utilities or helpers that could replace new code)
- Code quality (redundant state, copy-paste variants, leaky abstractions, stringly-typed code)
- Code efficiency (redundant computations, N+1, missed concurrency, hot-path bloat)
- Safety (TOCTOU existence checks, missing memory cleanup)

**Tests**
- Test quality (tests that don't verify behaviour)
- Test terseness: which tests are load bearing? which test the contract vs implementation?
- Simplify: tests that validate library/stdlib behaviour (Zod's `optional()`, discriminated unions, `decodeURIComponent` throwing, string template content) — they catch nothing in *our* logic; cut them

**Meta/Process**
- AGENTS.md / CLAUDE.md alignment (changes that contradict guidelines, incomplete work that docs imply)
- Simplification opportunities

## Reporting results

**No PR for the current branch** — report as plain text, one entry per finding:

~~~
Location: path-to-file.ts line 12-14
Severity: High

[description]

```suggestion
[optional suggestion]
```
~~~

**A PR exists** — post findings as one batched GitHub review instead of returning plain text:

1. Split non-duplicate findings by whether they land on a line in the PR's diff (`gh pr diff [number]` — a finding about unchanged code, eg. an unused existing helper elsewhere in the codebase, does not):
   - **In-diff findings** → one entry each in a `comments` JSON array: `{"path": "...", "line": ..., "body": "**[severity]**\n\n[description]\n\n```suggestion\n[optional]\n```\n\n_🤖 automated agent_"}`. GitHub's create-review endpoint 422s the *entire* batch if any comment's line falls outside the diff, so keep this array strictly diff-only.
   - **Out-of-diff findings** → fold into the review's top-level `body` text instead (still posted, just not as an inline thread).
2. Tag the review body with `_🤖 automated agent (atk-code-review)_`, so `polish-implementation` (and any human skimming the PR) can tell these apart from human/Copilot threads.
3. Post one review:

    ```sh
    HEAD_OID=$(gh pr view [number] --json headRefOid -q .headRefOid)
    gh api repos/[owner]/[repo]/pulls/[number]/reviews --input - <<EOF
    $(jq -n --arg commit "$HEAD_OID" --arg body "$REVIEW_BODY" --argjson comments "$COMMENTS_JSON" \
      '{commit_id: $commit, event: "COMMENT", body: $body, comments: $comments}')
    EOF
    ```

4. Re-run the Step 2 GraphQL query and diff its thread IDs against the "before" snapshot — the new IDs are the threads this review just created. No comment-ID bookkeeping needed.
5. Return to the caller: the list of newly created thread IDs (empty if every finding was a duplicate) plus a one-line summary.
6. Always post a review — even with zero findings. An empty-findings review (body with the `_🤖 automated agent (atk-code-review)_` tag but no inline comments) serves as a convergence marker: it tells `polish-implementation` the review ran and found nothing, so the loop can stop.

**For top level comment** (REVIEW_BODY):

- Ensure its formatted in `/skimmable` format.
- Make a judgement call between:
  - "🟢 Approval recommended" (no comments, or nitpicks only)
  - "🔵 Needs a closer look"
  - "🟡 Changes recommended" (wrong behaviour, data loss, unhandled real failures)

Example top level body comment format:

~~~
### 🟢 Approval recommended | 🔵 Needs a closer look | 🟡 Changes recommended

{short 1-sentence summary} _🤖 (automated agent: atk-code-review)_

<details>
<summary>Review details</summary>

{rest of details here}

</details>
~~~

**General guidelines:**

- Ensure the last response has the outcome itself (thread IDs + summary, or the text report). This may have been invoked in a subagent where only the last reply is used.

