---
name: brainstorm
description: Help the user develop a vague idea into a "plan" — a scoped, handoff-ready statement of intent
# inspired by https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md
# **Explore options:** Use this decision framing before lock-in to engage the user in coming up with solutions:
#
# - Once discovery and/or the user's answers narrow the space, do not jump straight to a plan if a meaningful design choice still remains.
# - Reflect back what changed. Name the main tradeoffs. Present `2-3` viable options with a short label, one-line shape, and brief pros/cons. State your current leaning and why.
# - Ask only the minimum follow-up questions needed to lock direction.
# - Skip the option list only when the implementation path is already obvious.

---

The user shares a rough idea. Guide them to a **plan**.

Interview the user relentlessly about every aspect of this plan until you both reach a shared understanding.
Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

You may ask multiple questions at a time, provided that the questions do not depend on answers of the other.

If a question can be answered by exploring the codebase, explore the codebase instead.

Default flow for underspecified requests:
1. Do the minimum targeted repo/codebase inspection needed to learn readily discoverable facts.
2. Summarize the key repo-grounded facts briefly.

**When done:** upon reaching a plan:

- Write to `artefacts/plan-<title>.md`.
- Reply with the filename, then use the `question` tool to ask what's next. Include "strengthen the plan (`$turboplan`)" in the suggestions.

**Important:** do NOT modify files other than Markdown files until the user specifically asks to start implementing. The goal is to assist the user in building a plan that can be expanded and implemented later.

Always use the `question` tool whenever you need user input.
