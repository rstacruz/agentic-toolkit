---
name: cook
description: Attend to an open-ended request. Only use when user explicitly asks for this.
---

## Goals

Definition of done: an open-ended request delivered as a verified result via a reframe → plan → implement → polish pipeline.

- Plans:
  - [ ] Plan created for human review
  - [ ] Plan is in `/atk-plan` format (Implementation steps, Decisions, etc)
  - [ ] Plan polished via `/polish-plan` (only with `--max`)
- Code changes:
  - [ ] Worked on in a worktree (not the main working copy)
  - [ ] Worked on in a branch
  - [ ] Verified through `/atk-pr-autofix`; plus `/polish-implementation` when `--max`
  - [ ] Verified locally by exercising the change; evidence posted on PR (see `verify-locally()`)
  - [ ] Impact on real production data analysed and posted (only when relevant; see `impact-analysis()`)
  - [ ] Added prose (markdown and code comments) is concise, non-repetitive, and readable
  - [ ] Readable PR description
  - [ ] CI passing
- Operational:
  - [ ] Orchestrated with subagents to keep a long-running high-level context window

## Input

- `$request` - required
- `$plan_file` - path to an existing plan; otherwise one is made first
- Options:
  - `--interactive` - pause for plan review before implementing; default is unattended
  - `--skip-plan` - no need to plan
  - `--max` - enable the extra rigor passes: `/polish-plan` and `/polish-implementation`. Off by default

## Skill dependencies

Read these to understand context:

- `/atk-plan`
- `/polish-plan`
- `/polish-implementation`
- `/atk-pr-autofix`
- `/pr-description` - optional, external; PR title/description guidelines when available
- `/worktrunk` - optional, external; used by prepare-worktree() when available
- `<skill-dir>/implement-plan.md` - builds the PR graph, spawns unblocked PRs, monitors until all land
- `/minimise-pr-comments`
- `/trim-tests-and-comments`
- `/deslop-prose`
- `/skimmable` - optional, external; formatting guidelines when available
- `/pr-review-guide`
- `/impact-analysis` - optional, external; guidelines for `impact-analysis()`
- `/page-screenshot` - optional, external; captures locally served pages in `verify-locally()`

## Workflow

Follow these instructions; do not assume tasks are too small.

```pseudocode
begin({ $request, $plan_file, … }) {
  reroute-if-needed()

  reframe-request($request)

  # -- plan phase --
  prepare-worktree()
  create-draft-pr()

  unless (--skip-plan) {
    if (sufficiently-scoped plan already exists in context or tickets) {
      $plan_file ??= ingest from context
    } else {
      $plan_file ??= subagent(fork) { plan() }
    }

    # must return: plan file path, multi-PR (y/n)

    if (--max) { /polish-plan }

    # unattended runs skip this and continue
    if (--interactive) { ask user: "Ready to implement?" }
  }

  # -- implement phase --
  if ($plan_file and it is split into multiple PRs) {
      Close original PR
      follow <skill-dir>/implement-plan.md
      # that reference only waits for code to land, not CI — each spawned
      # worker's #implement step must still run /atk-pr-autofix (and
      # /polish-implementation if --max) before this counts as "ready".
      # Pass --max through to workers.
  } else {
      subagent { implement() }
      # implement() can run long (/atk-pr-autofix polls CI), up to 1h in some cases
  }

  # skip silently otherwise; see the `/impact-analysis` skill when available
  if (change affects behavior that production data can measure over the last 30 days) {
    subagent { impact-analysis() }
  }

  update PR title and description via `/pr-description` (plain summary when unavailable); keep the Live verification table from `verify-locally()`

  sanity-check()
  subagent { apply /minimise-pr-comments } # keep it easy to read
  write-handover()

  # write PR review guide comment
  /pr-review-guide
}
```

### reroute-if-needed()

This workflow is intended for shipping PRs.
However, this skill tends to be requested for things better handled by other workflows. Pass it off if needed.

- Short question --> answer right away
- Review a pull request --> `/atk-code-review` skill

### prepare-worktree()

Ensure that we're working in a fresh worktree.

If pwd is:

- the project we're working on, and
- is in a branch that is not `main`, and
- it has no differences from `main`,

...then use it. Otherwise, prepare a worktree:

