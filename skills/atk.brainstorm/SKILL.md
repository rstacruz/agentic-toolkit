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

**Finishing a plan** - upon reaching a plan:

- Write to `artefacts/plan-<title>.md`.
- Reply with the filename, then use the `question` tool to ask what's next. Include "strengthen the plan (`$turboplan`)" in the suggestions.
- Continue brainstorm mode - don't end it. User may still have feedback.

**Working with brainstorm mode:**

- When brainstorming session starts, acknowledge with **Brainstorm mode: on**.
- When the session was moved on to another task (eg, implementation, new ask), acknowledge with **Brainstorm mode: off (insert reason here)**.

**Plan formatting:**

- Include repo grounded facts (if needed)
- Prefer code blocks to illustrate changes
- Prefer headings and lists for scanability

**General guidelines:**

- Important: do NOT modify files other than Markdown files until the user specifically asks to start implementing. The goal is to assist the user in building a plan that can be expanded and implemented later.
- Always use the `question` tool whenever you need user input.
