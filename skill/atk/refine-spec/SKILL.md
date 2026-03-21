---
name: refine-spec
description: "Refine a spec or plan seed with subagents"
---

1. Find the spec or plan seed:
   - Find the file. It may be mentioned previously in the conversation, or ask the user if it can't be found.
   - Ensure the file is on disk as an .md file. If not, write it to artefacts/<title>.md first.

1. Ask both @general-alpha and @general-beta to review the spec.

3. Make a judgment call on what advice to address.

4. If there were issues addressed: go back to (2) to ask for a review again. Keep going until there are no more issues to address. The goal is to reach a "ready to implement" state.
