---
name: polish
description: "Use after implementation to simplify and review code. Provide: git range (eg, main...HEAD); spec or plan path is optional supplemental context when available. Runs simplify agents + peer review loop until change set is clean."
---

1. Determine change set
   - Based on the conversation history, determine which type of review to perform. Ask the user if unsure. Consider if it might be:
      - Files changed in this conversation
      - Staged changes (eg, `git diff --cached`)
      - Branch (eg, `git diff main...HEAD`)
      - Set of commits (eg, `git diff commit1...commitN`)

2. Simplify: launch review agents in parallel
   Use the Agent tool to launch the first three agents concurrently in a single message. Pass each agent the change set information (eg, `git diff` command, or list of files and line ranges).
   If the change set includes added or modified test files, launch a fourth agent in parallel with the same change set information.

   **Agent 1: Code Reuse Review**

   For each change:
   1. Search for existing utilities and helpers that could replace newly written code. Look for similar patterns elsewhere in the codebase — common locations are utility directories, shared modules, and files adjacent to the changed ones.
   2. Flag any new function that duplicates existing functionality. Suggest the existing function to use instead.
   3. Flag any inline logic that could use an existing utility — hand-rolled string manipulation, manual path handling, custom environment checks, ad-hoc type guards, and similar patterns are common candidates.

   **Agent 2: Code Quality Review**

   Review the same changes for hacky patterns:
   1. **Redundant state**: state that duplicates existing state, cached values that could be derived, observers/effects that could be direct calls
   2. **Parameter sprawl**: adding new parameters to a function instead of generalizing or restructuring existing ones
   3. **Copy-paste with slight variation**: near-duplicate code blocks that should be unified with a shared abstraction
   4. **Leaky abstractions**: exposing internal details that should be encapsulated, or breaking existing abstraction boundaries
   5. **Stringly-typed code**: using raw strings where constants, enums (string unions), or branded types already exist in the codebase
   6. **Unnecessary JSX nesting**: wrapper Boxes/elements that add no layout value — check if inner component props (flexShrink, alignItems, etc.) already provide the needed behavior

   **Agent 3: Efficiency Review**

   Review the same changes for efficiency:
   1. **Unnecessary work**: redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
   2. **Missed concurrency**: independent operations run sequentially when they could run in parallel
   3. **Hot-path bloat**: new blocking work added to startup or per-request/per-render hot paths
   4. **Recurring no-op updates**: state/store updates inside polling loops, intervals, or event handlers that fire unconditionally — add a change-detection guard so downstream consumers aren't notified when nothing changed. Also: if a wrapper function takes an updater/reducer callback, verify it honors same-reference returns (or whatever the "no change" signal is) — otherwise callers' early-return no-ops are silently defeated
   5. **Unnecessary existence checks**: pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
   6. **Memory**: unbounded data structures, missing cleanup, event listener leaks
   7. **Overly broad operations**: reading entire files when only a portion is needed, loading all items when filtering for one

   **Agent 4: Test Value Review**

   Review changed test files for obsolete scaffold tests:
   1. Classify each added or modified test as `keep`, `remove candidate`, or `uncertain`.
   2. Mark `remove candidate` only when the test pins internal implementation details rather than observable behavior, duplicates stronger existing coverage with the same failure signal, or exists only as red-phase or extraction scaffolding and no longer adds lasting regression value.
   3. Mark `keep` when the test covers behavior, domain rules, edge cases, contracts, regressions, or important failure modes.
   4. Return file and line references with a brief rationale for each `remove candidate` or `uncertain` classification.
   5. Do not edit files directly.

   Wait for all launched agents to complete. Aggregate findings and fix each issue directly. If a finding is a false positive or not worth addressing, note it and move on. Briefly summarize what was fixed (or confirm the code was already clean).

3. Remove obsolete scaffold tests
   - Review Agent 4 findings when that agent was run and remove only high-confidence `remove candidate` tests.
   - Keep any `uncertain` tests.
   - Focus removals on tests that pin implementation details, duplicate stronger coverage, or exist only as red-phase scaffolding.
   - Keep tests that verify behavior, domain rules, edge cases, contracts, regressions, and important failure modes.

4. Review and address repeatedly
   - Ask @general-alpha and @general-beta agents to use `$review-changes` skill.
   - Give them the command to list the changes (eg, `git diff --cached`) and the spec or plan path when available.
   - Assess feedback. Address any P1 issues that makes sense to do.
   - If there was feedback, ask reviews again, then address again. Keep looping until there are no more changes to do.

5. Re-run verification after edits
   - After any edits, including scaffold-test cleanup and review fixes, re-run the relevant verification commands for the affected change set.
   - Prefer the quality gates from the spec or plan when available; otherwise use the most relevant local checks.
   - If verification fails, fix the issue and verify again before the next review pass.
   - Run one final verification pass before finishing, even if the review loop produced no further edits.

6. Keep the scope tight
   - Do not refactor unrelated areas while addressing findings.
   - Do not widen the diff just to satisfy optional feedback.
   - Every change should trace back to simplification, a review finding, or verification.
