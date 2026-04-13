> **Note:** This is an example spec from the planning workflow.
> It demonstrates what a full spec document looks like, derived from a plan seed.
> Source seed: [`example-seed.md`](./example-seed.md)

---

# Spec: Per-User Rate Limiting Middleware

## Initial ask

Add per-user rate limiting middleware to the Express API. Each authenticated user gets a configurable request quota per time window using a token bucket algorithm. Exceeded quotas return HTTP 429 with standard rate limit headers.

## Problem statement

API has no per-user request throttling. Single client can flood any endpoint, degrading service for all other users. Blocks safe issuance of API keys to third-party developers.

## Solution overview

1. Token bucket middleware factory — configurable limit, window, and key extractor
2. In-memory per-user bucket store — no external dependencies
3. Standard rate limit headers on every response
4. Fail-open on unauthenticated requests
5. Single-call attachment to any Express route or router

## Functional requirements

- **F1 — Rate limit enforcement** — Requests exceeding per-user limit within window rejected with HTTP 429
- **F2 — Response headers** — Every response includes `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`; rejected requests add `Retry-After`
- **F3 — Configurable key extractor** — User key derived via configurable `keyExtractor` function; default: JWT `sub` claim
- **F4 — Configurable limit/window** — Limit and window duration configurable per middleware instance
- **F5 — Fail open** — `keyExtractor` returning `null`/`undefined` passes request through unchanged
- **F6 — Single-call attachment** — Middleware attaches to any Express route or router in one call
- **F7 — Route isolation** — Routes without middleware attached are unaffected

## Technical requirements

- **TR1 — Token bucket algorithm** — Continuous refill: tokens replenish proportionally to elapsed time; never exceed `limit`
- **TR2 — In-memory store** — `Map<string, BucketState>`; no Redis or external dependency
- **TR3 — JWT decoding** — `defaultKeyExtractor` decodes JWT without verification; extracts `payload.sub`; returns `null` on missing/malformed header
- **TR4 — Factory interface** — `rateLimiter(options): RequestHandler` returns Express-compatible handler

## Non-functional requirements

- **NF1 — Latency** — < 1 ms overhead per request for bucket check
- **NF2 — Zero external deps** — In-memory only for this iteration
- **NF3 — Thread safety** — Single Node.js process; no locking required

## Technical constraints

- **TC1 — In-memory only** — No Redis or database in this iteration
- **TC2 — Single instance** — Does not support distributed deployments
- **TC3 — Authenticated routes only** — Rate limiting applies only where a user key is extractable

## Design considerations

- **DC1 — Fail open caveat** — F5 means unauthenticated routes must not attach this middleware; document clearly
- **DC2 — Header exposure** — Rate limit headers included by default; helps clients back off gracefully
- **DC3 — Token bucket over sliding window** — Simpler implementation; constant memory per user

## Out of scope

- IP-based rate limiting
- Persistent storage adapters
- Admin dashboard or monitoring
- Distributed / multi-instance coordination

## Call graph

```mermaid
flowchart TD
  subgraph mw["middleware/rateLimiter.ts"]
    A["rateLimiter(options) [🟢 NEW] [A]"]
    E["defaultKeyExtractor(req) [🟢 NEW] [E]"]
  end

  subgraph ms["middleware/memoryStore.ts"]
    D["MemoryStore.consume() [🟢 NEW] [D]"]
  end

  subgraph tb["middleware/tokenBucket.ts"]
    C["consume(bucket) [🟢 NEW] [C]"]
    B["refill(bucket) [🟢 NEW] [B]"]
  end

  A -->|"calls"| E
  A -->|"calls"| D
  D -->|"calls"| C
  C -->|"calls"| B
```

## Data models

```ts
interface BucketState {
  tokens: number      // current count (float)
  lastRefill: number  // Unix ms of last refill
}
// Store: Map<string, BucketState>
```

```ts
interface RateLimiterOptions {
  limit: number
  windowMs: number
  keyExtractor?: (req: Request) => string | null
  store?: BucketStore
}
```

```ts
interface ConsumeResult {
  allowed: boolean
  remaining: number    // tokens left after request
  resetAt: number      // Unix ms when bucket fully refills
  retryAfter?: number  // seconds until next token (only when !allowed)
}
```

## Pseudocode breakdown

`[A]` **Middleware handler** — request entry point

```sh
rateLimiter(options) → RequestHandler: # [🟢 NEW] [A]
  key = (options.keyExtractor ?? defaultKeyExtractor)(req)  # [E]
  if key is null → return next()
  result = store.consume(key, options)  # [D]
  setHeaders(res, result, options)
  if result.allowed → next()
  else → res.status(429).json(...)
```

`[B]` **Refill** — replenish tokens by elapsed time

```sh
refill(bucket, options, now): # [🟢 NEW] [B]
  tokensPerMs = options.limit / options.windowMs
  bucket.tokens = min(limit, bucket.tokens + (now - bucket.lastRefill) * tokensPerMs)
  bucket.lastRefill = now
```

`[C]` **Consume** — refill then deduct one token

```sh
consume(bucket, options, now): # [🟢 NEW] [C]
  refill(bucket, options, now)  # [B]
  if bucket.tokens >= 1:
    bucket.tokens -= 1
    return { allowed: true, remaining: floor(bucket.tokens) }
  else:
    return { allowed: false, retryAfter: ceil(...) }
```

