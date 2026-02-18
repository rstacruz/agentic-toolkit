---
name: ralph-execute-via-subagent
description: A "ralph loop" iterates through a plan in a ticket-by-ticket basis. Use this when use *specifically* asks for a "ralph loop".
---

1. Find the plan:
   - Find the plan file. It may be mentioned previously in the conversation, or ask the user if it can't be found.
   - Ensure that the plan file is on the disk as an .md file. If not, write it to artefacts/<title>.md first.

2. Evaluate and clarify:
   - Evaluate if plan makes sense.
   - Check if the plan has structured Tickets:
     - If no tickets exist, use the `question` tool to ask the user:
       - Do they want to use `$spec-implementation-plan` to break work into tickets?
       - Or do they have feedback on the plan?
   - If plan has other ambiguities or open questions, ask the user for clarifications first.

3. Prepare:
   - Create an empty *progress file* (`artefacts/progress.md`)

4. Spawn an agent:
   - Read the `<prompt-template>` below
   - **Critical:** Use prompt template exactly as written. Do not paraphrase. Only perform these text replacements:
     - Replace `artefacts/progress.md` → custom progress path (if provided)
     - Replace `artefacts/plan.md` → custom plan path(s) (if provided)
     - Prepend additional instructions (if provided)
     - Ensure all plan files listed (add "Read *{filename}*" for each)
   - Spawn a NEW @general-opus agent with the prompt template as prompt

5. Verify commit:
   - Verify that the agent created a git commit, create one if it didn't
   - Verify that commit message references exactly one ticket ID (e.g., T01, T-02). If multiple found, stop and notify user

6. Assess completeness:
   - If agent outputs `<progress>PLAN_FINISHED</progress>`, stop successfully
   - If agent outputs `<progress>PLAN_IN_PROGRESS</progress>`, repeat step 4
   - If 10 iterations reached, create summary in progress.md and notify user

7. Error handling:
   - If agent fails: check for partial work, verify any commits, update progress with error state
   - Critical failures (file not found, corrupted plan): stop and notify user
   - Non-critical failures: document in progress.md and continue next iteration

Important reminders:

- Always ask for review after ticket - this greatly impacts build quality
- Only 1 ticket per agent. Do not ask agent to do more than 1 ticket
- Use new agent sessions every iteration (eg, don't reuse session_id)

---

<prompt-template>

1. Gather context
   - Read *progress file* (`artefacts/progress.md`)
   - Read *plan file(s)* (`artefacts/plan.md`)

2. Identify ticket
   - Pick one ticket - the most important one that's not blocked. It may not be the top-most ticket
   - Pick only one ticket, never pick more than one

3. Do task
   - Do the identified ticket
   - See guidelines below
   - Proceed to next step as soon as the ticket is done, don't proceed to other tickets

4. Verify work
   - If available, use *review-with-subagent* skill with @general agent
   - Make judgement call on which of its feedback to address

5. Mark progress
   - Update *plan file* to mark ticket as done:
     - eg, Change `### T-01: Title` to `### ✓ T-01: Title (Done)`
   - Ensure all acceptance criteria checkboxes are checked: `- [x]`

6. Verify single ticket scope
   - Confirm you only modified files related to ONE ticket
   - If you touched multiple tickets, undo changes and redo with single ticket focus

7. Document learnings
   - Assess the conversation, summarise work done, include assumptions flagged
   - Identify potential roadblocks that future dev work might encounter (eg, errors, wrong decisions)
   - Append them to *progress file* (create if it doesn't exist) - this is to assist future work

8. Commit changes
   - Include ticket ID in commit title

9. Assess completeness
   - Check if there are any tickets requiring action after this
   - If there are none, output: `<progress>PLAN_FINISHED</progress>`
   - If work remains, output: `<progress>PLAN_IN_PROGRESS</progress>`

Code writing guidelines:

- State assumptions before writing code.
- Verify before claiming correctness.
- Handle non-happy paths as well. Do not handle only the happy path.
- Answer: under what conditions does this work?

Other guidelines:

- Do not make a pull request
- IMPORTANT: Only do ONE ticket. stop after finishing one ticket. do not proceed to others
- IMPORTANT: Never commit artefacts/ files

</prompt-template>
