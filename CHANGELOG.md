# Changelog

## Next version (unreleased)

- TBD

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
