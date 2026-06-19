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

- Correctness (inaccuracies, edge cases, missing error handling)
- Code reuse (existing utilities or helpers that could replace new code)
- Code quality (redundant state, copy-paste variants, leaky abstractions, stringly-typed code)
- Code efficiency (redundant computations, N+1, missed concurrency, hot-path bloat)
- Safety (TOCTOU existence checks, missing memory cleanup)
- Test quality (tests that don't verify behaviour)
- Gaps: What happens in failure cases? Missing fallbacks?
- Backward compatibility: Could these changes break existing behavior?
- Test terseness: which tests are load bearing? which test the contract, and which test the implementation? are there redundant tests (eg, multiple tests per failure mode)? Could test code be simplified?

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
