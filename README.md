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

See [docs/skills.md](./docs/skills.md).

## Previous versions

### [v26.03](https://github.com/rstacruz/agentic-toolkit/tree/v26.03)

- Most compact version of the skill-first toolkit.
- Moves foundation skills like `coding-practices`, `testing-practices`, and `refine-tests` into `skill/atk-extras/`.
- Compared with `v26.01`, the visible changes are mostly docs and layout cleanup.

### [v26.01](https://github.com/rstacruz/agentic-toolkit/tree/v26.01)

- Introduces the skill-first workflow: `brainstorm -> spec-mode -> implement-spec -> refine/review`.
- Adds the spec/refine/review family and newer operational skills like `babysit-pr`.
- README becomes much slimmer and points to `docs/skills.md` for the quick start.

### [v25.12](https://github.com/rstacruz/agentic-toolkit/tree/v25.12)

- Uses the older `plan+`, `/proceed`, and `/continue-from-here` workflow.
- README is more command- and prompt-oriented, with detailed usage examples inline.
- Predates the later spec-oriented docs and skill layout introduced in `v26.01`.
