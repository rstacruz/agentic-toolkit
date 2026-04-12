---
name: polish
description: "Use after implementation to simplify and review code. Provide: git range (eg, main...HEAD); spec or plan path is optional supplemental context when available. Runs polish via simplify + peer review loop until change set is clean."
---

1. Determine change set to refine
   - Based on the conversation history, determine which type of review to perform. Ask the user if unsure. Consider if it might be:
      - Files changed in this conversation
      - Staged changes (eg, `git diff --cached`)
      - Branch (eg, `git diff main...HEAD`)
      - Set of commits (eg, `git diff commit1...commitN`)

2. Simplify first:
   - Load and run the `$simplify` skill on the change set
   - Wait for it to complete before proceeding

3. Remove obsolete scaffold tests
   - If present, remove scaffold-style tests that were useful during TDD but no longer add lasting regression value.
   - Focus on tests that pin implementation details, duplicate stronger coverage, or exist only as red-phase scaffolding.
   - Keep tests that verify behavior, domain rules, edge cases, and important failure modes.

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
