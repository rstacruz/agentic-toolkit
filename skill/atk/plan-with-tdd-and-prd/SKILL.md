---
name: plan-with-tdd-and-prd
description: Use when initiating new features, complex code changes, or technical research tasks that require structured planning and documentation before implementation.
---

# Planning with PRD, TDD, and Discovery documents

This skill guides structured planning before implementation using three document types:

- **Discovery documents** (`discovery-<title>.md`) — Environmental context, constraints, existing architecture
- **PRD** (`prd-{slug}.md`) — Product requirements, functional specs, what system should do
- **TDD** (`tdd-<feature>.md`) — Technical design, implementation plan, how to build it

**Core workflow:** Research → Clarify ambiguities → Draft plan → Save to `artefacts/`

Document choice depends on task complexity: trivial changes need no planning; small tasks need TDD only; complex features benefit from full Discovery + PRD + TDD workflow.

## Formatting standards

**All documents:**

- High-density language: lists, fragments, no unnecessary articles
- Scannability: short sections, bullet points, clear headings
- IDs: F1, F1.1 for requirements; NF1, TC1, DC1 for other lists
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

## User actions

**Common requests:**
- "Write a PRD for [feature]" → [Draft or write a PRD](#draft-or-write-a-prd)
- "Draft a TDD for [feature]" → [Write a TDD](#write-a-tdd)
- "Plan a code change" → [Write a TDD](#write-a-tdd)
- "Research [topic/technology/approach]" → [Research a topic](#research-a-topic)
- "create combined tdd-prd for [feature]" → [Combined PRD-TDD](#combined-prd-tdd)

### Draft or write a PRD

Steps:

1. **Research:** Understand existing systems/constraints. Write to `artefacts/discovery-<title>.md` if non-obvious findings.
2. **Check context:** Read `artefacts/discovery-<title>.md` if exists.
3. **Clarify:** Ask ambiguities before drafting. See *Open questions guidelines*.
4. **Draft:** Follow PRD structure below.
5. **Add questions:** Unresolved items → PRD's "Open questions".
6. **Save:** Write to `artefacts/prd-{slug}.md`.

### Write a TDD

Steps:

1. **Research:** Find code patterns, data models, integration points. Write to `artefacts/discovery-<title>.md` if non-obvious findings.
2. **Check context:** Read `artefacts/prd-{slug}.md` and `artefacts/discovery-<title>.md`.
3. **Clarify:** Ask technical ambiguities with recommended solutions.
4. **Draft:** Follow TDD structure below.
5. **Add questions:** Unresolved implementation items → TDD's "Open questions".
6. **Save:** Write to `artefacts/tdd-<feature>.md`.

### Research a topic

Write findings to Discovery Document (`artefacts/discovery-<title>.md`).

### Combined PRD-TDD

For small to medium features where both product requirements and technical implementation can be covered together:

Steps:

1. **Research:** Find existing patterns, constraints. Write to `artefacts/discovery-<title>.md` if findings are non-obvious.
2. **Check context:** Read `artefacts/discovery-<title>.md` if exists.
3. **Clarify:** Ask ambiguities before drafting.
4. **Draft:** Combine PRD and TDD sections in single document. Use PRD structure for requirements, TDD structure for implementation. Skip duplicate sections (Initial ask, Open questions).
5. **Save:** Write to `artefacts/plan-<feature>.md`.

## Planning artefacts

### Document structure

Planning artefacts in `artefacts/` (local, git-ignored):

- `discovery-<title>.md` - environmental context/constraints
- `prd-{slug}.md` - product requirements
- `tdd-<feature>.md` - implementation plans

Notes persist in `notes/` across branches. Users may specify custom locations.

**Guidelines:**

- Write to `artefacts/` (eg, `artefacts/prd-{slug}.md`)
- Scope decisions:
  - Large projects: discovery, PRD, TDD
  - Small tasks: TDD only
- Confirm with user before PRD → TDD

### Multiple planning tracks

When user requests work outside current scope:

- New feature/scope → new TDD (`tdd-another-feature.md`)
- New research → new discovery (`discovery-api-quirks.md`)

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

## Discovery document guidelines

**Purpose:** Capture environmental constraints/context for planning. NOT implementation details or obvious info.

Answers: "What's needed about the environment for good planning decisions?"
Not: "How will I implement this?" (that's TDD)

**Typical inclusions:**

- Current system architecture/patterns
- Existing code structures to follow
- Technical constraints/limitations
- Database schemas/data formats
- Third-party APIs and quirks
- Non-obvious edge cases with business impact
- Library research (capabilities, usage, tradeoffs)

**Typical exclusions:**

- Implementation pseudocode/code samples (→ TDD)
- Obvious edge cases (eg, "React handles HTML escaping")
- Migration strategies/rollback plans (→ TDD)
- Backwards compatibility solutions (→ TDD)
- "Next steps" or implementation order (→ TDD)
- Test cases/testing strategy (→ TDD)
- Effort estimates/timelines (→ PRD roadmap)

### Condensed summary

Include "condensed summary" H2 at beginning. Write condensed prompt guiding future agents to research independently and reach same conclusions. Prefer code citations over examples.

Include: context (required), function/symbol names with locations, glossary, issues, key insights.

### Discovery vs TDD

Test: "Would this info still be true if we chose completely different implementation?"

- YES → Discovery (eg, "Database uses SQLite", "Tailwind v4 has no config file")
- NO → TDD (eg, "Use buildPrompt() function", "Handle errors with try/catch")

### Patterns to avoid

- Don't document obvious behaviors ("React handles HTML escaping", "UTF-8 works in database")
- Don't include implementation details ("Use try/catch for errors")

## PRD guidelines

Typical sections (include if applicable):

- **Initial ask** (required) — Restatement of original request. Update with clarifications.
- **Problem statement** — Current pain points/issues feature addresses.
- **Solution overview** — High-level summary (numbered list of key capabilities).
- **Functional requirements** — Complete technical specification of what system does (F1, F1.1, F1.2). Compact bullet format with em-dashes. See "Functional requirements" section.
- **Non-functional requirements** — Performance, accessibility, scalability (NF1, NF2...). Compact bullets.
- **Technical constraints** — Tech stack, integration, implementation constraints (TC1, TC2...). Compact bullets.
- **Quality gates** — Commands that must pass for every piece of work (typecheck, lint, tests, etc). See "Quality gates" section.
- **Design considerations** — Important design decisions/implementation notes (DC1, DC2...). Compact bullets.
- **Screen interactions** — Mermaid diagram: UI structure, components, navigation flows. Include "Key entities" subsection (pages/URLs, UI components, API endpoints).
- **User flow** — Mermaid diagram: end-to-end user journey through feature.
- **Open questions** — Clarifying questions with recommended solutions/alternatives.
- **Out of scope** — Features deferred for future.
- **Additional context** — Environmental info, existing systems, research findings.

**Good PRD qualities:**

- Technical solution plan can be made from it
- Edge cases/error scenarios addressed
- Engineers can estimate without many questions

### Functional requirements

Complete technical specification of what system does. See [Formatting standards](#formatting-standards) for format rules.

Example structure:

### F1: Notification events

- **F1.1. Task comments** — Someone comments on watched task
- **F1.2. Status changes** — Task status changes

Each notification includes: event type, task title (linked), who triggered it, timestamp.

### Quality gates

Commands that must pass for every piece of work. Example format:

```markdown
## Quality gates

- `pnpm typecheck` - Type checking
- `pnpm lint` - Linting
- `pnpm test` - Unit tests

For UI work: Verify in browser using devtools
```

### Design considerations

Document important design decisions that don't fit into functional requirements. See example.

### Screen interactions diagram

Visualize UI structure, component hierarchy, interactive flows. Include when feature has multiple screens/views or complex user interactions.

**Structure:**

1. Top-level subgraphs: Screens/pages with URL paths
2. Nested subgraphs: Group related UI elements
3. Nodes: Individual UI elements (buttons, links, inputs)
4. Dashed arrows (`-.->`) with labels for user actions
5. Include "Key entities" subsection listing pages/URLs, UI components, API endpoints

**Include:** Screens/URLs, interactive elements, navigation flows, modal/drawer interactions  
**Exclude:** Non-interactive elements, internal component hierarchy, styling, data flow

See [Formatting standards](#formatting-standards) for diagram rules.

### User flow diagram

Show end-to-end user journey for multi-step processes or cross-user interactions.

**Structure:**

1. Nodes: States, actions, events in user journey
2. Solid arrows (`-->`) with trigger/condition labels
3. Include system responses when relevant to flow

**Include:** User actions, system responses, conditional branches  
**Exclude:** Implementation details, error handling (unless critical), UI component specifics

See [Formatting standards](#formatting-standards) for diagram rules.

### PRD example

Shows structure - see guidelines above for section details.

````markdown
# PRD: Task notification system

## Initial ask
Add notification system for task updates (real-time + email).

## Problem statement
Users miss updates by manually checking task list.

## Functional requirements

### F1: Notification events
- **F1.1. Task comments** — Someone comments on watched task
- **F1.2. Status changes** — Task status changes
- **F1.3. Mentions** — Mentioned in comments/descriptions

Each notification: event type, task title (linked), who triggered it, timestamp.

### F2: Notification delivery
- **F2.1. Real-time** — In-app within 2 seconds
- **F2.2. Email** — Within 5 minutes
- **F2.3. Notification center** — View all in panel

## Non-functional requirements
- **NF1. Performance** — Real-time within 2 seconds
- **NF2. Scalability** — Email queue handles 1000+/min

## Quality gates
- `pnpm typecheck`, `pnpm lint`, `pnpm test`

For UI work: Verify in browser via http://localhost:3000/notifications

## Screen interactions
[Mermaid diagram: bell icon → notification panel → task detail]

### Key entities
**Pages:** `/workspace/[id]/tasks`, `/settings/notifications`  
**Components:** Notification bell, panel, item  
**API:** `GET /api/notifications`, `PATCH /api/notifications/[id]/read`

## Open questions
1. **Root page:** Redirect to `/es` or show language selection?
   - a. Redirect based on browser detection _(recommended)_
   - b. Show selection page
````

## TDD guidelines

### TDD structure

Use single `tdd-<feature>.md` file. Include if applicable: Call graph, Pseudocode, Data models, Files, CSS classes, Testing strategy, Open questions.

**Keep concise:**
- Omit sections without value
- Limit to 700 words (unless specified)
- Max 7 lines per code block - show structure only

See [Example TDD](#example-tdd) below for complete demonstration.

### Call graph

Visualizes how functions, modules, systems interconnect.

**When to include:** Multiple interconnected functions, complex dependencies, system integration points, architectural changes

**Structure:** Subgraphs (by file/module), nodes (functions/components), reference letters [A][B], status markers (🟢🟡🔴), arrows with descriptive labels ("uses", "calls", "renders via")

**Include:** Changed functions/components, what uses them, integration points, data flow direction  
**Exclude:** Internal implementation details, trivial helpers, standard library/framework functions, tests

**Best practices:** Focus on changed components + immediate dependencies, search codebase for usage, trace to entry points (API calls, CLI actions), correlate nodes to pseudocode using reference letters

**Example:**

```mermaid
flowchart TD
    subgraph api["api/tasks/[id]/complete.ts"]
        POST["POST handler [🟡 UPDATED]"]
    end
    
    subgraph tasks["tasks/complete.ts"]
        A["completeTask(taskId) [🟢 NEW] [A]"]
    end
    
    subgraph db["@/lib/prisma"]
        Prisma["prisma.task"]
    end
    
    POST -->|"calls"| A
    A -->|"queries & updates"| Prisma
```

Key elements shown:
- **Subgraphs** for each file/module
- **Reference letters** `[A]` to correlate with pseudocode
- **Status markers** `[🟢 NEW]` `[🟡 UPDATED]`
- **Descriptive arrows** showing relationships
- **Entry points** (API route) and **integration points** (Prisma)

### Pseudocode breakdown

Show logic flow with reference letters [A][B]. Mark status: 🟢 NEW, 🟡 UPDATED, 🔴 REMOVED. Use "sh" syntax. Keep JSX minimal.

**Key guidelines:** Include descriptive comments (logic flow, business rules), use `→ render <Component>` not full JSX trees, focus on logic not rendering details

### Testing strategy

List tests needed with run commands.

**Include:** Test data/fixtures used, dependencies needing mocks + why (external APIs, databases, time-dependent), exact command to run tests

**Format:** 1 line per test (name only). Add 1-line comment after if key info needed.

### Example TDD

````markdown
# TDD: Task completion tracker

## Initial ask

Add task completion feature: mark done w/ timestamp.

## Data models

```typescript
interface Task {
  id: string;
  title: string;
  status: "pending" | "completed";
  completedAt: Date | null;
}
```

## Pseudocode breakdown

**completeTask:** mark task complete

```sh
# == tasks/complete.ts ==

completeTask(taskId) # [🟢 NEW]
  # Validate task exists
  → task = prisma.task.findUnique({ where: { id: taskId } })
  if !task: return { ok: false, error: "NOT_FOUND" }
  if task.status == 'completed': return { ok: true, task }
  
  # Mark complete and persist
  → prisma.task.update({ ... })
  → return { ok: true, task }
```

## Files

**New:** `src/tasks/complete.ts`  
**Modified:** `prisma/schema.prisma` - Add Task model

## CSS classes

- `.task-item`, `.task-checkbox`, `.task-completed`

## Testing strategy

**Run:** `npx vitest src/tasks/complete.test.ts`

**Mocks:** `@/lib/prisma`  
**Fixtures:** `PENDING_TASK`, `COMPLETED_TASK`

**Tests:**
- marks task complete w/ timestamp
- returns error if task not found
- idempotent if already completed

## Open questions

1. **Undo completion:** Should users be able to mark completed task as incomplete?
   - a. Allow unmarking with completedAt set to null _(recommended)_
   - b. No undo - completion is final
````

## Quick reference

### Document decision tree

```mermaid
flowchart TD
    Start["Task to plan"] --> Trivial{"Trivial change?"}
    Trivial -->|"Yes: One-line fix,<br>docs only, obvious"| Skip["Skip planning.<br>Implement directly"]
    Trivial -->|"No"| Complex{"Complex feature?"}
    
    Complex -->|"No: Simple task,<br>single file"| TDD["TDD only<br>(artefacts/tdd-feature.md)"]
    Complex -->|"Yes: Multi-component,<br>requires specs"| Research{"Non-obvious<br>constraints?"}
    
    Research -->|"Yes: New tech,<br>quirky APIs"| Disco["1. Discovery doc<br>(artefacts/discovery-title.md)"]
    Research -->|"No"| PRD["2. PRD<br>(artefacts/prd-slug.md)"]
    
    Disco --> PRD
    PRD --> TDDFull["3. TDD<br>(artefacts/tdd-feature.md)"]
```

### Key reminders

**Before drafting:**
- Research existing patterns, constraints, architecture
- Ask clarifying questions if ambiguity will significantly change plan
- Check for existing discovery/PRD documents

**During drafting:**
- Use high-density language: lists, fragments, no fluff
- Add IDs to requirements: F1, F1.1, NF1, TC1
- Include reference letters `[A]` in call graphs to correlate with pseudocode
- Mark status: `[🟢 NEW]` `[🟡 UPDATED]` `[🔴 REMOVED]`

**Document boundaries:**
- **Discovery:** Environmental facts true regardless of implementation choice
- **PRD:** What system should do, not how
- **TDD:** How to implement, code structure, testing approach
