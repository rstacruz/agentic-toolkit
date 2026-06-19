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

Start with `$brainstorm`. This is my replacement for plan mode.

- Asks questions relentlessly (inspired by [grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/))
- Easily-skimmable output (Grounded facts, Steps, Risks)
- Works for all agents (including Pi which has no plan mode)

```
/brainstorm i want to implement config via c12 npm package
```

<!--
*Example:* [`example-brainstorm-plan.md`](./docs/example-brainstorm-plan.md) — example plan produced by `$brainstorm`
-->

### Polish the plan

Use `$polish-plan` after creating a plan.

- Runs the plan through a subagent review loop (up to 7 passes)
- Applying fixes until it converges into an implementation-ready plan

### Polish the implementation

Implement the plan as you normally would (I suggest `/goal implement this plan`, as supported by many harnesses by default). Then use `$polish-implementation`.

- Loops through Code review -> Apply -> Review again
- Stops when there are no more comments to address

### Watch CI

Use `$babysit-pr` to monitor a PR until CI passes or needs intervention.

- Waits for CI to be green
- Addresses CI failures automatically
