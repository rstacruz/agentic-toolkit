# Plan with TDD and PRD

Structured planning with PRD (product requirements) and TDD (technical design) before implementation. Plans combine both in a single document, including only the sections relevant to the task.

**Use when:** New features, complex code changes, technical research requiring structured planning

## Example: Plan a feature (combined — default)

> **User:** Plan task notifications
>
> **Agent:** **Now writing a plan.**
>
> (Researches existing patterns) (Asks clarifications)
>
> ```markdown
> # Plan: Task notification system
>
> ## Initial ask
> Add notification system for task updates (real-time + email).
>
> ## Problem statement
> Users miss updates by manually checking task list.
>
> ## Functional requirements
>
> ### F1: Notification events
> - **F1.1. Task comments** — Someone comments on watched task
> - **F1.2. Status changes** — Task status changes
>
> ## Call graph
> [Mermaid: createNotification → enqueueEmail]
>
> ## Pseudocode breakdown
> [Logic flow with reference letters]
>
> ## Testing strategy
> [Tests needed with run commands]
> ```
>
> (Saves to `artefacts/plan-notifications.md`)

## Example: PRD-only plan

> **User:** Write PRD for task notifications
>
> **Agent:** **Now writing a plan (PRD sections).**
>
> (Researches existing patterns) (Asks clarifications)
>
> ```markdown
> # Plan: Task notification system
>
> ## Initial ask
> Add notification system for task updates (real-time + email).
>
> ## Problem statement
> Users miss updates by manually checking task list.
>
> ## Functional requirements
> [F1, F2 with em-dash format]
>
> ## Technical requirements
> [TR1, TR2 with em-dash format]
>
> ## Open questions
> [Clarifying questions with options]
> ```
>
> (Saves to `artefacts/plan-notifications.md`)

## Example: TDD-only plan

> **User:** Draft TDD for task completion
>
> **Agent:** **Now writing a plan (TDD sections).**
>
> (Reads existing code) (Researches patterns)
>
> ```markdown
> # Plan: Task completion tracker
>
> ## Initial ask
> Add task completion feature: mark done w/ timestamp.
>
> ## Call graph
> [Mermaid: POST handler → completeTask → Prisma]
>
> ## Pseudocode breakdown
> [Logic flow with reference letters]
>
> ## Files
> **New:** `src/tasks/complete.ts`
> **Modified:** `prisma/schema.prisma`
>
> ## Testing strategy
> [Tests needed with run commands]
> ```
>
> (Saves to `artefacts/plan-task-completion.md`)

## Example: Research topic

> **User:** Research how to implement real-time notifications
>
> **Agent:** (Researches WebSockets vs SSE) (Checks existing infrastructure)
>
> (Writes findings to `artefacts/discovery-realtime.md`)

## Document types

**Plan (`plan-<title>.md`):** Combined document with PRD and/or TDD sections based on intent. PRD sections: problem statement, solution overview, functional requirements (F1, F1.1...), technical requirements, non-functional requirements, technical constraints, design considerations, user flows (Mermaid). TDD sections: call graph (Mermaid), pseudocode breakdown, data models, files, CSS classes, testing strategy. Shared: initial ask, quality gates, open questions, out of scope.

**Discovery (`discovery-<title>.md`):** Environmental constraints/context — current architecture, existing patterns, technical constraints, database schemas, library research. NOT implementation details.

**Test:** "Would this info still be true with different implementation?" YES → Discovery, NO → Plan (TDD sections)

**Related:** [`plan-mode`](../plan-mode/), [`execute-plan`](../execute-plan/), [`high-density-writing-style`](../high-density-writing-style/)
