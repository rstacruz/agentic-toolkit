# Agentic Toolkit

A set of prompts and tools I use. Treat this repo as a glimpse into my setup, not a sealed product. Use the parts you want and adapt them.

## Installation

```sh
npx skills add rstacruz/agentic-toolkit
```

Use it with [Pi](https://pi.dev/), [OpenCode](https://opencode.ai). Claude Code, Codex... pick your poison.

- **Pi:** Subagents are used in the *polish* skills, and Pi has no subagents by default. Consider [@tintinweb/subagents](https://github.com/tintinweb/pi-subagents).

- **OpenCode/Pi**: If you'd like to use a different model for polish reviews, create an agent with the name *"oracle"* and configure your preferred model for it. I personally use it with Opus, or GPT 5.5 high, or GLM 5.2 high. Otherwise, *polish* will default to whatever model you've got selected.

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

<details><summary>Example</summary>

Here's one I would use:

```
/goal First, make empty commit then create draft PR (use pr-description skill).
Then implement the plan as described, correctly and completely.
Ensure that the `polish-implementation` skill (using Oracle agent type if available; else, Opus) is used afterwards and has completed successfully.
Ensure `trim-tests` skill was used, and that no other changes to tests are needed.
Ensure the changes are committed and pushed to Git.
Ensure `atk-pr-autofix` is used and runs successfully.
Ensure CI is passing in GitHub. Ultrathink. Plan: <plan file here>
```

</details>
### Polish the implementation

Use [`$polish-implementation`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/polish-implementation/SKILL.md) after implementing a plan.

- Loops through Code review -> Apply -> Review again
- Stops when there are no more changes to do

### Watch CI

Use [`$atk-pr-autofix`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/atk-pr-autofix/SKILL.md) to monitor a PR until CI passes or needs intervention.

- Waits for CI to be green
- Addresses CI failures automatically
