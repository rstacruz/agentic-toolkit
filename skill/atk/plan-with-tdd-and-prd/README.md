# Plan with TDD and PRD

Structured planning with PRD (product requirements) and TDD (technical design) before implementation.

**Use when:** New features, complex code changes, technical research requiring structured planning

## Example: Write PRD for notifications

> **User:** Write PRD for task notifications
>
> **Agent:** **Now writing a PRD.**
>
> (Researches existing notification patterns) (Asks clarifications)
>
> ```markdown
> # PRD: Task notification system
>
> ## Initial ask
> Add notification system for task updates (real-time + email).
>
> ## Functional requirements
>
> ### F1: Notification events
> - **F1.1. Task comments** — Someone comments on watched task
> - **F1.2. Status changes** — Task status changes
> - **F1.3. Mentions** — Mentioned in comments
>
> ### F2: Notification delivery
> - **F2.1. Real-time** — In-app within 2 seconds
> - **F2.2. Email** — Within 5 minutes
> ```
>
> (Saves to `artefacts/prd-notifications.md`)

## Example: Write TDD after PRD

> **User:** Now write TDD for this
>
> **Agent:** **Now writing a TDD.**
>
> (Reads PRD) (Researches database schema, API patterns)
>
> ```markdown
> # TDD: Task notifications
>
> ## Call graph
>
> graph LR
>   subgraph "notify.ts"
>     A["createNotification"]:::new
>   end
>   subgraph "email.ts"
>     B["sendEmail"]:::updated
>   end
>   A -->|"triggers"| B
>
> ## Pseudocode
>
> \`\`\`sh
> # == notify.ts ==
>
> createNotification(userId, taskId, type) # [🟢 NEW]
>   → notification = { userId, taskId, type, read: false }
>   → prisma.notification.create({ data: notification })
>   → sendEmail(user.email, notification)
> \`\`\`
>
> ## Data models
>
> interface Notification {
>   id: string
>   userId: string
>   taskId: string
>   type: "comment" | "status" | "mention"
>   createdAt: Date
>   read: boolean
> }
> ```
>
> (Saves to `artefacts/tdd-notifications.md`)

## Example: Research topic

> **User:** Research how to implement real-time notifications
>
> **Agent:** (Researches WebSockets vs SSE) (Checks existing infrastructure)
>
> (Writes findings to `artefacts/discovery-realtime.md`)

## Document types

**Discovery (`discovery-<title>.md`):** Environmental constraints/context — current architecture, existing patterns, technical constraints, database schemas, library research. NOT implementation details.

**PRD (`prd-{slug}.md`):** Product requirements — initial ask, problem statement, solution overview, functional requirements (F1, F1.1...), non-functional requirements, technical constraints, design considerations, user flows (Mermaid), open questions, out of scope.

**TDD (`tdd-<feature>.md`):** Technical design — call graph (Mermaid), pseudocode breakdown, data models, files (new/modified/removed), CSS classes (list only), testing strategy, open questions.

**Test:** "Would this info still be true with different implementation?" YES → Discovery, NO → TDD

**Related:** [`plan-mode`](../plan-mode/), [`plan-feature-roadmap`](../plan-feature-roadmap/), [`execute-plan`](../execute-plan/), [`high-density-writing-style`](../high-density-writing-style/)
