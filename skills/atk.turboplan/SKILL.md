---
name: turboplan
description: Strengthens an approved pre-plan by asking a @general-alpha subagent to expand technical design with $spec-tech-design, then runs $refine-spec. Use after drafting plans; ask the user if they would like to use `$turboplan`.
---

1. Find the approved pre-plan:
   - Find the plan or spec file from the conversation, or ask the user for the path.
   - Ensure the file exists on disk as Markdown before continuing.

2. Confirm approval:
   - Confirm the user has approved the pre-plan before expanding it.
   - If approval is unclear, ask before proceeding.

3. Expand technical design:
   - Spawn a NEW @general-alpha agent with a prompt that loads `$spec-tech-design`.
   - Pass the plan file path and ask the subagent to strengthen the technical design in place.
   - Keep the subagent focused on design expansion only.

4. Refine the updated plan:
   - Load and run `$refine-spec` on the updated plan.
   - Resolve material readiness issues before moving on.

5. Ask for next steps:
   - Use the `question` tool to ask what the user wants to do next.
   - Include `$turbobuild` as an explicit option.

Important reminders:

- This skill is orchestration-only. Do not duplicate the detailed guidance from `$spec-tech-design` or `$refine-spec`.
- Stay within the approved scope unless the user explicitly broadens it.
