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

See [docs/skills.md](./docs/skills.md).
