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

2. **Subagent review.** Spawn a subagent with the change set from step 1.
   - Include new changes from previous passes (if applicable).
   - Ask it to use `atk-code-review` skill.
   - Pass the change set and the plan (if available).

3. **Triage.** Decide on what changes are neccesary and apply them.
   - Prefer surgical changes. Large scale change = defer later.
  
4. If changes were made, commit. Return to step 2. Repeat up to 7 times.

5. Report.

Notes:

- If available: for subagent, use *oracle* agent type, 20 max turns

Reporting:

- Make recommendation. If the last round still had changes to be done, suggest more polish rounds, there may be additional issues to find
- Summarise polishing done, and recommendations for future work.
