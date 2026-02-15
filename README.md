# Agentic toolkit

Some indispensable prompts and tools I use with [OpenCode](https://opencode.ai/).

## Installation

Consider this repo as a glimpse into what I do, *not* a pre-packaged system to install. I recommend perusing it, take what you need, and edit it to your use case.

1. Install [OpenCode](https://opencode.ai).
2. Set up artefacts directories:
  - Add to global gitignore: `echo artefacts >> ~/.config/git/global_ignore` (or wherever your global ignore is)
  - Exclude from global rgignore (for OpenCode): `echo '!artefacts' >> ~/.rgignore`
3. Pick-and-choose what you want to copy:
  - Copy `agent/` files into `~/.config/opencode/agent/`
  - Copy `skill/atk/` files into `~/.config/opencode/skill/atk/`

Not an OpenCode user? These are [Agent Skills](https://https://agentskills.io/home), it should work with Claude Code and Gemini CLI and other tools (with some edits).

## Contents

- [skill/atk/](skill/atk/) - the main skills
- [skill/atk-extras/](skill/atk-extras/) - skills that aren't really part of the plan-and-execute loop, but still useful nonetheless

## Quick start

Spec mode will do plan with PRD, technical implementation, tickets, and automatically refine continuously.

> Use spec mode to plan: migrate from useState to Zustand

Execute plans in Ralph-style loop.

> /execute-plan @artefacts/plan-zustand-migration.md
