# Agentic Toolkit

A set of prompts and tools I use with [OpenCode](https://opencode.ai/), packaged as [Agent Skills](https://agentskills.io/home) so they can travel to other compatible tools too.

Treat this repo as a glimpse into my setup, not a sealed product. Use the parts you want and adapt them.

## Installation

Install [OpenCode](https://opencode.ai). Claude and Codex are also supported. Then:

```sh
# Add `artefacts` to your global gitignore (wherever it might be)
git config --global core.excludesfile /.config/git/global_ignore
echo artefacts >> ~/.config/git/global_ignore

# Exclude `artefacts` from your global `rgignore` for OpenCode search
echo '!artefacts' >> ~/.rgignore

# If you use OpenCode, copy the `agent/` files into `~/.config/opencode/agent/`
mkdir -p ~/.config/opencode/agent
curl -L https://raw.githubusercontent.com/rstacruz/agentic-toolkit/main/agent/general-alpha.md -o ~/.config/opencode/agent/general-alpha.md
curl -L https://raw.githubusercontent.com/rstacruz/agentic-toolkit/main/agent/general-beta.md  -o ~/.config/opencode/agent/general-beta.md

# Finally, install the skills:
npx skills add rstacruz/agentic-toolkit
```

These skills use the [Agent Skills](https://agentskills.io/home) format, so they work across compatible tools. The `agent/` directory is OpenCode-specific.

## Contents

- [skills/](skills/) - the main skills

## Quick start

### Starting from scratch

Start with `$brainstorm`.

*When to use:* when you are starting from scratch and only have a vague idea.

*What it does:* it turns a rough prompt into a stronger one by doing research and asking clarifying questions.

```
/brainstorm i want to implement config via c12 npm package
```

*Example:* [`example-plan.md`](./docs/example-plan.md) — example plan produced by `$brainstorm`

### Hardening a plan

Use `$turboplan` to improve a plan.

*When to use:* when you already have a plan from `$brainstorm` or another planning pass.

*What it does:* it expands the plan with concrete implementation details, then refines it in multiple passes using two LLMs (Opus and GPT 5.4 High by default).

```
> ...
> Plan is done.

use turboplan
```

*Example:* [`example-spec.md`](./docs/example-spec.md) - example full plan document (PRD + TDD + tickets) from the planning workflow.

### Build with subagents

Use `$turbobuild` to build a plan.

*When to use:* when a plan is ready for implementation. Great follow-up to `$turboplan`, but it can work with any plan.

*What it does:* it splits a plan into smaller tickets, then assigns subagents to build them (Opus by default).

Strongly inspired by Ralph Loop principles and Copilot /fleet.

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

*When to use:* after making follow-up changes after `$turbobuild`, or when working on an existing pull request.

*What it does:* it makes a change pull-request ready through multiple rounds of subagent review.

This is done automatically by `$turbobuild`.

Compare with Copilot, Claude and Codex reviews, but automated.

See [`docs/skills.md`](./docs/skills.md).
