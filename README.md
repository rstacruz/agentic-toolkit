# Agentic Toolkit

A set of prompts and tools I use. Treat this repo as a glimpse into my setup, not a sealed product. Use the parts you want and adapt them.

## Installation

```sh
npx skills add rstacruz/agentic-toolkit
```

Use it with [Pi](https://pi.dev/), [OpenCode](https://opencode.ai). Claude Code, Codex... pick your poison.

## Cook it

Start here. [`/cook`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/cook/SKILL.md) takes an open-ended request all the way to a landed PR — unattended.

- Reframes the request, sets up a worktree + draft PR, then plans, implements, polishes, and waits on CI
- `--max` adds the extra rigor passes: `/polish-plan` and `/polish-implementation`
- Uses the other skills in this repo along the way (`/atk-plan`, `/polish-implementation`, `/atk-pr-autofix`, …), plus optional dependencies when you have them

Recommended invocation: `/goal /cook <request>` — the `/goal` wrapper keeps the run going until the request is done, rather than stopping after the first reply.

```
/goal /cook i want to implement config via c12 npm package
```

## Doing it by hand

Every step `/cook` automates can also be run yourself. See [skills/](skills/) and [`docs/skills.md`](./docs/skills.md) for the full skill reference.

### Plan it

Start with [`/atk-plan`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/atk-plan/SKILL.md). This is my replacement for plan mode.

- Makes reasonable judgement calls instead of interviewing you; every call is
  documented under `## Decisions` for your veto at review
- Easily-skimmable output (Grounded facts, Steps, Risks)
- Works for all agents (including Pi which has no plan mode)
- Example: [example-plan.md](./docs/example-plan.md)

```
/atk-plan i want to implement config via c12 npm package
```

### Polish the plan

Use [`/polish-plan`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/polish-plan/SKILL.md) after creating a plan.

- Runs the plan through a subagent review loop (up to 7 passes)
- Applying fixes until there are no more changes needed

### Implement the plan

Implement the plan as you normally would (I suggest `/goal implement this plan`, as supported by many harnesses by default). When the plan is split across several PRs, `/cook` fans the work out itself — one worktree per PR, unblocking dependents as their base branch lands code (see its [`implement-plan.md`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/cook/implement-plan.md)).

<details>

<summary>Example</summary>

Here's one I would use:

```
/goal First, make empty commit then create draft PR (use the `/pr-description` skill).
Then implement the plan as described, correctly and completely.
Ensure that the `/polish-implementation` skill (using Oracle agent type if available; else, Opus) is used afterwards and has completed successfully.
Ensure `/trim-tests-and-comments` skill was used, and that no other changes to tests are needed.
Ensure the changes are committed and pushed to Git.
Ensure `/atk-pr-autofix` is used and runs successfully.
Ensure CI is passing in GitHub. Ultrathink. Plan: <plan file here>
```

</details>

### Polish the implementation

Use [`/polish-implementation`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/polish-implementation/SKILL.md) after implementing a plan.

- Requires a PR for the branch (creates a draft one automatically if missing)
- Findings are posted as self-review threads on the PR, then fixed, replied to, and resolved — durable across passes, unlike a purely local review loop
- Stops when a pass finds nothing new, up to 10 passes

### Watch CI

Use [`/atk-pr-autofix`](https://github.com/rstacruz/agentic-toolkit/blob/main/skills/atk-pr-autofix/SKILL.md) to monitor a PR until CI passes or needs intervention.

- Waits for CI to be green
- Addresses CI failures automatically
