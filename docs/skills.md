# Skills

Visual overview of the `skill/atk/` library.

## Skill map

```mermaid
graph LR
  brainstorm --> specmode["spec-mode"]
  specmode --> specprod["spec-product-requirements"]
  specmode --> spectech["spec-tech-design"]
  specmode --> specimpl["spec-implementation-plan"]
  specmode --> planrefine["plan-refine"]
  specmode --> execplan["execute-plan"]
  execplan --> execsubagent["execute-plan-subagent"]
  execsubagent --> reviewchanges["review-changes"]
  refineimpl["refine-implementation"] --> reviewchanges

  subgraph Brainstorm
    brainstorm
  end
  subgraph Spec
    specmode
    specprod
    spectech
    specimpl
    planrefine
  end
  subgraph Execution
    execplan
    execsubagent
    refineimpl
  end
  subgraph Review
    reviewchanges
    analysepr["analyse-pr"]
    refinetests["refine-tests"]
  end
  subgraph Foundation
    codingpractices["coding-practices"]
    testingpractices["testing-practices"]
  end
```

## Skills reference

| Skill | Description |
|-------|-------------|
| [`$brainstorm`](../skill/atk/brainstorm/SKILL.md) | Develop a vague idea into a scoped, handoff-ready plan seed |
| [`$spec-mode`](../skill/atk/spec-mode/SKILL.md) | Guide interactive specification creation — requirements, design, tickets |
| [`$spec-product-requirements`](../skill/atk/spec-product-requirements/SKILL.md) | Define functional/technical requirements sections |
| [`$spec-tech-design`](../skill/atk/spec-tech-design/SKILL.md) | Define technical design — call graphs, data models, pseudocode |
| [`$spec-implementation-plan`](../skill/atk/spec-implementation-plan/SKILL.md) | Break features into smaller, reviewable tickets |
| [`$plan-refine`](../skill/atk/plan-refine/SKILL.md) | Refine a plan with subagents |
| [`$execute-plan`](../skill/atk/execute-plan/README.md) | Execute a plan ticket-by-ticket using subagents |
| [`$execute-plan-subagent`](../skill/atk/execute-plan-subagent/SKILL.md) | Execute a single ticket; used by `$execute-plan` subagents |
| [`$refine-implementation`](../skill/atk/refine-implementation/SKILL.md) | Review and improve an implementation |
| [`$review-changes`](../skill/atk/review-changes/SKILL.md) | Review code changes against a plan (P1/P2/P3 recommendations) |
| [`$analyse-pr`](../skill/atk/analyse-pr/README.md) | Analyse a pull request |
| [`$refine-tests`](../skill/atk/refine-tests/SKILL.md) | Identify redundant tests, coverage gaps, improvement opportunities |
| [`$coding-practices`](../skill/atk/coding-practices/SKILL.md) | Core coding guidelines (functional core, result patterns, components) |
| [`$testing-practices`](../skill/atk/testing-practices/SKILL.md) | Core testing guidelines (readability, quality, constants) |
