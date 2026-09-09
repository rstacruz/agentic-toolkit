---
name: atk-plan
description: >
  Turns a rough idea into an actionable plan quickly by making reasonable decisions instead of interviewing the user.
---

**Turn a rough idea into an actionable Markdown plan.**

## Input

- `$request` — the rough idea to turn into a plan
- `--interactive` — ask the user before proceeding on 🟡 mid-stakes or 🔴 high-stakes decisions

## Skill dependencies

Read first:

- `/pr-risk-assessment` — grades the `## Review effort` section
- `/skimmable` — apply to the plan doc when available

## Workflow

**Decide first, ask last.**

```pseudocode
begin($request, { --interactive }) {
  # -- phase 1: understand --
  if (scope or goal genuinely ambiguous) {
    ask_user_question("confirm the scope/goal reading")
  }

  # -- phase 2: gather --
  $facts = gather-context()

  # -- phase 3: decide --
  $decisions = decide($request, $facts, { --interactive })

  # -- phase 4: draft --
  $plan = draft($request, $decisions)
  validate($plan)
  if (skimmable available) { apply /skimmable formatting to $plan }

  # -- phase 5: write --
  $path = save-plan($request)
  reply with $path
}
```

### gather-context()

Inspect related files, plans, tickets, or discussions when available. If research affects the plan, record it under `## Appendix: Grounded facts`.

### decide()

Walk the design tree yourself — make a judgement call per branch; don't interview. At each branch, run the decide-first ladder:

```pseudocode
def decide($request, $facts, { --interactive }) {
  for each ($branch in the design tree) {
    $asked = false

    if (research can answer $branch) {
      find the fact first      # the fact is not itself a judgement call
      choose the simplest reasonable default unless findings support another option
      record the fact under `## Appendix: Grounded facts` if it affects the plan
    } else if (a reasonable default exists
        or one option is cheaply reversible
        or no option clearly wins) {
      choose the most reasonable default
    } else if (not blocking the plan) {
      decide and mark "⚠️ revisit"   # costly/irreversible, no signal — review catches it
    } else {
      $answer = ask_user_question($branch)  # all costly/irreversible, no signal, blocks the plan
      $asked = true
    }

    assign a stakes level — see Decision stakes
    document under `## Decisions`: Chosen + Why + Alternatives

    if (not $asked and --interactive and stakes in [🟡 mid, 🔴 high]) {
      $answer = ask_user_question("confirm Chosen, or pick an alternative")
      apply $answer
      $asked = true
    }

    tag `[user-confirmed]` if $asked, else `[auto-decided]`
  }
  return { decisions: ... }
}
```

### draft()

- Design entries are contracts, not prose (data model, state machine, storage, repo layout, component tree).
- For code changes, include code blocks in `## Implementation steps`.
- Assess `## Review effort` per `/pr-risk-assessment`.

### validate()

- [ ] every decision has Chosen, Why, Alternatives
- [ ] non-goals are explicit
- [ ] post-implementation verification states what to check before merging or deploying

### save-plan()

```pseudocode
def save-plan($request) {
  $filename = "plan-<yyyy>-<mmdd>-<ticket>-<title>.md"
  # omit <ticket>- when unknown; lowercase kebab-case for <ticket> and <title>
  save beside the relevant *.metaplan.md, or under ~/.artefacts/
  return { path: $filename }
}
```

## Guidelines

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
