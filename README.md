# Agentic Toolkit

A set of prompts and tools I use. Treat this repo as a glimpse into my setup, not a sealed product. Use the parts you want and adapt them.

## Installation

```sh
npx skills add rstacruz/agentic-toolkit
```

Use it with [Pi](https://pi.dev/), [OpenCode](https://opencode.ai). Claude Code, Codex... pick your poison.

## Quick start

See [skills/](skills/) and [`docs/skills.md`](./docs/skills.md) for the full skill reference.

### Plan it

Start with [`$brainstorm`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/brainstorm/SKILL.md). This is my replacement for plan mode.

- Asks questions relentlessly (inspired by [grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/))
- Easily-skimmable output (Grounded facts, Steps, Risks)
- Works for all agents (including Pi which has no plan mode)
- Example: [example-plan.md](./docs/example-plan.md)

```
/brainstorm i want to implement config via c12 npm package
```

### Polish the plan

Use [`$polish-plan`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/polish-plan/SKILL.md) after creating a plan.

- Runs the plan through a subagent review loop (up to 7 passes)
- Applying fixes until there are no more changes needed

### Implement the plan

Implement the plan as you normally would (I suggest `/goal implement this plan`, as supported by many harnesses by default). No skill here.

### Polish the implementation

Use [`$polish-implementation`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/polish-implementation/SKILL.md) after implementing a plan.

- Loops through Code review -> Apply -> Review again
- Stops when there are no more changes to do

### Watch CI

Use [`$babysit-pr`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/babysit-pr/SKILL.md) to monitor a PR until CI passes or needs intervention.

- Waits for CI to be green
- Addresses CI failures automatically
