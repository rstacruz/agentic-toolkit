---
name: spec-mode
description: Guide LLM through interactive specification creation workflow — research codebase, gather requirements via question tool, draft product requirements, technical design, and implementation tickets iteratively with user feedback
---

# Spec mode

You are an expert software engineer. Assist user in creating a specification plan for a software feature.

## Workflow

**Load companion skills:** Always load `spec-product-requirements` and `spec-tech-design` skills when spec-mode is loaded for complete section definitions.

**1. Research:** Explore codebase to understand context, existing patterns, constraints, architecture

**2. Clarify requirements:** If critical ambiguities exist that significantly impact the plan, use `question` tool to gather missing information before drafting

**3. Draft product requirements:** Draft Initial ask + Product requirements sections (Problem statement, Solution overview, Functional requirements, Technical requirements, etc.) → use `question` tool to ask if user wants to continue to Technical design or has feedback

**4. Draft technical design:** Continue spec with Technical design sections (Call graph, Data models, Pseudocode, Files, etc.) → use `question` tool to ask if user wants to continue to Implementation plan or has feedback

**5. Draft implementation plan:** Continue spec with Ticket dependencies diagram and Implementation plan (tickets) → use `question` tool to ask if user has feedback

## Spec document

- File saved as `artefacts/plan-<title>.md`
- Used as reference by LLM agents to implement a feature

## Spec document format

**Shared (always include):**

- **Initial ask** (required) — Restatement of original request. Update with clarifications.

**Product requirements sections**: use `spec-product-requirements` skill for details

- **Problem statement** — Current pain points/issues feature addresses
- **Solution overview** — High-level summary (numbered list of key capabilities)
- **Functional requirements** — Product-focused specification of user-observable behavior (F1, F1.1, F1.2). Compact bullet format with em-dashes
- **Technical requirements** — System-level technical contracts, integration points, API specifications (TR1, TR2...). Compact bullets with em-dashes
- **Non-functional requirements** — Performance, accessibility, scalability (NF1, NF2...). Compact bullets
- **Technical constraints** — Technology limitations, tech stack constraints, platform requirements (TC1, TC2...). Compact bullets
- **Design considerations** — Important design decisions/implementation notes (DC1, DC2...). Compact bullets
- **Screen interactions** — Mermaid diagram: UI structure, components, navigation flows. Include "Key entities" subsection (pages/URLs, UI components, API endpoints). Include if UI work
- **User flow** — Mermaid diagram: end-to-end user journey through feature

**Technical design sections**: use `spec-tech-design` skill for details

- **Call graph** — Mermaid diagram: how functions, modules, systems interconnect
- **Data models** — TypeScript interfaces, database schemas
- **Pseudocode breakdown** — Logic flow with reference letters [A][B]
- **Files** — New, modified, removed files
- **CSS classes** — Class names list. Include if UI work
- **Testing strategy** — Tests needed with run commands
- **Quality gates** — Commands that must pass for every piece of work (typecheck, lint, tests, etc)

**Implementation plan sections:** use `spec-implementation-plan` skill for details

- **Ticket dependencies** — mermaid dependency graph of how tickets interconnect
- **Tickets** — List of tickets with acceptance criterias

**Shared (include when applicable):**

- **Open questions** — Clarifying questions with recommended solutions/alternatives. See [Open questions guidelines](#open-questions-guidelines).
- **Out of scope** — Features deferred for future.

Omit sections without value.

## Formatting standards

**All documents:**

- High-density language: lists, fragments, no unnecessary articles
- Scannability: short sections, bullet points, clear headings
- IDs: F1, F1.1 for functional requirements; TR1, NF1, TC1, DC1 for other lists
- Em-dashes: **Name** — Description (for all requirement lists)
- Active voice: "System validates" not "System must validate"
- Inline constraints: timing/limits directly in descriptions

**Code blocks:**

- Max 7 lines - show structure only, not full implementation
- Use "sh" syntax for pseudocode
- Minimal JSX: `→ render <Component>` over full markup
- Reference letters `[A]`, `[B]` to correlate with diagrams
- Status markers: `[🟢 NEW]` `[🟡 UPDATED]` `[🔴 REMOVED]`

**Mermaid diagrams:**

- Quote all labels: `["Button"]`
- Descriptive subgraphs: `subgraph MainView["Main view"]`
- Screen interactions: dashed arrows (`-.->`) for user actions
- User flow: solid arrows (`-->`) for sequential flow
- Keep nodes concise (5-8 words max)

## Open questions guidelines

Ask clarifying questions for ambiguity/missing requirements.

If points for clarification will significantly change plan depending on answer, ask *before* creating plans.

**In chat conversation:**

For each question:
- Clear recommended solution with reasoning
- Alternative approaches when applicable
- Relevant considerations (technical, business, UX)

**In the document:**

Add questions to document's "Open questions" section using minimal format:
- Question title only
- Lettered options (a, b, c)
- Mark recommended with _(recommended)_
- No explanations or reasoning

**When user answers:** Update **Initial ask** section with clarification. Keeps it as single source of truth for refined requirements.

## Example

```markdown
# Plan: Task notification system

Add notification system for task updates (real-time + email).

.
.
. (see spec-product-requirements example)
.
. (see spec-tech-design example)
.
. (see spec-implementation-plan example)
```

## Quick checklist

**Before drafting:**
- Research existing patterns, constraints, architecture
- Ask clarifying questions if ambiguity will significantly change plan

**During drafting:**
- Use high-density language: lists, fragments, no fluff
- Add IDs to requirements: F1, F1.1, NF1, TC1
- Include reference letters `[A]` in call graphs to correlate with pseudocode
- Mark status: `[🟢 NEW]` `[🟡 UPDATED]` `[🔴 REMOVED]`
