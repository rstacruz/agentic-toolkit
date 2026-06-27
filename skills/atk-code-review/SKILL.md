---
name: atk-code-review
description: Review code changes and return a prioritised list of issues. Use when asked to review a PR, diff, or implementation for correctness, code quality, reuse, efficiency, safety, or test quality. When invoking, pass available details - the plan, git change range, files to review.
---

Review the code with the following guidelines.

## Workflow

1. Determine change set. Based on conversation history, determine the review scope. Ask if unsure. Consider:
  - Files changed in this conversation
  - Staged changes (eg, `git diff --cached`)
  - Branch (eg, `git diff main...HEAD`)
  - Set of commits (eg, `git diff commit1...commitN`)

2. Gather context:
  - Read PR description, linked issue, plan (if given)
  - Read files to review
  - Review CI/CD status (if PR)
  - Read PR comments
  
3. Review based on scope below.

4. Report list of issues.

## Scope

Start from this baseline:

> Perform a deep code quality audit of the hcnages.
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

For each finding, report:

- Severity (low, medium, high)
- Location, description, optional suggestion

~~~
Location: path-to-file.ts line 12-14
Severity: High

[description]

```suggestion
[optional suggestion]
```
~~~

Guidelines:

- Ensure the last response has the feedback itself. This may have been envoked in a subagent where only the last reply is used.
