---
name: execute-plan
description: "Execute a plan"
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

4. Proceed:
   - Proceed with implementing the plan.
   - Do one ticket.
   - Before starting each ticket:
     - Read the *plan file* and *progress file* again. This ensures we're working with updated copies.
   - After finishing each ticket:
     - Ask a @general-opus agent to use $review-changes skill. Ask it to review the uncommitted changes.
     - Assess feedback. Address any P1 issues that makes sense to do.
     - Commit your work. Include the ticket ID in the commit message.
     - Document learnings:
       - Assess the conversation, summarise work done, include assumptions flagged
       - Identify potential roadblocks that future dev work might encounter (eg, errors, wrong decisions)
       - Append them to *progress file* (create if it doesn't exist) - this is to assist future work

5. Post-implementation review, when done:
   - Ask @general-opus and @general-gpt-5-3-codex agents to use $review-changes skill. Ask it to review all changes, starting with the first commit.
   - Assess feedback. Address any P1 issues that makes sense to do.
   - If there was feedback, ask reviews again, then address again. Keep looping until there are no more changes to do.
   - Ask a @general-opus agent to use $refine-tests skill.
   - Apply recommendations from $refine-tests using @general-opus agent.

Important reminders:

- Always ask for review after ticket - this greatly impacts build quality
- Always re-read plan and progress files before every ticket - changes from external sources are expected
