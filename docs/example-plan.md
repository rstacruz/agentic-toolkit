> **Note:** This is an example plan produced by the brainstorm skill.

---

# Per-User Rate Limiting Middleware

- **Date:** 2025-01-15
- **Ticket:** [PLAT-412](https://linear.app/example/issue/PLAT-412)

## Context

The API has no per-user request throttling. A single client can flood any endpoint, degrading service for all other users. This blocks the safe issuance of API keys to third-party developers.

## Goals

1. Reject over-quota requests with HTTP 429 and standard rate-limit headers
2. Apply limits per authenticated user within a configurable time window
3. Attach middleware in a single call to any Express route or router

**Non-goals:**

- IP-based rate limiting
- Distributed / multi-instance coordination
- Admin dashboard or monitoring

## Decisions

- Use **token bucket** algorithm — simpler than sliding window, constant memory per user
- **In-memory store** only this iteration — no Redis dependency on the hot path
- **Fail open** on unauthenticated requests — null key extractor result → `next()`
- Default key extractor reads **JWT `sub` claim** without verification

## Implementation steps

### 1. Define types (`src/middleware/types.ts`)

```ts
interface BucketState {
  tokens: number      // current count (float)
  lastRefill: number  // Unix ms of last refill
}

interface RateLimiterOptions {
  limit: number
  windowMs: number
  keyExtractor?: (req: Request) => string | null
  store?: BucketStore
}
```

### 2. Token bucket logic (`src/middleware/tokenBucket.ts`)

```ts
function refill(bucket: BucketState, options: RateLimiterOptions, now = Date.now()) {
  const rate = options.limit / options.windowMs
  bucket.tokens = Math.min(options.limit, bucket.tokens + (now - bucket.lastRefill) * rate)
  bucket.lastRefill = now
}

function consume(bucket: BucketState, options: RateLimiterOptions): ConsumeResult {
  refill(bucket, options)
  if (bucket.tokens >= 1) {
    bucket.tokens -= 1
    return { allowed: true, remaining: Math.floor(bucket.tokens) }
  }
  return { allowed: false, retryAfter: Math.ceil(1 / (options.limit / options.windowMs) / 1000) }
}
```

### 3. In-memory store (`src/middleware/memoryStore.ts`)

```ts
class MemoryStore {
  private map = new Map<string, BucketState>()

  consume(key: string, options: RateLimiterOptions): ConsumeResult {
    const now = Date.now()
    const bucket = this.map.get(key) ?? { tokens: options.limit, lastRefill: now }
    const result = consume(bucket, options, now)
    this.map.set(key, bucket)
    return result
  }
}
```

### 4. Middleware factory (`src/middleware/rateLimiter.ts`)

```ts
export function rateLimiter(options: RateLimiterOptions): RequestHandler {
  const store = options.store ?? new MemoryStore()
  const keyExtractor = options.keyExtractor ?? defaultKeyExtractor

  return (req, res, next) => {
    const key = keyExtractor(req)
    if (!key) return next()

    const result = store.consume(key, options)
    res.set('X-RateLimit-Limit', options.limit)
    res.set('X-RateLimit-Remaining', result.remaining)

    if (result.allowed) return next()
    if (result.retryAfter) res.set('Retry-After', result.retryAfter)
    res.status(429).json({ error: 'Too Many Requests' })
  }
}
```

### 5. Attach to routes

```ts
// Single route
router.get('/data', rateLimiter({ limit: 100, windowMs: 60_000 }), handler)

// Whole router
apiRouter.use(rateLimiter({ limit: 1000, windowMs: 3_600_000 }))
```

## Risks

### 1. Memory growth

Buckets are never evicted. Long-lived processes with many unique users will accumulate state indefinitely. Acceptable for now; add TTL-based eviction if memory pressure is observed.

### 2. Clock skew on restart

In-memory state is lost on process restart — all buckets reset to full. Could allow a burst immediately after a restart.

## Post-implementation verification

- `curl` a rate-limited endpoint 101 times in a row — confirm 429 on request 101 with `Retry-After` header
- Restart the server mid-window and confirm no crash or error on first request
- Check that an unauthenticated route bypasses the middleware entirely (no 429, no headers)
- `npx vitest run src/middleware/` — all tests green
- `npx tsc --noEmit` — no type errors

## Appendix: Grounded facts

### 1. Existing auth middleware

JWT verification already runs in `src/middleware/auth.ts` and attaches `req.user.sub`. The rate limiter can read from `req.user` as a faster alternative to re-decoding the token.

Sources:
- `src/middleware/auth.ts:34`

### 2. No existing rate limit headers

Confirmed via `grep -r "X-RateLimit" src/` — nothing sets these headers today. Safe to introduce.

Sources:
- `grep -r "X-RateLimit" src/`

