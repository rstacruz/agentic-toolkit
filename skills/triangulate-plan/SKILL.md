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

Do **not** include: implementation steps, tests to write, or any detail that wasn't in the original request.

### 3. Delegate to a subagent

Use the *brainstorm* skill to generate an independent plan from the same brief:

> Use *brainstorm* skill. Formulate a plan. Do not write a Markdown file — reply with the plan itself.
> Brief: {brief contents}

### 4. Compare and recommend

Compare the new plan against the existing one. Assess:

- Where they agree (reinforces confidence)
- Where they differ (highlights alternatives or blind spots)
- What to adopt from each

Present the assessment for the user to decide.

## Guidelines 

For subagent, use *oracle* agent type if available.
