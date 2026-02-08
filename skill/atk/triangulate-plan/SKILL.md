---
name: triangulate-plan
description: Get alternative perspectives on an existing plan. Only invoke when a plan is already in place.
---
# Triangulate plan

Gather alternative perspectives on plan to surface risks, discover better approaches, strengthen design.

## Workflow

### 1. Delegate to subagent

Spawn a new agent (default: @general). Prompt must include:

**Required elements:**
- **Restate intent** — Original goal + clarifications from conversation
- **List related files/symbols** — Hints for agent's own research (file paths, function names, components)
- **Request `plan-with-tdd-and-prd` skill** — Ensure agent uses planning skill
- **Explicit output expectation** — "Return plan as inline text in final message. No file creation or edits."

**Prompt exclusions:**
- No technical implementation details. Let agent discover own answers through research.
- No leading hints about preferred solution. Allow independent thinking.

**Example:**
```
Goal: [restate intent]
Related: src/auth.ts, types/user.ts
Use plan-with-tdd-and-prd skill. Return plan as inline text, no files.
```

### 2. Evaluate subagent plan

Extract strong points and learnings from alternative approach:
- **Different architectural choices** — Why subagent chose different structure/pattern
- **New risks surfaced** — Issues you may have overlooked
- **Simpler alternatives** — Cleaner approaches to same problem
- **Edge cases considered** — Scenarios subagent identified that you missed
- **Better abstractions** — More cohesive separation of concerns

### 3. Compare plans

Present insights as structured comparison:

**Format per insight:**
- **[Insight name]**
  - Analysis: [Brief explanation of difference and tradeoffs]
  - Winner: ours | theirs
  - Confidence: low | med | high

**Example:**
```
- **Error handling approach**
  - Analysis: Subagent uses Result types vs our exception-based approach. Result types make error paths explicit but add boilerplate. Our approach simpler for this domain.
  - Winner: ours
  - Confidence: med
  
- **Database transaction scope**
  - Analysis: Subagent identified we're missing rollback on validation failure. Clear bug in our approach.
  - Winner: theirs
  - Confidence: high
```

### 4. Show recommendations

Summarise actionable changes based on comparison:

**Format:**
- **Adopt from alternative:** [List high-confidence "theirs" winners]
- **Keep from original:** [Note key decisions preserved]
- **Investigate further:** [List low-confidence items needing more research]

**Example:**
```
**Adopt from alternative:**
- Add transaction rollback on validation failure (high confidence)
- Include rate limiting edge case in tests (high confidence)

**Keep from original:**
- Exception-based error handling (simpler for this domain)
- Current database schema approach

**Investigate further:**
- Caching strategy differences (low confidence, need performance data)
```

## Guidelines

- Both plans can have merit—focus on extracting best ideas
- Subagent's approach may be wrong—analyse critically
- "Winner: theirs" with high confidence signals clear improvement to adopt
- "Winner: ours" means keep original approach
- Prompt subagent for fresh perspective, not validation
