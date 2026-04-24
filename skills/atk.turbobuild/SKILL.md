---
name: turbobuild
description: Implements a plan on a ticket-by-ticket basis using subagents. Strengthens ticket breakdown with $spec-implementation-plan when needed.
---

1. ****Find the plan:**
   - Find the plan file. It may be mentioned previously in the conversation, or ask the user if it can't be found.
   - Reuse the exact plan path if it was already provided.
   - Ensure that the file is on disk as an .md file. If not, write it to `artefacts/plan-<title>.md` first.

2. **Evaluate and clarify:**
   - Evaluate if the plan has structured Tickets suitable for execution.
   - If tickets are missing or clearly too rough to execute safely, spawn a NEW @general-alpha agent with this prompt:
     ```
     Load the $spec-implementation-plan skill. Update [plan file path] to break it down into tickets.
     ```
   - Re-read the updated file after ticket planning completes.
   - If there are other ambiguities or open questions, ask the user for clarifications first.

3. **Prepare:**
   - Derive the progress path from the plan path by inserting `-progress` before `.md`
   - Example: `artefacts/plan-rate-limiter.md` -> `artefacts/plan-rate-limiter-progress.md`
   - Create the progress file if it does not exist yet

4. **Identify ticket:**
   - Read the plan file and progress file
   - Pick one ticket, the most important one that's not blocked. It may not be the top-most ticket.
   - Pick only one ticket, never pick more than one.

5. **Spawn an agent:**
   - Prepare the ticket input: the identified ticket (ID and title)
   - Prepare the plan path: use the resolved plan path exactly as provided
   - Prepare the progress path: use the derived sibling progress path
   - Spawn a NEW @general-alpha agent with this prompt:
     ```
     Load the $implement-spec-subagent skill. Pass these inputs:
     - {{TICKET}}: [ticket ID and title]
     - {{PLAN_FILE}}: [plan file path]
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
     - Make a small plan correction directly when the issue is minor and unambiguous
     - Pause and ask the user before continuing when the suggestion changes product behavior, widens scope, or reveals unresolved ambiguity
   - Treat implementation-level fixes as safe to adjust inside the loop; treat behavior or scope changes as user decisions.

8. **Assess completeness:**
   - Check if there are any tickets requiring action after this.
   - If work remains, repeat step 4.
   - If 20 iterations reached, create a summary in the progress file and notify user.
   - If there are none, continue to step 10.

9. **Handle errors:**
   - If agent fails: check for partial work, verify any commits, update progress with error state.
   - Critical failures (file not found, corrupted plan): stop and notify user.
   - Non-critical failures: document in the progress file and continue next iteration.

10. **Post-execution polish:**
   - Load and run the `$polish` skill.
   - Pass both the plan path and the git range as context (e.g., `artefacts/plan-rate-limiter.md` and `main...HEAD`) so it can review against the plan and own the final post-polish verification pass.
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
