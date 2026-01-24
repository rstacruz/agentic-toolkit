# Plan Feature Roadmap

Break down large features into phased delivery roadmaps with dependency diagrams.

**Use when:** Large features requiring phased delivery, multiple interconnected tasks, work spanning sprints, visualizing dependencies

## Example: Auth roadmap

> **User:** Create roadmap for user authentication
>
> **Agent:** (Reads codebase patterns) (Checks for PRD/TDD)
>
> ```markdown
> # Roadmap: User authentication
>
> ## Dependency diagram
>
> graph TD
>     subgraph P1 [Phase 1: Foundation]
>         AUTH1["AUTH-1: DB Schema"]
>     end
>     subgraph P2 [Phase 2: Logic]
>         AUTH2["AUTH-2: Registration"]
>     end
>     subgraph P3 [Phase 3: Interface]
>         AUTH3["AUTH-3: Login Pages"]
>     end
>
>     AUTH1 --> AUTH2
>     AUTH2 --> AUTH3
>
> ## Work breakdown
>
> ### Phase 1: Foundation
> - **AUTH-1: DB Schema** (size S)
>   - Add `email`, `passwordHash` to User model
>   - Generate migration with Prisma
>
> ### Phase 2: Logic
> - **AUTH-2: Registration** (size M)
>   - Server Action for user creation
>   - Validate email uniqueness, password complexity
>
> ### Phase 3: Interface
> - **AUTH-3: Login Pages** (size M)
>   - Build `/signup` and `/login` routes
>   - Form validation and error states
>
> ## Technical considerations
>
> - Ensure bcrypt works with `nodejs_compat` mode
> ```
>
> (Saves to `artefacts/roadmap-auth.md`)

## Example: With clarifications

> **User:** Roadmap for file upload feature
>
> **Agent:** Clarifying questions:
> 1. **Storage:** a) S3 (recommended) b) Local filesystem
> 2. **File types:** a) Images only b) All file types
>
> **User:** 1a, 2a
>
> **Agent:** (Creates roadmap with S3 + image-specific tasks)

## Structure

1. **Dependency diagram** — Mermaid with tasks grouped by phase
2. **Work breakdown** — Detailed tasks by phase
3. **Technical considerations** — Key constraints/risks
4. **Related documents** — Links to PRD, TDD, Discovery

## Task sizing

**S:** Single file, clear scope (add validation, update CSS)  
**M:** Multiple files, moderate complexity (auth flow, search feature)  
**L:** Cross-cutting concerns (refactor data layer, real-time sync)  
**XL:** Very broad scope (multi-tenancy, payment system)  
**XXL:** Too large — break down

Default to **M** if uncertain. Flag **XXL** for breakdown.

**Related:** [`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/), [`plan-mode`](../plan-mode/)
