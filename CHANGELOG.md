# Changelog

## v2026.09.04

### Breaking changes

- The skill set is replaced by the atk4 family. The flow is now: plan
  (`atk-plan`) → refine (`polish-plan` / `triangulate-plan`) → implement
  (`polish-implementation`) → ship (`atk-pr-autofix`).
- Skill directories are now bare names in `skills/` — the `atk.` prefix is
  gone.
- The pre-atk4 skills no longer ship: `plan-mode`, `ralph-loop`, the
  `spec-*`/`refine-*` family, `turboplan`, `turbobuild`, `babysit-pr`,
  `brainstorm`, `turbo-brainstorm`, and `megaplan` are all dropped or
  renamed.
- The OpenCode-specific `agent/` directory and its install instructions are
  removed, along with the `command/` structure — commands are now skills.

### Added

- `atk-plan` — turns a rough idea into an actionable plan by making
  judgement calls instead of interviewing; every call is documented under
  `## Decisions` for your veto at review. The replacement for plan mode and
  `brainstorm`.
- `atk-pr-autofix` — babysits a PR into a merge-ready state: fixes CI
  failures, addresses review comments, resolves threads, and waits for
  re-review. Supports `--comments` and `--no-copilot` flags.
- `atk-code-review` — structured code review that posts findings as GitHub
  PR review threads (or plain text when no PR exists).
- `pr-risk-assessment` — rates PRs on a 5-level risk scale to triage how
  carefully they need reviewing.
- `metaplan` <sup>experimental</sup> — a living planning notebook for
  multi-slice projects: numbered requirements, decisions, risks, and
  grounded facts with cross-referenced IDs, plus a work-plan tracker.
- `polish-plan`, `triangulate-plan`, `polish-implementation` — the atk4
  loop that strengthens a plan, generates an alternative perspective, and
  reviews the implementation against the PR.

### Changed

- `babysit-pr` evolved into `atk-pr-autofix` with a wait/triage loop and
  PR-status reporting.
- `megaplan` was renamed to `metaplan`.
- Versioning is now calver: releases are tagged `vYYYY.MM.DD`.
- Docs are rewritten around the new flow: `README.md` quick start,
  `docs/skills.md` skill map, and standardized reviewer verdict/banner
  formats.

### Removed

- `pull.sh` and `push.sh` — local sync tooling, no longer published.
- `pr-plan` (held back), `mermaid-diagrams`, and `polish` (superseded by
  `polish-implementation`).

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
