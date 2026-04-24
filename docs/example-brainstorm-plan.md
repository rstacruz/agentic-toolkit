# Plan: Per-User Rate Limiting Middleware

> **Note:** This is an example plan produced by the `$brainstorm` skill.
> It shows what a compact planning document can look like after a brainstorm session.

---

## Problem

The API has no protection against request floods from individual users. A single misbehaving client can degrade service for everyone else, and the team cannot safely issue third-party API keys without a basic per-user limit.

**Who it's for:** The backend engineering team maintaining an Express-based API.

## Success criteria

- Requests exceeding the configured limit return `429 Too Many Requests` with a `Retry-After` header
- Rate limit state is tracked per user
- Middleware is easy to attach to any route or router in one line
- Limits and window duration are configurable per route
- Existing routes are unchanged until the middleware is attached

## In scope

- Express middleware for per-user rate limiting
- In-memory token bucket state
- Configurable `limit`, `window`, and user key extraction
- Unit tests for limiter behavior

## Out of scope

- Persistent storage (Redis, database) — in-memory only for now
- Distributed rate limiting across multiple server instances
- Admin UI or monitoring dashboard

---

## Open questions for planner

1. Should requests without a user key fail open or fail closed?
2. Should the default key extractor use JWT `sub`, API key, or require explicit configuration?
3. Do we need standard rate-limit headers on every response or only on `429` responses?
