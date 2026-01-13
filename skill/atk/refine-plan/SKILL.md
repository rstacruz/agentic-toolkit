---
name: refine-plan
description: Refine a plan
---
# Refine plan

Refine plan by validating requirements, identifying bugs/impacts, predicting issues.

## Workflow 

### 1. Read plan

Parse goals, scope, implementation approach.

### 2. Question requirements

Challenge plan assumptions:
- **Unclear goals**: What specific problem does this solve? For whom?
- **Scope creep**: Does this belong in this change or a separate one?
- **Missing context**: What's the user's actual need vs stated request?
- **Over-engineering**: Is the proposed solution simpler than alternatives?
- **Misalignment**: Does this contradict project principles or architecture?
- **Unstated constraints**: Performance/compatibility/security requirements unclear?

**Handling concerns**:
- Concerns needing user decisions/context: Ask focused clarifying questions before refining
- Critical blockers (unclear goals, fundamental misalignment): Ask user for clarification
- Minor concerns (scope suggestions, simpler alternatives): Document in refined plan
- Always flag before diving into implementation details if requirements don't make sense

### 3. Identify refinements

**Bugs** - Your primary focus
- Logic errors, off-by-one mistakes, incorrect conditionals
- If-else guards: missing guards, incorrect branching, unreachable code paths
- Edge cases: null/empty/undefined inputs, error conditions, race conditions
- Security issues: injection, auth bypass, data exposure
- Broken error handling that swallows failures, throws unexpectedly or returns error types that are not caught.

**Impact** - Your secondary focus
- Integration points: APIs, shared state, database schema, config
- Downstream consumers: UI components, services, scripts depending on changed code
- Cross-cutting concerns: auth, logging, caching, error handling
- Migration needs: data transforms, backwards compatibility

**Structure** - Does the code fit the codebase?
- Does it follow existing patterns and conventions?
- Are there established abstractions it should use but doesn't?
- Excessive nesting that could be flattened with early returns or extraction

**Performance** - Only flag if obviously problematic.
- O(n²) on unbounded data, N+1 queries, blocking I/O on hot paths

**Consistency**
- Verify plan aligns with existing codebase patterns and project guidelines
- Naming conventions, testing strategies, architectural style
- Implementation aligns with AGENTS.md coding/testing guidelines (if provided)

**Polish**
 - Outdated documentation or comments?
 - Opportunities to simplify?
 - Accessibility issues? (eg, wrong role, missing labels)

### 4. Identify potential issues 

Predict likely problems and rank them:
- **P1 (critical)**: Requires addressing before merging into main branch
- **P2 (important)**: in-between P1 and P3
- **P3 (edge case)**: Rare scenarios, minor inconveniences, polish items

### 5. Update the plan

- Make changes to the plan based on your analysis.
- If there is a Markdown file for this plan (eg plan.md), edit with refinements.
- If no file exists, provide updated plan in the conversation

## Guidelines

- **Challenge first, refine second**: If requirements unsound, flag before diving into implementation details
- Focus refinements on high-signal feedback—not style nitpicks
- Propose concrete alternatives, not just problems
- Only update existing Markdown files; do not create new ones
- Provide assessments in the conversation for user review
