---
name: polish-plan
description: Strengthen a plan by running it through a subagent review loop — catching inaccuracies and oversights before execution.
---

Strengthen this plan by incorporating feedback via subagents.

1. Ask a subagent to review the plan for inaccuracies, oversights, simplification opportunities — include the structural checks below in its prompt.
2. Triage the feedback: apply necessary changes now; note minor caveats to surface to the user later.
3. If changes were needed, return to step 1. Repeat up to 7 times.
4. Report.

Structural checks (when the plan extends an existing system — rules engine, enum, schema, classifier):

- **Wrong-axis check:** have the reviewer list the target system's extension points (axes) and what behaviour each owns, then justify that the plan's chosen one owns the behaviour being changed — and sketch the runner-up axis with its artifact count (enum values + seed/config rows + records-per-entity + workarounds). If the runner-up scores markedly lower, that's a finding, not a footnote.
- **Compensating-data smell:** flag any data that exists only to appease an existing code path — 0-cost rows, marker/placeholder rules, enum values "never stored on a record". One is a shortcut; two or more means the entity is in the wrong code path and the plan should switch axes rather than add workarounds.
- **Invariant applicability:** for each shipped invariant the plan works around, ask whether it conceptually applies to the new case. If it doesn't, route around it (own branch/type), don't fake compliance.

Notes:

- If using Claude Code: use *general-purpose* subagent with model=Opus
- If *oracle* type is available: for Agent tool, use subagent_type=oracle max_turns=35

Reporting:

- Make recommendation. If the last round still had changes to be done, suggest more polish rounds, there may be additional issues to find
