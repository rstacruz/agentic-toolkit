# Skills

Visual overview of the `skill/atk/` library.

## Skill map

```mermaid
graph LR
  "brainstorm" --> "spec-mode"
  "spec-mode" --> "spec-product-requirements"
  "spec-mode" --> "spec-tech-design"
  "spec-mode" --> "spec-implementation-plan"
  "spec-mode" --> "plan-refine"
  "spec-mode" --> "execute-plan"
  "execute-plan" --> "execute-plan-subagent"
  "execute-plan-subagent" --> "review-changes"
  "refine-implementation" --> "review-changes"

  subgraph "Brainstorm"
    "brainstorm"
  end
  subgraph "Spec"
    "spec-mode"
    "spec-product-requirements"
    "spec-tech-design"
    "spec-implementation-plan"
    "plan-refine"
  end
  subgraph "Execution"
    "execute-plan"
    "execute-plan-subagent"
    "refine-implementation"
  end
  subgraph "Review"
    "review-changes"
    "analyse-pr"
    "refine-tests"
  end
  subgraph "Foundation"
    "coding-practices"
    "testing-practices"
  end
```

## Skills reference

| Skill | Description |
|-------|-------------|
| [`$brainstorm`](../skill/atk/brainstorm/) | Develop a vague idea into a scoped, handoff-ready plan seed |
| [`$spec-mode`](../skill/atk/spec-mode/) | Guide interactive specification creation — requirements, design, tickets |
| [`$spec-product-requirements`](../skill/atk/spec-product-requirements/) | Define functional/technical requirements sections |
| [`$spec-tech-design`](../skill/atk/spec-tech-design/) | Define technical design — call graphs, data models, pseudocode |
| [`$spec-implementation-plan`](../skill/atk/spec-implementation-plan/) | Break features into smaller, reviewable tickets |
| [`$plan-refine`](../skill/atk/plan-refine/) | Refine a plan with subagents |
| [`$execute-plan`](../skill/atk/execute-plan/) | Execute a plan ticket-by-ticket using subagents |
| [`$execute-plan-subagent`](../skill/atk/execute-plan-subagent/) | Execute a single ticket; used by `$execute-plan` subagents |
| [`$refine-implementation`](../skill/atk/refine-implementation/) | Review and improve an implementation |
| [`$review-changes`](../skill/atk/review-changes/) | Review code changes against a plan (P1/P2/P3 recommendations) |
| [`$analyse-pr`](../skill/atk/analyse-pr/) | Analyse a pull request |
| [`$refine-tests`](../skill/atk/refine-tests/) | Identify redundant tests, coverage gaps, improvement opportunities |
| [`$coding-practices`](../skill/atk/coding-practices/) | Core coding guidelines (functional core, result patterns, components) |
| [`$testing-practices`](../skill/atk/testing-practices/) | Core testing guidelines (readability, quality, constants) |
