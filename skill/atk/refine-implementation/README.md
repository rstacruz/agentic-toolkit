# Refine Implementation

Refine uncommitted changes, commits, branches, or PRs before merging.

**Use when:** After implementation, before merging, code review phase

## Example: Refine uncommitted work

> **User:** Just added user validation, refine it
>
> **Agent:** (Reads git diff) (Reads full files) (Checks AGENTS.md conventions)
>
> Found 3 issues:
> - Missing null check in `validateUser()` — P1 bug
> - Excessive nesting in `processData()` — structure
> - Unused import — cleanup
>
> (Fixes issues) (Runs verification)
>
> **Summary:** `CHANGES_DONE` — Fixed null check, flattened nesting, removed unused import.

## Example: Refine PR

> **User:** Refine implementation #234
>
> **Agent:** (Fetches PR via gh) (Reads changed files)
>
> Found P1 issue: Missing await on async `saveTask()` call at line 45 — will cause data loss.
>
> (Fixes) (Verifies)
>
> **Summary:** `CHANGES_DONE` — Fixed missing await.

## Example: Refine commit

> **User:** Refine implementation abc123
>
> **Agent:** (Reads commit via git show) (Checks full file context)
>
> **Summary:** `NO_CHANGES_REQUIRED` — Logic correct, follows patterns, no issues found.

## Focus priorities

**P1 Bugs:** Logic errors, missing guards, null/undefined handling, security vulnerabilities, broken error handling

**P2 Structure:** Pattern consistency, excessive nesting, abstraction usage

**P3 Performance:** Obvious O(n²), N+1 queries, blocking I/O on hot paths

## Input types

- **No args:** Uncommitted changes (`git diff`, `git diff --cached`)
- **Commit hash:** `git show $HASH`
- **Branch:** `git diff $BRANCH...HEAD`
- **PR #/URL:** `gh pr view/diff`

**Related:** [`verify-implementation`](../verify-implementation/), [`review-with-subagent`](../review-with-subagent/)
