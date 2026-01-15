---
name: ralph-loop
description: tbd
---

## Ralph loop

A "ralph loop" iterates through a plan in a story-by-story basis.

Pre-requisites:

1. Ensure there is a PRD as a Markdown file (`artefacts/prd.md` by default)
2. Ensure the PRD has user stories
3. Ensure user stories have acceptance criteria
4. Ensure there is a progress file (`artefacts/progress.md`) - create an empty one if not

Workflow:

1. Spawn a @general agent to do the instructions in `<skill_dir>/once.md`. Use its instructions in verbatim, but change the file paths if needed, and include additional instructions / preamble if given by user.

2. Verify that the agent created a git commit. If it didn't, create one.

3. If the agent reports PRD_COMPLETE, stop. otherwise, repeat step 1 (up to 10 times max).


