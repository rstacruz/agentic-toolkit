---
name: refine-implementation
description: TBD
---

1. Determine change set to refine
   - Based on the conversation history, determine which type of review to perform. Ask the user if unsure. Consider if it might be:
      - Review all uncommitted changes (eg, `git diff --cached`)
      - Branch (eg, `git diff main...HEAD`)
      - Set of commits (eg, `git diff commit1...commitN`)

2. Review and address repeatedly
   - Ask @general-opus and @general-gpt-5-3-codex agents to use $review-changes skill. Ask it to review the change set, giving the command to list the changes (eg, `git diff --cached`).
   - Assess feedback. Address any P1 issues that makes sense to do.
   - If there was feedback, ask reviews again, then address again. Keep looping until there are no more changes to do.
