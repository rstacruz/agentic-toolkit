---
name: brainstorm
description: Help the user develop a vague idea into a "plan" — a scoped, handoff-ready statement of intent
# inspired by https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md
---

The user shares a rough idea. Guide them to a **plan**.

**Brainstorm workflow:**

- Interview the user relentlessly about every aspect of this plan until you both reach a shared understanding.
- Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.
- You may ask multiple questions at a time, provided that the questions do not depend on answers of the other.
- If a question can be answered by exploring the codebase, explore the codebase instead.

**Proactive researching** - Research facts proactively to gather facts needed for planning. Such as:

- Do repo/codebase inspection needed to learn readily discoverable facts.
- Do web research as needed.

**Look for related resources** - before finishing a plan, use the Agent tool to find related resources. Use a *research* agent type if available.

- If Linear tools are available, see if there are any linear tickets that are along these lines. 
- If Slack tools are available, See if there are any Slack discussions that may be related.

**Finishing a plan** - upon reaching a plan:

- Write to `~/.artefacts/plan-<yyyy>-<mmdd>-<ticket>-<title>.md` (omit *ticket* if not known).
- Reply with the filename, then use the `question` tool to ask what's next, include options:
  - Polish plan (`$polish-plan` skill)
- Continue brainstorm mode - don't end it. User may still have feedback.

**Working with brainstorm mode:**

- When brainstorming session starts, acknowledge with **Brainstorm mode: on**.
- When the session was moved on to another task (eg, implementation, new ask), acknowledge with **Brainstorm mode: off (insert reason here)**.

**Plan formatting:**

- Include repo grounded facts (if needed)
- Prefer code blocks to illustrate changes
- Prefer headings and lists for scanability
- Include post-implementation verification: things to do before merging or deploying to verify if implementation is correct

**General guidelines:**

- Important: do NOT modify files other than Markdown files until the user specifically asks to start implementing. The goal is to assist the user in building a plan that can be expanded and implemented later.
- Always use the `question` tool whenever you need user input.

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
2. …

## Decisions
- [list descisions here as user answers questions or steers the planning/brainstorming]

## Grounded facts

### 1. [name]
[context from the codebase and external sources]

Sources:
- [Filename or URL or name/identifier of source]

### 2. [name]

## Implementation steps

### 1. [name]
[include codeblocks whenever possible]

### 2. [name]

## Risks

### 1. [name]

## Post-implementation verification
```

