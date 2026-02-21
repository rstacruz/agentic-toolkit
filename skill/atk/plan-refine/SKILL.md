---
name: plan-refine
description: "Refine a plan with subagents"
---

1. Find the plan:
   - Find the plan file. It may be mentioned previously in the conversation, or ask the user if it can't be found.
   - Ensure that the plan file is on the disk as an .md file. If not, write it to artefacts/<title>.md first.

1. Ask both @general-opus and @general-gpt-5-3-codex to review the plan.

3. Make a judgment call on what advice to address.

4. If there were issues addressed: go back to (2) to ask for a review again. Keep going until there are no more issues to address. The goal is to reach a "ready to implement" state.
