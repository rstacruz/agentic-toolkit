---
name: turbobuild
description: Expands a plan into implementation-ready tickets by asking a @general-alpha subagent to use $spec-implementation-plan, then runs $implement-spec. Use when a plan is ready to turn into execution.
---

1. Find the plan:
   - Find the plan or spec file from the conversation, or ask the user for the path.
   - Ensure the file exists on disk as Markdown before continuing.

2. Expand tickets:
   - Spawn a new @general-alpha agent with a prompt that loads `$spec-implementation-plan`.
   - Pass the plan file path and ask the subagent to strengthen the ticket breakdown in place.
   - Keep the subagent focused on ticket planning only.

3. Execute the plan:
   - Use the `$implement-spec` to implement the plan ticket-by-ticket using subagents.

4. Ask for next steps:
   - When implementation is done, use the `question` tool to ask what the user wants to do next.
   - Include a choice to create a PR.

Important reminders:

- If implementation produces scope or behavior changes, pause for user input rather than silently broadening the work.
