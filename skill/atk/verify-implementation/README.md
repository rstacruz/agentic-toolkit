# Verify Implementation

Mandatory verification after code changes.

**Use when:** After making code changes, before considering work complete, part of implementation workflow

## Example: Clean verification

> **Agent:** (After implementing auth feature)
>
> Running preflight checks...
> - `npm run lint` ✅
> - `npm run type-check` ✅
>
> Running tests...
> - `npm test src/auth/login.test.ts` ✅ All pass
>
> Manual verification:
> - Started dev server: `npm run dev`
> - Tested login flow: ✅ Success
> - Tested rate limiting: ✅ Blocks after 5 attempts
> - Screenshot: `artefacts/login-success.png`
>
> Verification complete.

## Example: Type errors found

> **Agent:** (After code changes)
>
> Running preflight checks...
> - `npm run type-check` ❌ 3 errors found
>
> (Fixes type errors) (Re-runs checks)
>
> - `npm run type-check` ✅
>
> Tests...
> - `npm test` ✅
>
> Verification complete.

## Example: Browser UI verification

> **Agent:** (After implementing notification panel)
>
> Manual verification:
> - Opened `/dashboard` in browser
> - Verified notification bell shows unread count: ✅
> - Clicked bell, panel opens: ✅
> - Screenshot: `artefacts/notification-panel.png`
>
> All checks passed.

## Verification steps

1. **Preflight:** Lint, format, type-check — fix issues before proceeding
2. **Automated:** Run relevant tests (focus on changed areas, avoid full suite when possible)
3. **Manual:** CLI output, UI verification (browser/DevTools), database queries, screenshots to `artefacts/`

**Common commands:** `npm run lint`, `npm run format`, `npm run type-check`, `npx biome check`

**Related:** [`execute-plan`](../execute-plan/), [`review-with-subagent`](../review-with-subagent/)
