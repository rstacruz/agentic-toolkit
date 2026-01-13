# Reflect

Distill session learnings into improvements for skills and AGENTS.md.

**Use when:** After completing work, encountering repeated issues, discovering better approaches, user provides corrections

## Example: After repeated clarifications

> **User:** Reflect on this session
>
> **Agent:** (Reviews session) (Identifies repeated database schema questions)
>
> Suggesting addition to AGENTS.md:
>
> ```markdown
> ## Database
> - Using PostgreSQL via Prisma ORM
> - Schema defined in `prisma/schema.prisma`
> - Run migrations: `npx prisma migrate dev`
> ```
>
> Also updating `plan-with-tdd-and-prd` skill:
>
> ```markdown
> **Before drafting TDD:**
> - Always check `prisma/schema.prisma` for existing data models
> ```
>
> (Updates files)

## Example: Better pattern discovered

> **User:** Reflect
>
> **Agent:** (Reviews work) (Found better error handling pattern)
>
> Updating AGENTS.md:
>
> ```markdown
> ## Error handling
> - Use Result objects: `{ ok: boolean, result: string, data?: T, error?: string }`
> - Never throw for operational errors
> - See `src/lib/result.ts` for helpers
> ```
>
> (Saves changes)

## Goal

Guide future agents to: understand user intent better, accomplish tasks with less effort, discover hard-to-find information easier, troubleshoot errors better

**Related:** All skills (improves them), AGENTS.md (project guidelines)
