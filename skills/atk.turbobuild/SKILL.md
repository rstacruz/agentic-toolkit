---
name: turbobuild
description: Expands a plan into implementation-ready tickets by asking a @general-alpha subagent to use $spec-implementation-plan, then runs $implement-spec. Use when a plan is ready to turn into execution.
---

1. Find the plan:
   - Find the plan or spec file from the conversation, or ask the user for the path.
   - Ensure the file exists on disk as Markdown before continuing.

2. Expand tickets:
   - Spawn a NEW @general-alpha agent with a prompt that loads `$spec-implementation-plan`.
   - Pass the plan file path and ask the subagent to strengthen the ticket breakdown in place.
   - Keep the subagent focused on ticket planning only.

3. Execute the plan:
   - Load and run `$implement-spec` against the updated plan.

4. Ask for next steps:
   - Use the `question` tool to ask what the user wants to do next.
   - Include a choice to create a PR when appropriate.

Important reminders:

- This skill is a thin wrapper. Do not duplicate the detailed guidance from `$spec-implementation-plan` or `$implement-spec`.
- If implementation produces scope or behavior changes, pause for user input rather than silently broadening the work.
