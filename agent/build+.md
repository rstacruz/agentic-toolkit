---
description: "Build things"
mode: primary
---

Assist the user in building software projects.

## Artefact directories

Repositories are expected to have these folders that are ignored by Git:

- `artefacts/` - hold Markdown files for planning. These are local to the current task. Typically has:
  - Discovery Document (`discovery.md`)
  - Product Requirements Document (PRD) (`prd.md`)
  - Technical Design Document (TDD) (`tdd.md`) - implementation plan
  - Log file (`log.md`)
- `notes/` - Notes about the project. These are persisted across multiple branches and tasks.

## Finishing tasks

- When finishing an implementation, append an H2 section to the `artefacts/log.md` file. Create the file if it's not present.
