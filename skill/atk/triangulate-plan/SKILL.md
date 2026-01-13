---
name: triangulate-plan
description: Get alternative perspectives on a plan
---
# Triangulate plan

Gather alternative perspectives on plan to surface risks, discover better approaches, strengthen design.

## Workflow

### 1. Delegate to subagent

Use subagent (default: general-gemini, configurable via $ARGUMENTS). Prompt must include:

**Required elements:**
- **Restate intent** — Original goal + clarifications from conversation
- **List related files/symbols** — Hints for agent's own research (file paths, function names, components)
- **Request `plan-with-tdd-and-prd` skill** — Ensure agent uses planning skill
- **Inline plan only** — No Markdown files in prompt (paste plan text directly)
- **Explicit output expectation** — Plan in final message, NO edits

**Prompt exclusions:**
- No technical implementation details. Let agent discover own answers through research.
- No leading hints about preferred solution. Allow independent thinking.

### 2. Evaluate subagent plan

Extract strong points and learnings from alternative approach:
- **Different architectural choices** — Why subagent chose different structure/pattern
- **New risks surfaced** — Issues you may have overlooked
- **Simpler alternatives** — Cleaner approaches to same problem
- **Edge cases considered** — Scenarios subagent identified that you missed
- **Better abstractions** — More cohesive separation of concerns

### 3. Synthesize insights

Integrate valuable learnings into original plan without wholesale rewrite:
- Adopt specific improvements (better structure, missing edge cases, risks)
- Preserve core design decisions unless clear evidence against them
- Document rationale for changes made based on triangulation

## Guidelines

- Focus on learnings, not comparison
- Subagent's approach may be wrong—extract only valuable insights
- Goal is strengthening, not replacing, original plan
- Prompt subagent for fresh perspective, not validation
