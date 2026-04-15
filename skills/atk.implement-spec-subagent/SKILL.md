---
name: implement-spec-subagent
description: Implements a single ticket from a spec. Always invoke with ticket, spec file, progress file. For use by subagents only.
---

## Input Validation

**CRITICAL**: This skill requires three inputs to be passed from the parent agent:

1. `{{TICKET}}` - The ticket ID and title (e.g., "T-01: Implement user authentication")
2. `{{SPEC_FILE}}` - Path to the spec file (e.g., `artefacts/spec.md`)
3. `{{PROGRESS_FILE}}` - Path to the progress file (e.g., `artefacts/progress.md`)

If any of these inputs are missing or not provided, exit immediately with this message:

> Error: Missing required input. Please provide: ticket ID, spec file path, and progress file path.

Do not proceed further. Do not attempt to infer or guess missing values.

## Workflow

1. Gather context
   - Read *progress file* (`{{PROGRESS_FILE}}`)
   - Read *spec file(s)* (`{{SPEC_FILE}}`)

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
   - Append one progress entry for `{{TICKET}}` to `{{PROGRESS_FILE}}`
   - Use this structure:
     - `Status:` completed, blocked, or partial
     - `Assumptions:` assumptions you made while implementing the ticket
     - `Learnings:` implementation details that future tickets should know about
     - `Blockers/Risks:` potential roadblocks that future work might encounter
     - `Suggested plan changes:` optional list of corrections or pivots the parent agent should assess
   - For each suggested plan change, include:
     - `Type:` spec inaccuracy, inconsistency, hidden dependency, reorder needed, pivot needed, or similar
     - `Impact:` what this changes for upcoming work
     - `Recommendation:` the concrete next-step adjustment to make
     - `User input needed:` yes or no
   - Do not directly rewrite the broader spec or plan unless that work is explicitly part of `{{TICKET}}`

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
