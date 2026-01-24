---
name: ralph-loop
description: A "ralph loop" iterates through a plan in a ticket-by-ticket basis. Use this when use *specifically* asks for a "ralph loop".
---

## Ralph loop

**Pre-requisites:**

1. Ensure there is a PRD as a Markdown file (`artefacts/prd.md` by default)
2. Ensure the PRD has tickets
3. Ensure tickets have acceptance criteria
4. Ensure there is a progress file (`artefacts/progress.md`) - create an empty one if not

**Workflow:**

1. Spawn an agent:
   - Spawn a @general agent to do the instructions in `<skill_dir>/once.md`
   - Use its instructions in verbatim, but change the file paths if needed
   - Include additional instructions / preamble if given by user
   - Ensure all plan files are included (eg, PRD, TDD)
2. Verify commit:
   - Verify that the agent created a git commit, create one if it didn't
3. Assess completeness:
   - If the agent reports all PRD tasks are done ("PRD_COMPLETE"), stop
   - Otherwise, repeat step 1 (up to 10 times max iterations)

**Guidelines:**

- Only 1 iteration per agent. Do not ask agent to do more than 1
- Use new agent sessions (eg, don't reuse session_id) - unless otherwise specified
