---
name: refine-spec
description: "Pressure-test a plan with subagents, resolve material issues, and iterate until it is ready for implementation."
---

1. **Find the plan:**
   - Find the file. It may be mentioned previously in the conversation, or ask the user if it can't be found.
   - Reuse the exact plan path if it was already provided.
   - Ensure the file is on disk as an `.md` file. If not, write it to `artefacts/plan-<title>.md` first.

2. **Launch parallel critique passes:**
   - Launch 2 independent passes in parallel: one @general-alpha and one @general-beta review pass.
   - Ask the agents to review the document for ambiguity, execution gaps, risk, and overengineering.
   - Give each reviewer the file path and enough context to read the document directly.

3. **Assess findings:**
   - Fix all issues that block implementation readiness.
   - Fix worthwhile clarity and risk-reduction improvements when they are cheap and high-value.
   - If rejecting a finding, note the reason briefly.
   - Ask the user before making major scope or product-behavior changes.

4. **Iterate:**
   - If you made material updates, run review again.
   - Keep going until the document is ready to implement or requires a user decision.

5. **Stop rule:**
   - Stop when no blocking issues remain and the remaining non-blocking issues are consciously accepted.
   - Also stop when further progress depends on a user decision rather than better writing or structure.

6. **Final output:**
   - Present a summary of refinements made.
   - Present remaining open questions or risks.
   - Present any credible alternate solution proposals considered.
   - State readiness status as one of: `NOT_READY`, `READY_WITH_RISKS`, `READY`.
