# Skills

## Skill map

```mermaid
graph LR
  brainstorm --> turboplan["turboplan"]
  turboplan --> spectech["spec-tech-design"]
  turboplan --> refinespec["refine-spec"]
  turboplan --> turbobuild["turbobuild"]
  turbobuild --> specimpl["spec-implementation-plan"]
  turbobuild --> implsubagent["implement-spec-subagent"]
  turbobuild --> polish
  implsubagent --> reviewchanges["review-changes"]
  polish["polish"] --> reviewchanges
  polish --> simplify["simplify"]

  subgraph turboplan_group["turboplan"]
    brainstorm
    turboplan
    spectech
    refinespec
  end
  subgraph turbobuild_group["turbobuild"]
    turbobuild
    specimpl
    implsubagent
  end
  subgraph polish_group["polish"]
    polish
    reviewchanges
    simplify
  end
  subgraph other_group["other"]
    mermaid["mermaid-diagrams"]
  end
```

## Skills reference

### pre-plan

- [`$brainstorm`](../skills/atk.brainstorm/SKILL.md) — Develop a vague idea into a scoped, handoff-ready plan seed

### turboplan

- [`$turboplan`](../skills/atk.turboplan/SKILL.md) — Expand an approved pre-plan with technical design, then refine it
  - [`$spec-tech-design`](../skills/atk.spec-tech-design/SKILL.md) — Define technical design — call graphs, data models, pseudocode
  - [`$refine-spec`](../skills/atk.refine-spec/SKILL.md) — Pressure-test a spec or plan seed with independent critiques

### turbobuild

- [`$turbobuild`](../skills/atk.turbobuild/SKILL.md) — Strengthen ticket planning when needed, then implement a spec ticket-by-ticket
  - [`$spec-implementation-plan`](../skills/atk.spec-implementation-plan/SKILL.md) — Break features into smaller, reviewable tickets
  - [`$implement-spec-subagent`](../skills/atk.implement-spec-subagent/SKILL.md) — Implement a single ticket; used by `$turbobuild` subagents

### polish

- [`$polish`](../skills/atk.polish/SKILL.md) — Simplify and review an implementation
  - [`$review-changes`](../skills/atk.review-changes/SKILL.md) — Review code changes against the spec (P1/P2/P3 recommendations)
  - [`$simplify`](../skills/atk.simplify/SKILL.md) — Simplify an implementation before final review

### other

- [`$spec-product-requirements`](../skills/atk.spec-product-requirements/SKILL.md) — Define functional/technical requirements sections
- [`$mermaid-diagrams`](../skills/atk.mermaid-diagrams/SKILL.md) — Create Mermaid diagrams and fix Mermaid syntax issues

## Quick start 

### Starting from scratch

Start with the brainstorm skill or command.

```
/brainstorm i want to implement config via c12 npm package
```

### Hardening a plan

Use `$turboplan` to improve a plan

### Build with subagents

Use `$turbobuild`

### Polish an existing implementation

Use `$polish`

## Examples

Concrete examples of skill outputs using a rate-limiting middleware scenario:

- [`example-seed.md`](./example-seed.md) — example plan seed produced by `$brainstorm`
- [`example-spec.md`](./example-spec.md) — example full spec document (PRD + TDD + tickets) from the planning workflow
