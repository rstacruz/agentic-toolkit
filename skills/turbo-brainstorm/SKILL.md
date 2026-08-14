---
name: turbo-brainstorm
description: >
  Turns a rough idea into an actionable plan quickly by making reasonable decisions instead of interviewing the user. Use when the user invokes `$turbo-brainstorm`, wants a plan quickly, or prefers minimal back-and-forth. Records judgement calls under `## Decisions` for later review or veto.
---

**Turn a rough idea into an actionable plan quickly, asking questions only when needed.**

## Workflow

**Decide first, ask last.**

- Walk the design tree yourself — make a judgement call per branch; don't interview.
- Document every call under `## Decisions` — each entry needs **Chosen**, **Why**, and **Alternatives**.

1. **Confirm understanding only if genuinely ambiguous.**
   - Before walking the tree, check whether the idea's scope or goal is unclear enough that a wrong read would derail the plan.
   - If ambiguous, use `ask_user_question` to confirm the scope/goal reading before research or decisions.
   - If clear enough, skip to next.

2. **Check relevant context.**
   - Inspect related files, plans, tickets, or discussions when available.

3. **Resolve open decisions.** At each branch, run the decide-first ladder:

   1. If research can answer the branch, find the fact first; it is not itself a judgement call. Then choose the simplest reasonable default unless the findings support another option.
   2. If a reasonable default exists, one option is cheaply reversible, or no option clearly wins, choose the most reasonable default, document it, and move on.
   3. If the choice is costly or irreversible, has no signal, and does not block the plan, decide, document, and mark `⚠️ revisit` so review can catch it.
   4. If all options are costly or irreversible, there is no signal, and the choice blocks the plan, ask the user with `ask_user_question`.

   - If research affects the plan, record it under `## Appendix: Grounded facts`.

4. **Draft and validate the plan.**
   - [ ] Every decision has **Chosen**, **Why**, and **Alternatives**.
   - [ ] Non-goals are explicit.
   - [ ] Post-implementation verification states what to check before merging or deploying.
   - [ ] Apply the `$skimmable` skill if available.

5. **Write the plan.**
   - Filename: `plan-<yyyy>-<mmdd>-<ticket>-<title>.md`; omit `<ticket>-` when unknown. Use lowercase kebab-case for `<ticket>` and `<title>`.
   - Save it beside the relevant `*.metaplan.md`, or under `~/.artefacts/`.
   - Reply with the filename.

6. **Ask what's next.** Use `ask_user_question` with these options:
   - **Start implementing** — begin the work described in the plan
   - **Polish the plan** — run the `$polish-plan` skill first
   - **Review decisions** — check `## Decisions` for weak assumptions or missed alternatives

## General guidelines

- During brainstorming, write or edit Markdown files only; leave source code untouched until the user chooses **Start implementing**.
- Do not add speculative implementation details or dependencies that the plan does not need.
- Use `ask_user_question` for user input, never open-ended prose. Ask about the plan only for genuine ambiguity or when the final ladder rung blocks it.

### Design entries

Design entries are contracts, not prose. Typical entries:

- **Data model** — type definitions, one concrete example value, invariants (rules a lint/test must enforce)
- **State machine** — state + action types, then a transition table (action × guard → result); guards capture the edge cases
- **Storage** — keys, shape, access rules (eg effects-only for `localStorage` in SSR apps)
- **Repo layout** — file tree mapping each artifact to its work item
- **Component tree** — component hierarchy with who owns state and how events flow up

Use code blocks and markdown tables over paragraphs. If a data model has a design fork (eg a field that could be two shapes), record it as a Decision with options + recommendation, and reference it from the Design entry (D10).

## Suggested plan structure

Consider structuring plan files like so. Feel free to add or omit sections as needed:

``````
# Title

- **Date:** yyyy-mm-dd
- **Ticket:** [link](...) or `None`
- **Metaplan:** [link](...) (only if available)

## Context

## Goals
1. …

**Non-goals:**

1. …

## Decisions

### 1. <decision> — `[auto-decided]` or `[user-confirmed]`

- **Chosen:** <option>
- **Why:** <one-line rationale>

**Alternatives:**

- ✗ <runner-up> — <why it lost>

### 2. <decision>

## Design

### <Area title>

- ...

```
...
```

## Implementation steps

### 1. [name]
[include code blocks when useful]

### 2. [name]

## Post-implementation verification

## Risks

<details>
<summary>Expand</summary>

### 1. [name]

</details>

## Appendix: Grounded facts

<details>
<summary>Expand</summary>

### 1. [name]
[context from the codebase and external sources]

Sources:
- [Filename, URL, or identifier]

### 2. [name]

</details>
``````
