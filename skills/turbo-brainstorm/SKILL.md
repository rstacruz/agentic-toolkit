---
name: turbo-brainstorm
description: >
  Turn a vague idea into a plan fast by making judgement calls instead of interviewing the user. Use when the user says $turbo-brainstorm, wants a plan quickly, or is unwilling to be interviewed. Every judgement call is documented under '## Decisions' so it can be vetoed. Prefer this over brainstorm when the user values speed over consultation.
---

**Turn a rough idea into a plan. Ask as few questions as possible.**

## Turbo workflow

**Decide first, ask last.**

- Walk the design tree yourself — make a judgement call per branch, don't interview.
- Document every call under `## Decisions` (see Suggested plan structure) — each entry needs **Chosen**, **Why**, **Alternatives**. The user can veto at review — that safety net replaces the interview.

**Rung 0 — confirm understanding, only if it's genuinely ambiguous.**

Before walking the tree, check if the idea's scope or goal is unclear enough that a wrong read would derail the whole plan (eg, could mean two different features, target audience unstated, "fix X" without saying what broken looks like).

- Ambiguous → `AskUserQuestion` once, confirming the scope/goal reading before doing any research or decisions.
- Clear enough → skip this, go straight into the ladder below.

Don't restate an idea that's already unambiguous — that's an interview, not a confirmation.

**At each branch, run the decide-first ladder:**

1. Research answers it → not a decision, just find the fact.
2. Reasonable default exists, or one option is cheaply reversible, or no option clearly wins → decide on the most reasonable default, document, move on.
3. Costly/irreversible + no signal, but doesn't block the plan → decide, document, flag it clearly (eg, `⚠️ revisit`) so the veto step catches it.
4. All options costly/irreversible + no signal + blocks the plan → ask.

## General guidelines

- **Do NOT modify files other than Markdown** until the user asks to start implementing. Goal: a plan to expand and implement later.
- Use `AskUserQuestion` for user input, never open-ended prose. Ask only per ladder rung 4.

## Look for related resources

**Before finishing a plan, check for related work.** Use the `Explore` agent type (or `general-purpose` if unavailable):

- Linear tickets along these lines (if Linear tools available)
- Slack discussions that may be related (if Slack tools available)

## Finishing a plan

**Checklist before writing to file:**
- [ ] Every `## Decisions` entry has all three fields: `Chosen`, `Why`, `Alternatives` (name the runner-up and why it lost — one line each), plus a `[decided]`/`[asked]` tag
- [ ] Non-goals listed
- [ ] Post-implementation verification present (what to check before merging or deploying)
- [ ] Noisy sections wrapped in `<details>` (see Suggested plan structure)
- [ ] Formatted with `/skimmable` skill if available

Missing any item → fix the plan, don't write it.

**Write to file:**

- Filename: `plan-<yyyy>-<mmdd>-<ticket>-<title>.md` (omit *ticket* if unknown)
- Save location, in order:
  1. Same folder as an existing `*.metaplan.md` for this project, if one exists (eg, `~/.notebooks/<path>/`).
  2. Else, `~/.artefacts/`.

**Then:**

- Reply with the filename
- Use `AskUserQuestion` for what's next, options:
  - Start implementing
  - Polish plan (`$polish-plan` skill)
  - Review the judgement calls — spawn a subagent to veto-check `## Decisions`

## Suggested plan structure

Consider structuring plan files like so. Feel free to add or omit sections as needed.

```
# Title

- **Date:** yyyy-mm-dd
- **Ticket:** [link](...)

## Context

## Goals
1. …

**Non-goals:**
1. …

## Decisions

### 1. <decision> — `[auto-decided]` or `[user-confirmed]`

- **Chosen:** <answer>
- **Why:** <one-line rationale>

**Alternatives:**

- ✗ <alternative considered, and why it lost>

### 2. <decision>

## Implementation steps

### 1. [name]
[include codeblocks whenever possible]

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
- [Filename or URL or name/identifier of source]

### 2. [name]

</details>
```
