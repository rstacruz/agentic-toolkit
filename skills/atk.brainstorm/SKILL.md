---
name: brainstorm
description: Help the user develop a vague idea into a "pre-plan" — a scoped, handoff-ready statement of intent
---

The user shares a rough idea. Guide them to a **pre-plan** through targeted questioning — ask about intent, scope, and success criteria; point out blind spots; suggest alternative framings.

**What is a pre-plan?**

- A concise document communicating intent clearly enough to hand off to a planner or builder.
- It can start compact, then be expanded in place later.

**Rate readiness after each exchange:**

- `NEEDS_REFINEMENT` — critical gaps remain. State which gaps and ask 1-5 follow-up questions.
- `READY_FOR_PLANNING` — all planning criteria met. This is the ideal phase.
- `READY_FOR_EXECUTION` — all planning + execution criteria met. This is a stretch goal reserved for very simple changes.

**READY_FOR_PLANNING criteria:**

- What problem is being solved (for whom)
- What success looks like (measurable or demonstrable outcomes)
- What is in/out of scope (explicit boundaries)
- Why this problem is important — always ask the user via the `question` tool; suggest reasons to pick from; never infer it yourself

**READY_FOR_EXECUTION criteria:** All planning criteria, plus the ones below:

- **Implementation path is obvious** — no design decisions remain; a competent engineer could start immediately
- **Scope is narrow** — touches a single file or tightly bounded area; no cross-cutting concerns
- **Single deliverable** — one concrete task, not a breakdown of sub-tasks

**Explore options:** Use this decision framing before lock-in to engage the user in coming up with solutions:

- Once the user's answers narrow the space, do not jump straight to a concrete pre-plan if a meaningful design choice still remains.
- Reflect back what changed. Name the main tradeoffs. Present `2-3` viable options with a short label, one-line shape, and brief pros/cons. State your current leaning and why.
- Ask only the minimum follow-up questions needed to lock direction.
- Skip the option list only when the implementation path is already obvious.

**When done:** upon reaching READY_FOR_PLANNING or READY_FOR_EXECUTION:

- Write the pre-plan to `artefacts/plan-<title>.md`.
- Reply with the filename, then use the `question` tool to ask what's next. Include "strengthen the plan (`$turboplan`)" in the suggestions.

**Important:** do NOT modify files other than Markdown files until the user specifically asks to start implementing. The goal is to assist the user in building a plan that can be expanded and implemented later.

Always use the `question` tool whenever you need user input.
