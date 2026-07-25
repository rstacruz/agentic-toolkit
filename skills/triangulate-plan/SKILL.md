---
name: triangulate-plan
description: Improve a plan by asking a subagent to generate an alternative perspective, then comparing and combining results. Use when a plan already exists in the conversation and the user wants a second opinion, broader coverage, or to catch blind spots.
---

# Triangulate plan

Generates an independent second opinion on an existing plan and merges the best of both.

## Workflow

### 1. Locate the existing plan

Find the plan produced earlier in this conversation. If none exists, abort.

### 2. Extract the brief

From the existing plan, distill a brief containing only:

- The original ask
- Decisions made (clarifications, answers, steers)
- Relevant resources used (file paths, symbol names, URLs)

Do **not** include: implementation steps, tests to write, or any detail that wasn't in the original request. In particular, when the plan extends an existing system (a rules engine, enum, schema, classifier), do **not** leak which extension point the existing plan chose — name the target system and let the subagent pick its own. A second opinion that inherits the first plan's axis can't catch a wrong-axis mistake.

### 3. Delegate to a subagent

Use the *brainstorm* skill to generate an independent plan from the same brief:

> Use *brainstorm* skill. Formulate a plan. Do not write a Markdown file — reply with the plan itself.
> Brief: {brief contents}

### 4. Compare and recommend

Compare the new plan against the existing one. Assess:

- Where they agree (reinforces confidence)
- Where they differ (highlights alternatives or blind spots)
- What to adopt from each

When both plans extend an existing system, also run these checks:

- **Axis check:** list the target system's extension points (axes) and what behaviour each owns (e.g. usage type → classification; billing source → rate lookup). Each plan must extend the axis that owns the behaviour being changed — extending the wrong one shows up as workarounds against the right one's invariants.
- **Compensating-data count:** data manufactured only to appease an existing code path (0-cost rows, marker/placeholder rules, enum values never stored on a record, events that exist only to unlock other events). One is a shortcut; two or more means that plan put the entity in the wrong code path.
- **Artifact count:** enum values + seed/config rows + records-per-entity + workarounds. Fewer wins ties; a large gap usually means one plan picked the wrong axis.

Present the assessment for the user to decide.

## Guidelines 

For subagent, use *oracle* agent type if available.
