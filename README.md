# Agentic Toolkit

A set of prompts and tools I use with [OpenCode](https://opencode.ai/), packaged as [Agent Skills](https://agentskills.io/home) so they can travel to other compatible tools too.

Treat this repo as a glimpse into my setup, not a sealed product. Use the parts you want and adapt them.

## Installation

Install [OpenCode](https://opencode.ai). Claude and Codex are also supported. Then:

```sh
npx skills add rstacruz/agentic-toolkit
```

These skills use the [Agent Skills](https://agentskills.io/home) format, so they work across compatible tools.

## Contents

- [skills/](skills/) - the main skills

## Quick start

```
brainstorm → polish-plan / triangulate-plan → polish-implementation → babysit-pr
```

### Starting from scratch

Start with `$brainstorm`.

*When to use:* when you are starting from scratch and only have a vague idea.

*What it does:* it turns a rough prompt into a stronger one by doing research and asking clarifying questions.

```
/brainstorm i want to implement config via c12 npm package
```

*Example:* [`example-brainstorm-plan.md`](./docs/example-brainstorm-plan.md) — example plan produced by `$brainstorm`

### Strengthen a plan

Use `$polish-plan` or `$triangulate-plan` to improve a plan.

*When to use:* when you already have a plan from `$brainstorm` or another planning pass.

*What they do:*

- `$polish-plan` runs the plan through a subagent review loop (up to 3 passes), applying critical fixes until it converges.
- `$triangulate-plan` generates an independent second opinion via a subagent and merges the best of both plans.

```
> ...
> Plan is done.

use polish-plan
```

### Build / implement

Use `$polish-implementation` to implement a plan.

*When to use:* when a plan is ready for implementation. Great follow-up to `$polish-plan`, but it can work with any plan.

*What it does:* it runs an iterative code review loop using a subagent, auto-applying fixes up to 3 passes.

```
> ...
> Plan is done.

use polish-implementation
```

### Watch CI

Use `$babysit-pr` to monitor a PR until CI passes or needs intervention.

*When to use:* after opening a PR — it polls CI, delegates failure analysis to a subagent, auto-fixes branch-related failures, and triages review feedback.

```
use babysit-pr
```

See [`docs/skills.md`](./docs/skills.md) for the full skill reference.
