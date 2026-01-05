---
name: refine-plan
description: Refine a plan
---
# Refine plan

Refine this plan.

## Workflow 

### 1. Read the plan

Understand the current plan and its goals before analysing.

### 2. Identify refinements

**Bugs** - Your primary focus
- Logic errors, off-by-one mistakes, incorrect conditionals
- If-else guards: missing guards, incorrect branching, unreachable code paths
- Edge cases: null/empty/undefined inputs, error conditions, race conditions
- Security issues: injection, auth bypass, data exposure
- Broken error handling that swallows failures, throws unexpectedly or returns error types that are not caught.

**Impact** - Your secondary focus
- Identify parts of this codebase that maybe affected by this change.
- Assess if anything needs to change, either in those related systems or the ones updated in this change.

**Structure** - Does the code fit the codebase?
- Does it follow existing patterns and conventions?
- Are there established abstractions it should use but doesn't?
- Excessive nesting that could be flattened with early returns or extraction

**Performance** - Only flag if obviously problematic.
- O(n²) on unbounded data, N+1 queries, blocking I/O on hot paths

**Cconsistency**
- Verify that the plan aligns with existing codebase patterns
- eg, Naming conventions, testing strategies, architectural style

**Alignment**
 - Check if implementation aligns with project guidelines described in its AGENTS.md files
 - Does code follow coding guidelines (if given)?
 - Do tests follow follow test guidelines (if given)?

**Also**
 - Are there outdated documentation or comments?
 - Opportunities to simplify?
 - Accessibility issues? (eg, wrong role, missing labels)

### 3. Identify potential issues 

Predict likely problems and rank them:
- **P1 (critical)**: Requires addressing before merging into main branch
- **P2 (important)**: in-between P1 and P3
- **P3 (edge case)**: Rare scenarios, minor inconveniences, polish items

### 4. Update the plan

- Make changes to the plan based on yoru analysis.
- If there is a Markdown file for this plan (eg plan.md), edit with refinements.
- If no file exists, provide updated plan in the conversation

## Guidelines

- Only update existing Markdown files; do not create new ones
- Provide assessments in the conversation for user review
