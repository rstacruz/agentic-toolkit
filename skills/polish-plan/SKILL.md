---
name: polish-plan
description: Strengthen a plan by running it through a subagent review loop — catching inaccuracies and oversights before execution.
---

Strengthen this plan by incorporating feedback via subagents.

1. Ask a subagent to review the plan for inaccuracies, oversights, simplification opportunities.
2. Triage the feedback: apply necessary changes now; note minor caveats to surface to the user later.
3. If changes were needed, return to step 1. Repeat up to 7 times.
4. Report.

Notes:

- If using Claude Code: use *general-purpose* subagent with model=Opus
- If *oracle* type is available: for Agent tool, use subagent_type=oracle max_turns=35

Reporting:

- Make recommendation. If the last round still had changes to be done, suggest more polish rounds, there may be additional issues to find
