---
name: turbo-brainstorm
description: >
  Turns a rough idea into an actionable plan quickly by making reasonable decisions instead of interviewing the user.
---

**Turn a rough idea into an actionable Markdown plan.**

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
- Try not to duplicate content; consider using "Refer to <section>" in later sections when something is mentioned earlier in the doc.
- Use `ask_user_question` for user input, never open-ended prose. Ask about the plan only for genuine ambiguity or when the final ladder rung blocks it.

### Design entries

Design entries are contracts, not prose. Typical entries:

- **Data model** — type definitions, one concrete example value, invariants (rules a lint/test must enforce)
- **State machine** — state + action types, then a transition table (action × guard → result); guards capture the edge cases
- **Storage** — keys, shape, access rules (eg effects-only for `localStorage` in SSR apps)
- **Repo layout** — file tree mapping each artifact to its work item
- **Component tree** — component hierarchy with who owns state and how events flow up

Use code blocks and markdown tables over paragraphs. If a data model has a design fork (eg a field that could be two shapes), record it as a Decision with options + recommendation, and reference it from the Design entry (D10).

### Decision stakes

Tag every entry under `## Decisions` with a **stakes** level — a proxy for how much review attention *the decision itself* needs, not how much code it touches. This is distinct from `### Review effort` below, which grades the diff.

| Tag | Means | Reviewer does |
|---|---|---|
| 🟢 `[low stakes]` | Contained, reversible, no security/persistence angle | Read once, move on |
| 🟡 `[mid stakes]` | Coupled to other code, moderate blast radius | Verify the reasoning holds |
| 🔴 `[high stakes]` | Security-critical, expensive to reverse once shipped, or evidence is thin | Argue it now, before code ships |

Place it as a bullet inside the decision, not in the heading:

```
### 3. Alias key namespace — `[auto-decided]`

- **Stakes:** 🔴 `[high stakes]` — the wrong keyspace opens a hijack path.
- **Chosen:** ...
```

### Review effort

Read [`$pr-risk-assessment`](../pr-risk-assessment/SKILL.md) and apply it.

- Use level names verbatim: 🟢 L1 glance, 🟢 L2 skim, 🟡 L3 spot-check, 🟠 L4 audit, 🔴 L5 war room.
- Format as a nested list, not a paragraph.
- When the plan ships as more than one PR, assess each PR separately.

```
**🔴 L5 — war room.** <one line: why this level, and why the PRs differ>

- **PR-A — <scope>: 🟢 L2 skim**
  - <reason>
  - <reason>
- **PR-B — <scope>: 🔴 L5 war room**
  - <reason>
```

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

## Review effort

**🟢 L2 — skim.** <verbatim level name; rationale as a nested list; per-PR when the plan splits>

## Implementation steps

### 1. [name]
[include code blocks when useful]

### 2. [name]

## Design

### <Area title>

- ...

```
...
```

## Decisions

### 1. <decision> — `[auto-decided]` or `[user-confirmed]`

- **Stakes:** 🔴 `[high stakes]`
- **Chosen:** <option>
- **Why:** <one-line rationale>

**Alternatives:**

- ✗ <runner-up> — <why it lost>

**Affects:**

- `path/file2.ts` → `symbolName`, `name2`

### 2. <decision>

## Post-implementation verification

<details>
<summary>Expand</summary>

...

</details>

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
