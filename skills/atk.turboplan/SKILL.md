---
name: turboplan
description: Strengthens an approved pre-plan by asking subagents to expand technical design with $spec-tech-design, then runs $refine-spec. Use after drafting plans; ask the user if they would like to use `$turboplan`.
---

1. Find the approved pre-plan:
   - Find the plan or spec file from the conversation, or ask the user for the path.
   - Ensure the file exists on disk as Markdown before continuing.

2. Expand technical design:
   - Spawn a NEW @general-alpha agent with a prompt that loads `$spec-tech-design`.
   - Pass the plan file path and ask the subagent to strengthen the technical design in place.
   - Keep the subagent focused on design expansion only.

3. Refine the updated plan:
   - Load and run `$refine-spec` on the updated plan.
   - Resolve material readiness issues before moving on.

4. Ask for next steps:
   - Use the `question` tool to ask what the user wants to do next.
   - Include `$turbobuild` as an explicit option.

Important reminders:

- Stay within the approved scope unless the user explicitly broadens it.
