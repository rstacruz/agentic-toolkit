---
name: implement-spec
description: Implements a spec on a ticket-by-ticket basis.
---

1. Find the spec:
   - Find the spec file. It may be mentioned previously in the conversation, or ask the user if it can't be found.
   - Ensure that the spec file is on the disk as an .md file. If not, write it to artefacts/<title>.md first.

2. Evaluate and clarify:
   - Evaluate if spec makes sense.
   - Check if the spec has structured Tickets:
     - If no tickets exist, use the `question` tool to ask the user:
       - Do they want to use `$spec-implementation-plan` to break work into tickets?
       - Or do they have feedback on the spec?
   - If spec has other ambiguities or open questions, ask the user for clarifications first.

3. Prepare:
   - Create an empty *progress file* (`artefacts/progress.md`)

4. Identify ticket:
   - Read the spec file(s) and progress file
   - Pick one ticket — the most important one that's not blocked. It may not be the top-most ticket
   - Pick only one ticket, never pick more than one

5. Spawn an agent:
    - Prepare the ticket input: the identified ticket (ID and title)
    - Prepare the spec path: `artefacts/spec.md` (or custom path if provided)
    - Prepare the progress path: `artefacts/progress.md` (or custom path if provided)
    - Spawn a NEW @general-alpha agent with this prompt:
      ```
      Load the $implement-spec-subagent skill. Pass these inputs:
      - {{TICKET}}: [ticket ID and title]
      - {{SPEC_FILE}}: [spec file path]
      - {{PROGRESS_FILE}}: [progress file path]
      ```
    - The subagent will validate inputs and execute the ticket workflow

6. Verify commit:
   - Verify that the agent created a git commit, create one if it didn't
   - Verify that commit message references exactly one ticket ID (e.g., T01, T-02). If multiple found, stop and notify user

7. Assess completeness:
   - Check if there are any tickets requiring action after this
   - If work remains, repeat step 4
   - If 20 iterations reached, create summary in progress.md and notify user
   - If there are none, continue to step 9

8. Error handling:
   - If agent fails: check for partial work, verify any commits, update progress with error state
   - Critical failures (file not found, corrupted spec): stop and notify user
   - Non-critical failures: document in progress.md and continue next iteration

9. Post-execution polish:
   - Load and run the `$refine-implementation` skill
   - Pass both the spec path and the git range as context (e.g., `artefacts/spec.md` and `main...HEAD`) so it can review against the spec and own the final post-polish verification pass
   - This step runs once, after all tickets are complete

Important reminders:

- Always ask for review after ticket - this greatly impacts build quality
- Only 1 ticket per agent. Do not ask agent to do more than 1 ticket
- Use new agent sessions every iteration (eg, don't reuse session_id)
- Let the `$implement-spec-subagent` skill handle all execution details
