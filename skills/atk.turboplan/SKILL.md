---
name: turboplan
description: Strengthens an approved plan by asking subagents to expand technical design with $spec-tech-design, then runs $refine-spec. Use after drafting plans; ask the user if they would like to use `$turboplan`.
---

1. **Find the plan:**
   - Find the plan file. It may be mentioned previously in the conversation, or ask the user if it can't be found.
   - Reuse the exact plan path if it was already provided.
   - If that plan path is not on disk yet, create the plan at that exact path.
   - Only if no plan path exists yet, write it to `artefacts/plan-<title>.md` first.

2. **Expand technical design:**
   - Spawn a NEW @general-alpha agent with this prompt:
     ```
     Load `$spec-product-requirements` and `$spec-tech-design` skills.
     Strengthen the plan file in place with product requirements and technical design.
     Keep it compact. When adding new content, consider if there is existing redundant content that can be removed.

     - Plan file path: [plan file path]
     ```

3. **Refine the updated plan:**
   - Load and run `$refine-spec` on the updated plan.
   - Resolve material readiness issues before moving on.

4. **Ask for next steps:**
   - Use the `question` tool to ask what the user wants to do next.
   - Include `$turbobuild` as an explicit option.

**Important reminders:**

- Stay within the approved scope unless the user explicitly broadens it.
