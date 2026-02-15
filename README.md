# Agentic toolkit

Some indispensable prompts and tools I use with [Opencode](https://opencode.ai/).

## Installation

Consider this repo as a glimpse into what I do, *not* a pre-packaged system to install. I recommend perusing it and taking what you need.

1. Install [OpenCode](https://opencode.ai).
2. Set up artefacts directories:
  - Add to global gitignore: `echo artefacts >> ~/.config/git/global_ignore` (or wherever your global ignore is)
  - Exclude from global rgignore (for OpenCode): `echo '!artefacts' >> ~/.rgignore`
3. Pick-and-choose what you want to copy:
  - Copy `command/atk/` files into `~/.config/opencode/command/atk/`
  - Copy `skill/atk/` files into `~/.config/opencode/skill/atk/` (ensure you use OpenCode 1.0.190+)

Not an OpenCode user? These are pretty tool-agnostic, it should work with Claude Code and Gemini CLI and other tools (with some edits).

## Contents

See [skill/atk/](skill/atk/) for the skills.

## Quick start

Spec mode will do plan:

> Use spec mode to plan: migrate from useState to Zustand

Execute plans in Ralph-style loop:

> /execute-plan @artefacts/plan-zustand-migration.md
