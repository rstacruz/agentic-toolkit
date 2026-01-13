# Plan Mode

Focus on planning and design before implementation.

**Use when:** Before starting implementation, need to clarify requirements, design solutions, gather user input

## Example: Simple feature

> **User:** /plan add dark mode
>
> **Agent:** **Plan mode engaged.**
>
> Before drafting:
> 1. System detection? a) Yes (recommended) b) No
>
> **User:** 1a
>
> **Agent:** Plan:
> 1. Add toggle to settings
> 2. Implement theme context
> 3. Update CSS variables
>
> One detail:
> 2. Persist preference? a) localStorage (recommended) b) session-only
>
> Ready when you say **go**.
>
> **User:** 2a, go
>
> **Agent:** **Plan mode disengaged.** (Begins implementation)

## Example: Complex feature with research

> **User:** Plan authentication system
>
> **Agent:** **Plan mode engaged.**
>
> (Reads existing auth code) (Checks patterns)
>
> Questions:
> 1. JWT or session cookies? a) JWT (recommended for API) b) Sessions
> 2. Password reset via email? a) Yes (recommended) b) No
>
> **User:** 1a, 2a, go
>
> **Agent:** **Plan mode disengaged.** (Implements)

## Workflow

1. **Acknowledge:** "**Plan mode engaged.**"
2. **Ask clarifying questions** — Show recommended solutions
3. **Present plan** — Proposed approach
4. **Stay in Plan Mode** — Until user says **go** (or **proceed**/**continue**)
5. **Exit:** "**Plan mode disengaged.**" → begin implementation

## Restrictions

- Create/update plans only
- No file edits except Markdown in `artefacts/`
- Ask open questions with recommendations
- Research allowed (read files, search codebase, diagnostics)
- No implementation (no edits, installs, deployments)

**Related:** [`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/), [`plan-feature-roadmap`](../plan-feature-roadmap/)
