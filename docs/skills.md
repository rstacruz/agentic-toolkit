# Skills

## Skill map

```mermaid
graph LR
  brainstorm --> polish-plan
  brainstorm --> triangulate-plan
  polish-plan --> polish-implementation
  triangulate-plan --> polish-implementation
  polish-implementation --> babysit-pr
```

## Skills reference

### Planning

- [`$brainstorm`](../skills/brainstorm/SKILL.md) — Develop a vague idea into a scoped, handoff-ready plan

### Refining

- [`$polish-plan`](../skills/polish-plan/SKILL.md) — Strengthen a plan into an implementation-ready plan via a subagent review loop, catching inaccuracies before execution
- [`$triangulate-plan`](../skills/triangulate-plan/SKILL.md) — Generate an independent second opinion on a plan and merge the best of both into an implementation-ready plan

### Implementing

- [`$polish-implementation`](../skills/polish-implementation/SKILL.md) — Iterative code review loop using a subagent; auto-applies fixes up to 3 passes

### Shipping

- [`$babysit-pr`](../skills/babysit-pr/SKILL.md) — Monitor a PR's CI status in a loop until it passes or needs human input
