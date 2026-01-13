# Execute Plan

Execute implementation plans with verification, review, and documentation.

**Use when:** Transitioning from planning to implementation (TDD/PRD/informal designs)

## Example: Standard execution

> **User:** Plan dark mode feature, use TDD skill
>
> **Agent:** (Creates TDD with test cases, implementation steps, acceptance criteria)
>
> **User:** Execute the plan
>
> **Agent:** (Implements features) (Runs tests) (Verifies implementation) (Reviews with subagent) (Generates changelog)
>
> Final summary:
> ```markdown
> ✅ Done: Dark mode toggle, theme persistence, CSS variables
> ✅ Tests passing (12 new tests), verified, reviewed
>
> ⚠️ Manual verification:
> - Test theme toggle in Safari (localStorage behavior)
> - Verify system preference detection on macOS
> ```

## Example: Roadblocks

> **User:** Execute auth refactor plan
>
> **Agent:** (Implements JWT validation) (Adds session middleware) (Implements rate limiting) (Verifies) (Reviews) (Generates changelog)
>
> Final summary:
> ```markdown
> ✅ Done: JWT validation, session middleware, rate limiting
> ✅ Verified and reviewed
>
> ⚠️ Roadblocks:
> - Redis version incompatible — upgraded to v7
> - Missing env vars — added REDIS_URL to .env.example
> ```

## Example: Prototype mode

> **User:** Quick prototype, skip tests for now
>
> **Agent:** (Implements features) (Skips tests) (Verifies basic functionality)
>
> Notes in summary: "⚠️ Tests skipped (prototype phase)"

**Related:** [`verify-implementation`](../verify-implementation/), [`review-with-subagent`](../review-with-subagent/), [`generate-changelog`](../generate-changelog/), [`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/)
