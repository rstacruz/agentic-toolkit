# Refine Plan

Refine existing plans (TDD, PRD, roadmaps) before implementation.

**Use when:** After initial plan draft, before implementation starts, when reviewing plans

## Example: Refine TDD

> **User:** Just drafted TDD for auth, refine it
>
> **Agent:** (Reads `artefacts/tdd-auth.md`)
>
> Issues found:
> - **P1:** Missing rate limiting in login flow — brute force risk
> - **P2:** Password validation too weak — suggest min 12 chars, complexity rules
> - **P3:** Consider adding session timeout
>
> (Updates TDD file)
>
> Updated plan saved to `artefacts/tdd-auth.md`.

## Example: Refine PRD inline

> **User:** Refine this PRD (pasted in chat, no file)
>
> **Agent:** (Analyzes PRD content)
>
> Suggestions:
> - **P1:** Missing error handling for failed email delivery
> - **P2:** Add notification preferences to requirements
>
> Updated PRD:
> ```markdown
> ## F3: Error handling
> - **F3.1. Email failures** — Retry 3 times, log failures
> - **F3.2. User preferences** — Allow opting out of emails
> ```

## Example: Plan looks good

> **User:** Refine roadmap
>
> **Agent:** (Reads `artefacts/roadmap-auth.md`)
>
> No issues found. Plan follows patterns, covers edge cases, dependencies properly ordered.

## Focus areas

**Bugs:** Logic errors, missing guards, edge cases, security  
**Impact:** Affected codebase parts  
**Structure:** Follows patterns, uses abstractions  
**Performance:** Obvious O(n²), N+1 queries  
**Consistency:** Aligns with codebase patterns, AGENTS.md guidelines

**Related:** [`refine-implementation`](../refine-implementation/), [`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/)
