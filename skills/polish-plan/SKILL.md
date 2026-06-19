---
name: polish-plan
description: Strengthen a plan by running it through a subagent review loop — catching inaccuracies and oversights before execution.
---

Strengthen this plan by incorporating feedback via subagents.

1. **Send for review** — Ask a subagent to review the plan for inaccuracies, oversights, and simplification opportunities.
2. **Classify feedback** — Categorize each item as *critical* (must fix now) or *minor* (note for user, defer).
3. **Apply critical fixes** — Incorporate all critical changes into the plan.
4. **Check convergence** — If no critical items were found this round, mark this round as **converged**.
5. **Loop or continue** — If not converged and fewer than 3 rounds completed, return to step 1 with the updated plan.
6. **Surface remaining caveats** — Present any deferred minor caveats to the user as notes/risks.
7. **Report convergence status** — State whether the last round converged or not. If the last round did **not** converge (i.e., critical issues were still being found up to the limit), flag this prominently — the plan may need human attention.

Notes:

- If available: for subagent, use *oracle* agent type, 20 max turns
- Convergence means a full review round produced no critical items (only minor caveats or nothing at all).
- Non-convergence after max rounds suggests the plan is still rough and should be flagged for human review.
