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

6. Document learnings
   - Assess the conversation, summarise work done, include assumptions flagged
   - Identify potential roadblocks that future dev work might encounter (eg, errors, wrong decisions)
   - Append them to *progress file* (create if it doesn't exist) - this is to assist future work

7. Commit changes
   - Include ticket ID in commit title

8. Assess completeness
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
- Only do ONE ticket, do not proceed to others
