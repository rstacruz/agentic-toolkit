---
name: execute-plan-subagent
description: Executes a single ticket from a plan. Always invoke with ticket, plan file, progress file. For use by subagents only.
---

## Input Validation

**CRITICAL**: This skill requires three inputs to be passed from the parent agent:

1. `{{TICKET}}` - The ticket ID and title (e.g., "T-01: Implement user authentication")
2. `{{PLAN_FILE}}` - Path to the plan file (e.g., `artefacts/plan.md`)
3. `{{PROGRESS_FILE}}` - Path to the progress file (e.g., `artefacts/progress.md`)

If any of these inputs are missing or not provided, exit immediately with this message:

> Error: Missing required input. Please provide: ticket ID, plan file path, and progress file path.

Do not proceed further. Do not attempt to infer or guess missing values.

## Workflow

1. Gather context
   - Read *progress file* (`{{PROGRESS_FILE}}`)
   - Read *plan file(s)* (`{{PLAN_FILE}}`)

2. Do ticket
   - Ticket: `{{TICKET}}`
   - See guidelines below
   - Proceed to step 3 as soon as the ticket is done, don't proceed to other tickets

3. Verify work
   - Stage updates in Git (git add)
   - Load `$review-changes` skill. Ask it to review staged changes (git diff --cached).
   - Assess feedback. Address any P1 issues that makes sense to do.
   - If there was feedback, ask reviews again, then address again. Keep looping until there are no more changes to do.

4. Verify single ticket scope
   - Confirm you only modified files related to ONE ticket
   - If you touched multiple tickets, undo changes and redo with single ticket focus

5. Document learnings
   - Assess the conversation, summarise work done, include assumptions flagged
   - Identify potential roadblocks that future dev work might encounter (eg, errors, wrong decisions)
   - Append them to *progress file* - this is to assist future work

6. Commit changes
   - Include ticket ID in commit title

## Code writing guidelines

- State assumptions before writing code.
- Verify before claiming correctness.
- Handle non-happy paths as well. Do not handle only the happy path.
- Answer: under what conditions does this work?

## Other guidelines

- Do not make a pull request
- **IMPORTANT**: Only do ONE ticket. Stop after finishing one ticket. Do not proceed to others.
- **IMPORTANT**: Never commit artefacts/ files.
