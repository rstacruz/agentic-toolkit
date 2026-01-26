---
name: ralph-loop
description: A "ralph loop" iterates through a plan in a ticket-by-ticket basis. Use this when use *specifically* asks for a "ralph loop".
---

## Ralph loop

**Workflow:**

1. Verify prerequisites and gather context:
   - Ensure there is a plan file as a Markdown file (`artefacts/plan.md` by default)
   - Ensure the plan file has tickets
   - Ensure tickets have acceptance criteria
   - Ensure there is a progress file (`artefacts/progress.md`) - create an empty one if not

2. Spawn an agent:
   - Read `<skill_dir>/once.md` file contents as template string
   - Perform text replacements in template string:
     - Replace `artefacts/progress.md` → custom progress path (if provided)
     - Replace `artefacts/plan.md` → custom plan path(s) (if provided)
     - Prepend additional instructions (if provided)
     - Ensure all plan files listed (add "Read *{filename}*" for each)
   - Spawn @general agent with modified template string as prompt

3. Verify commit:
   - Verify that the agent created a git commit, create one if it didn't

4. Assess completeness:
   - If agent outputs `<progress>PLAN_FINISHED</progress>`, stop successfully
   - If agent outputs `<progress>PLAN_IN_PROGRESS</progress>`, repeat step 2
   - If 10 iterations reached, create summary in progress.md and notify user

5. Error handling:
   - If agent fails: check for partial work, verify any commits, update progress with error state
   - Critical failures (file not found, corrupted plan): stop and notify user
   - Non-critical failures: document in progress.md and continue next iteration

**Guidelines:**

- Only 1 ticket per agent. Do not ask agent to do more than 1 ticket.
- Use new agent sessions (eg, don't reuse session_id) unless otherwise specified
