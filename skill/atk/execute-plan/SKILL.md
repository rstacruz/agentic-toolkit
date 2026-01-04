---
name: execute-plan
description: Use when executing implementation plans from planning phase to verified completion
---

# Execute Plan

Execute implementation plans and verify completion. This skill orchestrates implementation, verification, review, and documentation.

## Workflow

### 1. Execute the plan

- Follow the plan precisely
- **Tests first:** Write tests before production code when tests are in the plan. Skip if tests not planned or task is trivial.
- Use small, incremental commits

### 2. Verify and Review

Load and follow these specialized skills sequentially after implementation:

1. `verify-implementation`: Run preflight checks and functional verification.
2. `review-with-subagent`: Perform a peer review of the changes.
3. `generate-changelog`: Document the work done.

### 3. Summary

Provide action items requiring user attention:

```
Summary:
- ✅ Done: [things done]
- ✅ Tests passing

⚠️ Manual verification:
- [steps]

⚠️ Out of scope issues:
- [list]

⚠️ Roadblocks and difficulties:
- [list]
```

**Include:**
- Manual verification steps not automated
- Test/lint/type errors outside change scope
- Known issues or technical debt found
- Roadblocks and difficulties (to be used to improve documentation and future plans)
- Follow-up tasks

Omit if nothing requires attention.

## When to Use

- Implementing from a plan (TDD, PRD, or informal design)
- Transitioning from planning to execution

## When NOT to Use

- Exploratory work without plan
- Simple one-file changes
- Research or investigation tasks
