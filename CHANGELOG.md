# Changelog

## v2026.01.15

**Added:**
- New skills: `analyse-and-review-pr`, `execute-plan`, `explain-code`, `mermaid-diagrams`, `refine-implementation`, `triangulate-plan`, `verify-implementation`, `high-density-writing-style`
- New command: `/triangulate-plan`
- Comprehensive READMEs for all `atk` skills
- Roadmap task sizing and phasing guide
- Quality gates and user stories sections in planning documentation

**Changed:**
- **High-density writing style** - Enforced terse, direct style for prompts and documents
- Major refactor of `plan-with-tdd-and-prd` skill
- Updated `pull.sh` to use `--delete` with `rsync`
- Refined `reflection` skill and command instructions
- Streamlined root `README.md`

**Removed:**
- Obsolete tool usage instructions from documentation

## v2026.01.04

**Breaking changes:**
- **New plan mode** - Replaced `plan+` mode with new `/plan` command and plan-mode workflow
- **Skills replaces agents** - No more agents, and commands are slimmer now with logic moved to skills
- **Organised into atk/** - commands now in `command/atk/`, skills in `skill/atk/` for easy updating

**Added:**
- Commands: `/plan`, `/reflect`, `/tdd`, `/discover`, `/explain-code`, `/preflight`, `/refine-plan`
- Skills: `plan-mode`, `execute-plan`, `reflect`, `generate-changelog`, `review-with-subagent`, `plan-feature-roadmap`, `solution-options-document`

**Changed:**
- Significantly enhanced `plan-with-tdd-and-prd` skill
- Updated installation instructions

**Removed:**
- Legacy `agent/plan+.md` (replaced by plan mode)

## v2025.12.23

Reference version with plan+ mode
