---
name: turbobuild
description: Implements a plan or spec on a ticket-by-ticket basis using subagents. Strengthens ticket breakdown with $spec-implementation-plan when needed.
---

1. ****Find the plan or spec:**
   - Find the plan or spec file. It may be mentioned previously in the conversation, or ask the user if it can't be found.
   - Ensure that the file is on disk as an .md file. If not, write it to `artefacts/<title>.md` first.

2. **Evaluate and clarify:**
   - Evaluate if the plan/spec if it has structured Tickets suitable for execution.
   - If tickets are missing or clearly too rough to execute safely, spawn a NEW @general-alpha agent with this prompt:
     ```
     Load the $spec-implementation-plan skill. Update [plan/spec file path] to break it down into tickets.
     ```
   - Re-read the updated file after ticket planning completes.
   - If there are other ambiguities or open questions, ask the user for clarifications first.

3. **Prepare:**
   - Create an empty *progress file* (`artefacts/progress.md`)

4. **Identify ticket:**
   - Read the spec file(s) and progress file
   - Pick one ticket, the most important one that's not blocked. It may not be the top-most ticket.
   - Pick only one ticket, never pick more than one.

5. **Spawn an agent:**
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
   - The subagent will validate inputs and execute the ticket workflow.

6. **Verify commit:**
   - Verify that the agent created a git commit, create one if it didn't.
   - Verify that commit message references exactly one ticket ID (e.g., T01, T-02). If multiple found, stop and notify user.

7. **Assess progress feedback:**
   - Read the latest entry in progress file
   - Decide whether to:
     - Continue unchanged when suggestions are informational only
     - Auto-adjust upcoming ticket order or acceptance criteria when the fix is cheap and low-risk
     - Make a small plan/spec correction directly when the issue is minor and unambiguous
     - Pause and ask the user before continuing when the suggestion changes product behavior, widens scope, or reveals unresolved ambiguity
   - Treat implementation-level fixes as safe to adjust inside the loop; treat behavior or scope changes as user decisions.

8. **Assess completeness:**
   - Check if there are any tickets requiring action after this.
   - If work remains, repeat step 4.
   - If 20 iterations reached, create summary in progress.md and notify user.
   - If there are none, continue to step 10.

9. **Handle errors:**
   - If agent fails: check for partial work, verify any commits, update progress with error state.
   - Critical failures (file not found, corrupted spec): stop and notify user.
   - Non-critical failures: document in progress.md and continue next iteration.

10. **Post-execution polish:**
   - Load and run the `$polish` skill.
   - Pass both the spec path and the git range as context (e.g., `artefacts/spec.md` and `main...HEAD`) so it can review against the spec and own the final post-polish verification pass.
   - This step runs once, after all tickets are complete.

11. **Ask for next steps:**
   - When implementation is done, use the `question` tool to ask what the user wants to do next.
   - Include a choice to create a PR.

Important reminders:

- Always ask for review after ticket - this greatly impacts build quality.
- Only 1 ticket per agent. Do not ask agent to do more than 1 ticket.
- Use new agent sessions every iteration (eg, don't reuse session_id).
- Let the `$implement-spec-subagent` skill handle all execution details.
- If implementation produces scope or behavior changes, pause for user input rather than silently broadening the work.
