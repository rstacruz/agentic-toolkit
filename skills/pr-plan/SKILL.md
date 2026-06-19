---
name: pr-plan
description: Draft a PR plan that breaks an existing plan into smaller, reviewable pull requests.
---

Draft a PR plan for an existing plan.

## Workflow

1. Find the plan.
   - If it does not exist, abort and prompt the user first.
2. Present options.
3. Update the plan with a PR plan.

## PR plan

A PR plan breaks a plan down into smaller PRs.

Benefits of multiple PRs:

- Simpler reviewing.
- Controlled deploy order. For example, database schema changes may need to go out before dependent services are updated.

For every PR:

- Give it a branch name.
- Specify its intended base branch.
