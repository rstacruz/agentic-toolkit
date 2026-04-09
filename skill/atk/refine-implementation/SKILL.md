---
name: refine-implementation
description: "Use after implementation to simplify and review code. Provide: git range (eg, main...HEAD). Runs simplify + peer review loop until change set is clean."
---

1. Determine change set to refine
   - Based on the conversation history, determine which type of review to perform. Ask the user if unsure. Consider if it might be:
      - Files changed in this conversation
      - All uncommitted changes (eg, `git diff --cached`)
      - Branch (eg, `git diff main...HEAD`)
      - Set of commits (eg, `git diff commit1...commitN`)

2. Simplify first:
   - Load and run the `$simplify` skill on the change set
   - Wait for it to complete before proceeding

3. Review and address repeatedly
   - Ask @general-alpha and @general-beta agents to use `$review-changes` skill. Ask them to review the change set, giving the command to list the changes (eg, `git diff --cached`).
   - Assess feedback. Address any P1 issues that makes sense to do.
   - If there was feedback, ask reviews again, then address again. Keep looping until there are no more changes to do.
