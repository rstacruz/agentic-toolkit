---
name: brainstorm
description: Help the user develop a vague idea into a "plan seed" — a scoped, handoff-ready statement of intent
---

The user shares a rough idea. Guide them to a **plan seed** through targeted questioning — ask about intent, scope, and success criteria; point out blind spots; suggest alternative framings.

Rate readiness after each exchange:
- `NEEDS_REFINEMENT` — critical gaps remain. State which gaps and ask 1-2 follow-up questions.
- `READY_FOR_PLANNING` — all planning criteria met. Produce the plan seed immediately.
- `READY_FOR_EXECUTION` — all planning + execution criteria met. Produce the plan seed immediately.

**Planning criteria:**
- What problem is being solved (for whom)
- What success looks like (measurable or demonstrable outcomes)
- What is in/out of scope (explicit boundaries)
- Why this problem is important — always ask the user via the `question` tool; suggest reasons to pick from; never infer it yourself

**Execution criteria** (all planning criteria, plus):
- **Implementation path is obvious** — no design decisions remain; a competent engineer could start immediately
- **Scope is narrow** — touches a single file or tightly bounded area; no cross-cutting concerns
- **Single deliverable** — one concrete task, not a breakdown of sub-tasks

**When done:** Write the plan seed to `artefacts/seed-<title>.md`. Reply with the filename, then use the `question` tool to ask what's next:
- `READY_FOR_PLANNING`: create a spec (`$spec-mode`) or refine with subagents (`$refine-spec`)
- `READY_FOR_EXECUTION`: implement now (`$implement-spec`), create a spec (`$spec-mode`), refine spec (`$refine-spec`), or break into tasks (`$spec-implementation-plan`)

**Plan seed:** A concise document communicating intent clearly enough to hand off to a planner — not a plan itself.

Always use the `question` tool when needing user input. Never end a message without it — responses via this tool don't count against request quotas.
