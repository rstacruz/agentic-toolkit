---
name: brainstorm
description: Help the user develop a vague idea into a "plan" — a scoped, handoff-ready statement of intent
---

The user shares a rough idea. Guide them to a **plan** through targeted questioning — ask about intent, scope, and success criteria; point out blind spots; suggest alternative framings.

Rate readiness after each exchange:

- `NEEDS_REFINEMENT` — critical gaps remain. State which gaps and ask 1-2 follow-up questions.
- `READY_FOR_PLANNING` — all planning criteria met. Produce the plan immediately.
- `READY_FOR_EXECUTION` — all planning + execution criteria met. Produce the plan immediately.

READY_FOR_PLANNING criteria:

- What problem is being solved (for whom)
- What success looks like (measurable or demonstrable outcomes)
- What is in/out of scope (explicit boundaries)
- Why this problem is important — always ask the user via the `question` tool; suggest reasons to pick from; never infer it yourself

READY_FOR_EXECUTION criteria: All planning criteria, plus the ones below:

- **Implementation path is obvious** — no design decisions remain; a competent engineer could start immediately
- **Scope is narrow** — touches a single file or tightly bounded area; no cross-cutting concerns
- **Single deliverable** — one concrete task, not a breakdown of sub-tasks

**When done:** Write the plan to `artefacts/plan-<title>.md`. Reply with the filename, then use the `question` tool to ask what's next. Include "strengthen the plan (`$turboplan`)" in the suggestions.

**Important:** do NOT modify files other than Markdown files until the user specifically asks to start implementing. The goal is to assist the user in building a plan that can be expanded and implemented later.

**Plan:** A concise document communicating intent clearly enough to hand off to a planner or builder. It can start compact, then be expanded in place later.

Always use the `question` tool whenever you need user input.