`[D]` **Memory store** — get-or-create, persist

```sh
MemoryStore.consume(key, options): # [🟢 NEW] [D]
  bucket = map.get(key) ?? { tokens: options.limit, lastRefill: now }
  result = consume(bucket, options, now)  # [C]
  map.set(key, bucket)
  return result
```

`[E]` **Default key extractor** — JWT `sub` claim

```sh
defaultKeyExtractor(req): # [🟢 NEW] [E]
  token = req.headers.authorization?.split(' ')[1]
  payload = jwt.decode(token)  // no verification
  return payload?.sub ?? null
```

## Files

**New:** `src/middleware/rateLimiter.ts`, `src/middleware/tokenBucket.ts`, `src/middleware/memoryStore.ts`, `src/middleware/types.ts`, `src/middleware/rateLimiter.test.ts`, `src/middleware/tokenBucket.test.ts`, `src/middleware/memoryStore.test.ts`, `src/middleware/README.md`

## Testing strategy

**Run:** `npx vitest src/middleware/`

**Mocks:** none (in-memory; no I/O)

**Tests:**
- Token bucket: refill math, boundary at exactly 0 tokens, tokens never exceed limit, `retryAfter` accuracy
- MemoryStore: state persists across calls, new keys initialised at full limit
- Middleware: 200 on first N requests, 429 on N+1, correct headers, null key = pass-through, custom `keyExtractor`
- Integration (supertest): full Express app, route with/without middleware, window reset after `windowMs`

## Quality gates

```sh
npx vitest run
npx tsc --noEmit
npx eslint src/middleware/
```

## Ticket dependencies

```mermaid
graph LR
  T1["T1: Token bucket"] --> T2["T2: Memory store"]
  T1 --> T3["T3: Key extractor"]
  T2 --> T4["T4: Middleware factory"]
  T3 --> T4
  T4 --> T5["T5: Tests"]
  T4 --> T6["T6: Docs"]
  T5 --> T7["T7: Final verification"]
  T6 --> T7
```

## Tickets

### T1 — Core token bucket logic

**Description:** As a developer, I want pure token bucket functions so that rate limiting logic is testable in isolation.

**Acceptance criteria:**
- [ ] `BucketState`, `RateLimiterOptions`, `ConsumeResult` interfaces defined in `types.ts`
- [ ] `refill(bucket, options, now?)` mutates bucket in place [B]
- [ ] `consume(bucket, options, now?)` calls refill, returns `ConsumeResult` [C]
- [ ] No Express dependency
- [ ] `tokenBucket.test.ts` passes

---

### T2 — In-memory store

**Description:** As a developer, I want a `MemoryStore` class so that bucket state persists across requests per user.

**Acceptance criteria:**
- [ ] `Map<string, BucketState>` internal store
- [ ] `consume(key, options)` — get-or-create bucket, delegate to T1, persist [D]
- [ ] `clear()` — empties map (test helper)
- [ ] Bucket state persists across calls for same key

---

### T3 — Default key extractor

**Description:** As a developer, I want a default key extractor so that the middleware works out-of-the-box with JWT auth.

**Acceptance criteria:**
- [ ] Reads `Authorization: Bearer <token>` header
- [ ] Decodes JWT without verification via `jsonwebtoken.decode`
- [ ] Returns `payload.sub` as string, or `null` [E]
- [ ] Returns `null` for missing or malformed header

---

### T4 — Middleware factory

**Description:** As a developer, I want `rateLimiter(options)` so that I can attach rate limiting to any Express route in one call.

**Acceptance criteria:**
- [ ] Uses `MemoryStore` by default (or `options.store`)
- [ ] Uses `defaultKeyExtractor` by default (or `options.keyExtractor`)
- [ ] Null key → `next()` (fail open) [A]
- [ ] Sets `X-RateLimit-*` headers on every request
- [ ] Returns 429 + JSON body with `retryAfter` when limit exceeded
- [ ] Attaches to Express app in one line

---

### T5 — Tests

**Description:** As a developer, I want full test coverage so that behaviour is verified at all layers.

**Acceptance criteria:**
- [ ] Token bucket: refill math, boundary conditions, `retryAfter` accuracy
- [ ] MemoryStore: state persistence, initial bucket at full limit
- [ ] Middleware: 200 on first N requests, 429 on N+1, correct headers, null key pass-through, custom `keyExtractor`
- [ ] Integration (supertest): window reset after `windowMs`
- [ ] All tests pass

---

### T6 — Usage documentation

**Description:** As an API developer, I want a README so that I can quickly integrate the middleware.

**Acceptance criteria:**
- [ ] Install / import instructions
- [ ] Basic one-liner usage example
- [ ] Options reference table
- [ ] Custom `keyExtractor` example
- [ ] Known limitations: in-memory, single-instance only

---

### T7 — Final verification

**Description:** As a developer, I want all quality gates to pass so that the feature is production-ready.

**Acceptance criteria:**
- [ ] `npx vitest run` — all tests pass
- [ ] `npx tsc --noEmit` — no type errors
- [ ] `npx eslint src/middleware/` — no lint errors
- [ ] Remove TODO/debug comments from implementation
- [ ] JSDoc limited to 2 lines max where present
