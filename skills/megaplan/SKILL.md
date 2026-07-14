---
name: megaplan
description: Write a "megaplan" planning notebook — a long-form Markdown doc for a multi-slice project that tracks scope, decisions, requirements, risks, and grounded research facts with cross-referenced IDs. Use when the user asks to write up a project plan, planning notebook, or "megaplan" doc, especially one spanning multiple tickets/PRs where decisions and raw research need to be preserved for later reference. Also use when bootstrapping a new megaplan from a vague idea.
---

## What this is

- A single living doc for a multi-slice project (spans several tickets/PRs over time), not a one-shot design doc.
- It accumulates as work progresses — new slices, decisions, and grounded facts get appended rather than rewritten.

## Getting started

1. Ask the user for the subject matter. Derive a slug, create `~/.notebooks/<yy><mm>-<slug>/index.md`.
2. Populate from the template below: title, one-line summary, `**Status:** seed`. All other sections empty — fill them as you go using the interview loop (see **Filling sections**).
3. Once the completeness checklist passes, flip to `**Status:** draft`.

## Structure

Sections in order. Tagged sections use short IDs so others can cross-reference them without repeating content:

- **Links**
- **Summary**
- **Scope**
  - Goals / Non-goals, each bullet says why.
  - What must the system do? What must it *not* do?
  - For each goal/non-goal: *why*? What does excluding it enable?
  - Are there adjacent features that look in-scope but aren't? Call them out explicitly.
- **Work plan**
  - Slices, each with its tickets in dependency order; include PRs and statuses if known.
  - Keep entries lean — see Work plan hygiene below.
- **Decisions** (`D01`, `D02`, ...)
  - Decision, why, implication.
  - For each design fork: lay out 2–3 options with trade-offs. Recommend one.
- **Inbox** (`N01`, `N02`, ...)
  - Incoming requests that still need triage; removed and turned into requirements as they're understood.
- **Requirements** (`R01`, `R02`, ...)
  - The actual spec: types, arbitration rules, worked examples.
  - Is there an existing pattern in the codebase to reuse?
  - Does it interact with another requirement? Resolve ordering first.
  - Can it be illustrated with a worked example (input → output)?
- **Risks** (`I01`, `I02`, ...)
  - Known gaps accepted as out-of-scope; include mitigations.
  - What's explicitly out-of-scope that could bite us?
- **Open questions** (`Q01`, `Q02`, ...)
  - Unresolved decisions blocking scope.
  - Promoted to a Decision as each is answered (leave the ID gap, don't renumber).
- **Appendix: Grounded facts** (`F01`, `F02`, ...)
  - Research relevant to task. eg: real API responses, third-party docs, source code findings.
- **Sources**
  - File paths and functions consulted, for traceability; live docs links used as reference.

## Filling sections

Interview the user relentlessly through each section. Walk each branch of the design tree before moving to the next — resolve dependencies between decisions one-by-one. For every question, provide your recommended answer.

Proactively research facts before asking: inspect the codebase for existing patterns, web-search for third-party constraints. If a question can be answered by exploring the repo, explore it instead of asking.

## Inbox triage

Incoming items get triaged with a concrete verdict:

- **Promote** → move to Requirements or Work plan with suggested markdown.
- **Close** → remove with reason (stale, duplicate, won't-fix).
- **Merge** → fold into an existing item.
- **Clarify** → pose a specific question back to the user.

## Completeness checklist

Before marking **Status:** draft and starting implementation:

- **Ready to start** — enough detail to begin the first slice?
- **Has work items** — every requirement mapped to a ticket; each reasonably sized?
- **Has goals** — clear, scoped goals and non-goals with reasons?
- **Has requirements** — if relevant: data model, API schema, screen inventory covered?

If gaps, fill them before flipping the status.

## Guidelines

- Omit sections not needed
- Add sections as necessary

### Work plan hygiene

Keep each entry to one line: **status emoji · ticket · short title · (requirement refs) · PR link(s)**, plus at most one short note only if it's *forward-looking and actionable* (e.g. "needs rework — X", "blocked on #NNNN").

- Reference PRs by bare number (`#14669`), not prose. One link is enough.
- **Cut the history.** No merge dates, "merged 9 Jul 03:01", "was stuck In Progress", superseded-branch trivia, CI-green/red narration, who-approved-what, diff stats (`+14/-2`). That belongs in git/Linear, not the living plan.
- A done item (✅) needs only the PR link — no story of how it got there.
- If a status note isn't something a reader would *act on*, delete it.

## Template

````markdown
# <Project name> megaplan

> One-sentence description of what this adds/changes and to what system.

**Status:** seed

## Links

- [Linear project](<url>)
- [Notion one-pager](<url>)
- [Repo](<url>)

## Summary

...

## Scope

### Goals

- **<Goal>** (G01)
  - ...
  - ...
- ...

### Non-goals

- **<Excluded thing>** (X01)
  - ...
  - ...
- ...

> ID goes on the title line and nothing else follows it — put the description and rationale in sub-bullets. Goals are G0N, non-goals X0N.

## Work plan

### Slice 1

- 🟡 [<TICKET-ID>](<url>) — **<short title>**
  - ...
  - ...
- ✅ [<TICKET-ID>](<url>) — **<short title>** — [PR #<n>](<url>)
  - ...
  - ...

### Slice N: <name>

- ...

Legend: 🟡 To do, ✏️ Draft PR, 👀 Ready for review, ✅ Done

## Decisions

### <Decision title> (D0N)

- ...

## Inbox

Requests coming in that need triage. These will eventually be removed and turned into requirements as we learn more.

### <Request title> (N0N)

- ...

## Requirements

### <Requirement title> (R0N)

- ...

## Risks

### <Risk title> (I0N)

- ...

## Open questions

### <Question title> (Q0N)

- ...

## Appendix: Grounded facts

### <Fact title> (F0N)

- ...

## Sources

- ...
````
