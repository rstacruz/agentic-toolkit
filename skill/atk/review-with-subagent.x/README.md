# Review with Subagent

Spawn subagent to review changes against plan and quality standards.

**Use when:** After implementation and verification complete, part of [`execute-plan`](../execute-plan/) workflow

## Example: Review finds issues

> **User:** Implement auth feature
>
> **Agent:** (Implements) (Verifies tests pass)
>
> Now spawning subagent for review...
>
> **Subagent review:**
> ```
> ### [P1] Missing rate limiting
> - See: auth/login.ts:45
> - Plan requires 5 attempts per 15min, not implemented
> - Add rate limiting middleware before login handler
>
> ### [P2] Extract magic number
> - See: auth/login.ts:89
> - Define MAX_PASSWORD_LENGTH = 128 constant
> ```
>
> **Agent:** (Fixes P1 issue) (Fixes P2 issue) (Re-verifies)
>
> ✅ Tests pass. Review complete.

## Example: Clean review

> **Agent:** (After implementing feature)
>
> Spawning subagent for review...
>
> **Subagent:** No issues found. Implementation matches plan. Code quality good.
>
> **Agent:** Review complete. No changes needed.

## Review criteria

Subagent checks: plan alignment, code quality, potential bugs, architecture decisions, security vulnerabilities, documentation consistency

**Related:** [`execute-plan`](../execute-plan/), [`verify-implementation`](../verify-implementation/), [`refine-implementation`](../refine-implementation/)