- Use the `/worktrunk` skill's `wt switch --create $branch-name` when available; otherwise `git worktree add`.
- For branch name, use format `<handle>/<three-word-max>`, where `<handle>` is the user's GitHub login (eg, `gh api user -q .login`).

### reframe-request($request)

Build an understanding of the `$request` and reframe it for clarity.

- Gather context: if the request points external sources (eg, Slack thread, Linear ticket), follow them.
- Find sources: Look for sources that would be relevant to the task at hand (links, files, etc).

Guidelines:

- Do not infer a solution (unless solution is part of request).

Example:

```
Remove the cancel button from the settings page.

Relevant sources:
- pages/Settings.tsx
- components/Cancel.tsx
- <https://...>
- /path/to/external-files

References:
- <links to tickets, slack threads, etc>
```

### plan()

```
def plan($request) {
    # plan and write to markdown file
    /atk-plan $request

    subagent { reformat plan to be /skimmable }
    post-pr-comment()

    return { plan_file, multi-PR: y/n }
}
```

**post-pr-comment():**

Post plan contents as comment on pull request. Wrap it in `### Plan (WIP): <short title> \n <short 1-sentence recap> \n \n <details><summary>Details</summary> ... </details>`.
If a plan comment was posted before, edit the old comment.

### create-draft-pr()

- Create an empty commit, push it, create draft PR

### implement()

```
def implement() {
    implement the plan
    commit && push

    if (--max) { /polish-implementation }

    # ensure tests and comments are lean; use fresh subagent.
    # unattended runs skip its approval gate — the PR is the review surface
    subagent { apply /trim-tests-and-comments }

    deslop-prose()

    /atk-pr-autofix
    # /atk-pr-autofix polls CI, which can run long. Whatever happens, end
    # with a concrete report: files changed, test/type-check results, and
    # current CI state (pass/fail/pending — name what's still pending). A
    # bare "waiting on CI" with no data is not an acceptable final report.

    # fresh subagent, so the implementer doesn't grade its own work
    subagent { verify-locally() }
    if (verify-locally() pushed fixes) { /atk-pr-autofix }
}
```

### deslop-prose()

Spawn a subagent that edits only lines added on this branch (diff against the base), fixing what `/deslop-prose` finds:

- Markdown prose: apply `/deslop-prose` and `/skimmable`.
- Inline code comments: apply `/deslop-prose`.

Commit and push the result.

### verify-locally()

- [ ] Changed behaviour exercised in the worktree, beyond tests
- [ ] Can't run locally → closest proxy (eg, script against the changed function), with the gap stated in the evidence
- [ ] Screenshots of UI or terminal output for anything visual, including dependency, tooling, or build-config changes that can affect rendered UI
- [ ] One screenshot per risky area, each captioned with what it proves (eg, "About page shows 10.6.3", "docs page renders source snippets")
- [ ] Locally served pages (eg, a static build served over HTTP) captured via `/page-screenshot` when available
- [ ] Evidence posted as one PR comment headed `### Live verification (local)` (the heading keeps it through `/minimise-pr-comments`); edited on re-runs
- [ ] Same screenshots in the PR description, as a captioned table under a *Live verification* heading that links to that comment

### impact-analysis()

Estimate how many production records the change affects, positively and negatively (last 30 days), following the external `/impact-analysis` skill. Post the result on the PR and the linked ticket; skip the analysis when the skill is not available.

- If the result shows the change is riskier or less useful than assumed, say so in the PR description.
- Link the comment from `write-handover()`; don't repeat the numbers.

### sanity-check()

- [ ] PR is open, has accurate title and description
- [ ] CI is passing

### write-handover()

Write handover doc and leave it as a PR comment.
Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.
Include context that may not be there — eg, decisions done midway through implementation.
Do not include context not relevant for continuing work. Eg: "state: draft", "CI green", "approval needed"

General format:

~~~ markdown
### :compass: Handover

- <condensed notes; 4 bullet points max>

<details>
<summary>Full content</summary>

... {contents here}

</details>
~~~

## Guidelines

- Use subagents liberally. Act as an orchestrator.
- When invoking subagents, ask them to read this `/cook` skill so they understand context.
- When invoking subagents, pass `--max` through if it was given.
- Planning subagent:
  - If using Claude Code: use *general-purpose* subagent with model=Opus
  - If *agent="reviewer"* is available, use that
- Trim tests / minimise subagent:
  - If *agent="sonic"* is available, use that
