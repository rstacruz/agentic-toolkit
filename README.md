# Agentic toolkit

Some indispensable prompts and tools I use with [OpenCode](https://opencode.ai/), packaged as [Agent Skills](https://agentskills.io/home) so they can travel to other compatible tools too.

## Installation

Consider this repo as a glimpse into what I do, not a sealed product. Use the parts you want and adapt them to your setup.

1. Install [OpenCode](https://opencode.ai).
2. Add `artefacts` to your global git ignore:
   - `echo artefacts >> ~/.config/git/global_ignore`
3. Exclude `artefacts` from your global `rgignore` for OpenCode search:
   - `echo '!artefacts' >> ~/.rgignore`
4. For OpenCode only, copy `agent/` files into `~/.config/opencode/agent/`.
5. Install the skills:
   - `npx skills add rstacruz/agentic-toolkit`

These skills are written in the [Agent Skills](https://agentskills.io/home) format, so the skills themselves work with Agent Skills-compatible tools. The `agent/` directory is OpenCode-specific.

## Contents

- [skills/](skills/) - the main skills

## Quick start

### Starting from scratch

Start with the brainstorm skill.

*When to use:* from scratch. Works great when you have a vague idea.

*What it does:* it refines your prompt into a better prompt. It does this with research and asking you questions.

```
/brainstorm i want to implement config via c12 npm package
```

*Example:* [`example-seed.md`](./docs/example-seed.md) — example plan seed produced by `$brainstorm`

### Hardening a plan

Use `$turboplan` to improve a plan.

*When to use:* you already have a plan (from your agwntw plan mode) or plan seed from `$brainstorm`

*What it does:* it expounds the plan with more concrete technical implementation details. Then it uses 2 LLM models (Opus and GPT 5.4 High by default) to refine it in multiple passes.

```
> ...
> Plan is done.

use turboplan
```

*Example:* [`example-spec.md`](./docs/example-spec.md) — example full spec document (PRD + TDD + tickets) from the planning workflow

### Build with subagents

Use `$turbobuild` to build a plan.

*When to use:* when a plan is ready for implementation. Great follow-up to `$turboplan`, but it can work with any plan.

*What it does:* Split a plan into smaller tickets, then assign subagents to build them (Opus by default)

SStrongly inspired by Ralph Loop principles and Copilot /fleet.

```
> ...
> Plan is done.

use turboplan

> ...
> Plan has been refined through 2 review passes.

use turbobuild

-or-

use turbobuild then create a draft pull request
```

### Polish an existing implementation

Use `$polish` to make a pull request ready for submitting.

*When to use:* after making follow-up changes after a `$turbobuild`, or on existing pull requests

*What it does:* makes a change pull-request ready with multiple rounds of subagent reviews.

This is done automatically by `$turbobuild`.

Compare with Copilot, Claude and Codex reviews, but automated.

See [docs/skills.md](./docs/skills.md).
