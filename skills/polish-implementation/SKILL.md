---
name: polish-implementation
description: Iterative code review loop using a subagent — catches bugs, code quality issues, and inefficiencies; auto-applies fixes up to 3 passes.
---

Run an iterative review loop on an implementation, auto-applying fixes each pass.

1. **Determine change set.** Based on conversation history, determine the review scope. Ask if unsure. Consider:
  - Files changed in this conversation
  - Staged changes (eg, `git diff --cached`)
  - Branch (eg, `git diff main...HEAD`)
  - Set of commits (eg, `git diff commit1...commitN`)

2. **Subagent review.** Spawn a subagent (oracle, if available) with the change set from step 1. Ask it to return a prioritised list of issues covering:
  - Correctness (inaccuracies, edge cases, missing error handling)
  - Code reuse (existing utilities or helpers that could replace new code)
  - Code quality (redundant state, copy-paste variants, leaky abstractions, stringly-typed code)
  - Code efficiency (redundant computations, N+1, missed concurrency, hot-path bloat)
  - Safety (TOCTOU existence checks, missing memory cleanup)
  - Test quality (tests that don't verify behaviour)

3. **Triage.** Apply necessary changes now; surface minor caveats to the user later.

4. If changes were made, return to step 2 — repeat up to 3 times.

Notes:

- If available: for subagent, use *oracle* agent type, 20 max turns
