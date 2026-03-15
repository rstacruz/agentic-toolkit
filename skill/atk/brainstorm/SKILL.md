---
name: brainstorm
description: Help the user develop a vague idea into a "plan seed" — a scoped, handoff-ready statement of intent
---

The user shares a rough idea. Your job: guide them to a **plan seed** through targeted questioning.

Ask clarifying questions, point out blind spots, suggest changes.

- Ask clarifying questions about intent, scope, and success criteria
- Point out blind spots or unstated assumptions
- Suggest changes or alternative framings
- Rate readiness after each exchange:
   - `NEEDS_REFINEMENT` — critical gaps remain. State which gaps and ask 1-2 follow-up questions
   - `READY_FOR_PLANNING` — criteria below are met. Confirm with user before producing the plan seed.
   - `READY_FOR_EXECUTION` — all planning criteria met AND execution criteria below are met. Confirm with user before producing the plan seed.

Ready for planning when you have clarity on:

- What problem is being solved (for whom, why it matters)
- What success looks like (measurable or demonstrable outcomes)
- What is in/out of scope (explicit boundaries)

Ready for execution (all planning criteria, plus):

- **Implementation path is obvious** — no design decisions remain; a competent engineer could start immediately
- **Scope is narrow** — touches a single file or a tightly bounded area; no cross-cutting concerns
- **No new abstractions** — no new data models, APIs, or architectural patterns needed
- **Single deliverable** — expressible as one concrete task, not a breakdown of sub-tasks
- **Low risk / reversible** — no side effects on other systems or components

**When done:** after giving the full plan seed:

- Write to `artefacts/seed-<title>.md`
- use the `question` tool to ask if the user wants to:
  - (`READY_FOR_PLANNING`) Start `$spec-mode` to make a full implementation plan
  - (`READY_FOR_EXECUTION`) Start `$execute-plan` directly, start `$spec-mode` instead, use `$refine-plan` to refine it here, `$spec-implementation-plan` to break it into smaller tasks

**Plan seed definition:** A concise document that communicates intent clearly enough to hand off to a planner — without being a plan itself.

Guidelines:
- Do not implement the change. Instead, see "when done" above.
- Always use the `question` tool when requiring user input.
