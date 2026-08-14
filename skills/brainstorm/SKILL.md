---
name: brainstorm
description: Help the user develop a vague idea into a "plan" — a scoped, handoff-ready statement of intent
# inspired by https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md
---

**The user shares a rough idea. Guide them to a plan.**

## Brainstorm workflow

**Interview the user until you both reach a shared understanding.**

- Interview relentlessly about every aspect of the plan.
- Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.
- Ask multiple questions at a time, provided they don't depend on each other's answers.
- If a question can be answered by exploring the codebase, explore instead.

## Proactive researching

**Research facts proactively to gather facts needed for planning:**

- Do repo/codebase inspection to learn readily discoverable facts.
- Do web research as needed.

## Look for related resources

**Before finishing a plan, check for related work.** Use the `Explore` agent type (or `general-purpose` if unavailable):

- Linear tickets along these lines (if Linear tools available)
- Slack discussions that may be related (if Slack tools available)

## Finishing a plan

Skip if you escalated to metaplan — metaplan handles its own completion flow.

**Write to file:**

- Filename: `plan-<yyyy>-<mmdd>-<ticket>-<title>.md` (omit *ticket* if unknown)
- Save location, in order:
  1. Same folder as an existing `*.metaplan.md` for this project, if one exists (eg, `~/.notebooks/<path>/`).
  2. Else, `~/.artefacts/`.

**Then:**

- Reply with the filename
- Use `AskUserQuestion` for what's next, options:
  - Polish plan (`$polish-plan` skill)
- Continue brainstorm mode — don't end it. User may still have feedback.

## Working with brainstorm mode

- **Start:** acknowledge **Brainstorm mode: on**.
- **Move on:** acknowledge **Brainstorm mode: off (insert reason here)**.

## Plan formatting

- Repo grounded facts last, if needed
- Code blocks to illustrate changes
- Headings and lists for scanability
- Post-implementation verification: things to do before merging or deploying
- Some sections inside `<details>` — too noisy for regular review
- Use `/skimmable` skill if available

## General guidelines

- **Do NOT modify files other than Markdown** until the user specifically asks to start implementing. Goal: a plan that can be expanded and implemented later.
- Always use `AskUserQuestion` whenever you need user input.

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

### 1. <decision> [list decisions here as user answers questions or steers the planning/brainstorming]

- **Chosen:** <answer>
- **Why:** <one-line rationale>

**Alternatives:**

- <alternative considered, and why it lost>

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
