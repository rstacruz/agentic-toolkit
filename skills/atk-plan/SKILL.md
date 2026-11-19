---
name: atk-plan
description: >
  Plans the given change non-interactively — decides for the user, never asks — using a compact plan format saved to a file.
---

Plan the given change. Decide for the user; never ask.

## Goals

- [ ] Saved to a Markdown file
- [ ] Lists decisions
- [ ] No duplication across `## Design`, `## Implementation steps`, and `## PR's`

## Guidelines

- Read related files, plans, and tickets first.
- Order the plan: Decisions → Design → Implementation steps → PR's.
- `## Design` owns contracts exactly once: data model, state, storage, types, markup, CSS, component tree. `## Implementation steps` is one line per step: files — action — done when. Never repeat a Design code block or attribute list; write `Apply Design → <section>` and keep only the step-specific delta.
- In `## Design`, mark code with `/* 🟢 New */`, `/* 🟡 Updated */`, or `/* 🔴 Removed */` so the design shows the change, not just the end state.
- Give examples in `## Design` when they make a contract concrete: sample rows for each new table, a request and response for each API operation, a before and after value, and one refusal or error case. Use one scenario (same ids and values) across all examples so they read as a story. Mark made-up data as illustrative; copy real output when you ran something and say how. Skip examples for contracts that are self-evident, and never repeat them in `## Implementation steps`.
- Keep steps terse: name only the narrow test that proves the step; exhaustive cases belong in tests, not the plan.
- Group the steps into `## PR's` as a nested list: each PR names its steps, one-line scope, and dependencies. Keep the grouping out of `## Implementation steps`.
- Grade `## Review effort` per `/pr-risk-assessment` when available.
- Rate every decision's risk as `🟢 low`, `🟡 med`, or `🔴 high` by the cost of being wrong (data loss, privacy, concurrency, live migrations, public contracts), not the size of the change. The line says what breaks if the decision is wrong, not why it's safe: `🟢 low — if wrong, callers get a no-op instead of an error`. Worst-hit-wins: a `🔴 high` decision makes `## Review effort` at least L4.
- Facts that shape the plan go under `## Appendix: Grounded facts`, with sources.
- No speculative details or dependencies; refer to earlier sections instead of repeating them.
- Write or edit Markdown only; leave source code untouched.
- Save to `~/.artefacts/plan-<yyyy-mm-dd>-<ticket>-<title>.md` (`<ticket>` omitted when unknown); reply with the path.
- After saving, show decisions in chat for user to challenge.

## Format

``````
# <Title>

- **Date:** yyyy-mm-dd
- **Ticket:** <link> or `None`

## Context

## Goals
1. …

**Non-goals:**

1. …

## Review effort

**<level> — <name>.** <one line: why>

## Decisions

### 1. <decision>

- **Chosen:** <option>
- **Why:** <one line>
- **Risk:** 🟢 low / 🟡 med / 🔴 high — <one line: what breaks if this is wrong>

**Alternatives:**

- ✗ <runner-up> — <why it lost>

**Affects:**

- `path/file.ts` → `symbolName`

## Design

<single source of truth for contracts: data model, state machine, storage, types, markup, CSS, repo layout, component tree. Mark code with `/* 🟢 New */`, `/* 🟡 Updated */`, or `/* 🔴 Removed */`.>

```<lang>
/* 🟢 New */
...
/* 🟡 Updated */
...
/* 🔴 Removed */
...
```

<examples when relevant, as `### Examples` or one sub-section per contract (eg `### Example rows`, `### GraphQL examples`): illustrative unless produced by a run; say which.>

## Implementation steps

<one line per step: files — action (reference `Design → <section>`) — done when. PR grouping lives in `## PR's`.>

### 1. <name>
`path/a`, `path/b` — <action; see Design → <section>>. Done when <observable result>.

## PR's

1. **PR 1 — <name>**
   - Steps: …
   - Includes: …
   - Depends on: …
2. **PR 2 — <name>**
   - Steps: …
   - Includes: …
   - Depends on: …

## Risks

## Appendix: Grounded facts

<details>
<summary>Expand</summary>

### 1. <name>
<fact from the codebase or external source>

Sources:
- `path/file.ts:12`

</details>
``````
