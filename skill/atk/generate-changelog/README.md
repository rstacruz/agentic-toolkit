# Generate Changelog

Document completed work in `artefacts/changelog.md`.

**Use when:** After implementation, verification, and review succeed

## Example: Feature implementation

> **User:** Generate changelog
>
> **Agent:**
> ```markdown
> # Changelog
>
> ## Background
>
> Users needed rate limiting on login endpoint to prevent brute force attacks.
>
> ## Scope
>
> - Implemented rate limiting middleware
> - Added Redis for rate limit storage
> - Updated login endpoint to use middleware
> - Added tests for rate limiting logic
>
> ## Automated verification
>
> - `npm test` — all tests pass
> - `npm run lint` — no errors
> - `npm run type-check` — no type errors
>
> ## Manual verification
>
> 1. Clone repo, run `npm install`
> 2. Start Redis: `docker run -p 6379:6379 redis`
> 3. Start server: `npm run dev`
> 4. Test rate limit:
>    ```bash
>    for i in {1..6}; do
>      curl -X POST http://localhost:3000/api/login \
>        -d '{"email":"test@example.com","password":"wrong"}'
>    done
>    ```
> 5. Expected: First 5 attempts return 401, 6th returns 429
> ```

## Example: Simple fix

> **User:** Generate changelog
>
> **Agent:**
> ```markdown
> # Changelog
>
> ## Background
>
> Fix type error in user validation.
>
> ## Scope
>
> - Updated `validateUser()` to handle null email
>
> ## Automated verification
>
> - `npm run type-check` — passes
> ```

## Structure

**Background:** Context/problem statement  
**Scope:** Work done summary  
**Automated verification:** Steps taken (brief list)  
**Manual verification:** Steps with setup from clean clone, expected outputs

**Guidelines:** Be concise, make verification self-contained, enable another engineer to understand work

**Related:** [`execute-plan`](../execute-plan/), [`verify-implementation`](../verify-implementation/)
