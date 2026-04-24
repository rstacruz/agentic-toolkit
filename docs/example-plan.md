# Plan: Per-User Rate Limiting Middleware

> **Note:** This is an example plan produced by the `$brainstorm` skill.
> It shows what a compact planning document can look like after a brainstorm session.

---

## Problem

The API has no protection against request floods from individual users. A single misbehaving client can exhaust server resources and degrade service for everyone else. There is no consistent way to enforce per-user limits across endpoints.

**Who it's for:** The backend engineering team maintaining an Express-based API.

## Success criteria

- Requests exceeding the configured limit return `429 Too Many Requests` with a `Retry-After` header
- Rate limit state is tracked per user (by user ID extracted from a JWT or API key)
- Middleware is easy to attach to any route or router in one line
- Limits and window duration are configurable per route
- Existing routes are not affected until the middleware is explicitly attached

## In scope

- Token bucket algorithm implementation
- Express middleware wrapper
- In-memory storage for token bucket state
- Configuration options (`limit`, `window`, `keyExtractor`)
- Unit tests for the bucket logic and middleware

## Out of scope

- Persistent storage (Redis, database) — in-memory only for now
- Distributed rate limiting across multiple server instances
- Rate limiting by IP (only per-user, authenticated routes)
- Admin UI or dashboard for monitoring rate limit hits

## Why this matters

A single abusive client can take down the API for all users. Per-user rate limiting is the minimum protection needed before opening the API to third-party developers. Without it, the team cannot safely issue API keys.

---

## Illustrative examples

### Attaching the middleware to a route

```js
import { rateLimiter } from './middleware/rateLimiter.js'

// Allow 100 requests per user per 15-minute window
app.use('/api/data', rateLimiter({ limit: 100, windowMs: 15 * 60 * 1000 }))
```

### Per-route customization

```js
// Stricter limit on an expensive endpoint
app.post(
  '/api/export',
  rateLimiter({ limit: 5, windowMs: 60 * 1000 }),
  exportHandler
)
```

### Custom key extractor (default: JWT sub claim)

```js
rateLimiter({
  limit: 50,
  windowMs: 60 * 1000,
  keyExtractor: (req) => req.headers['x-api-key'],
})
```

### 429 response shape

```json
{
  "error": "Too Many Requests",
  "retryAfter": 42
}
```

Response headers:

```
HTTP/1.1 429 Too Many Requests
Retry-After: 42
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1711058400
```

### Token bucket state (in-memory, per user key)

```js
// Internal store — not exposed externally
{
  "user:abc123": { tokens: 0, lastRefill: 1711058358000 },
  "user:def456": { tokens: 87, lastRefill: 1711058300000 },
}
```

---

## Open questions for planner

1. Should the middleware short-circuit before route handlers run, or should the handler be able to opt out?
2. What happens when `keyExtractor` returns `null` — fail open (allow) or fail closed (block)?
3. Should hit counts be exposed in response headers by default, or opt-in?
