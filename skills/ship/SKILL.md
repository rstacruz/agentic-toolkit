---
name: ship
description: Attend to an open-ended request. Only use when user explicitly asks for this.
---

## Goals

Definition of done: an open-ended request delivered as a verified result via a reframe → plan → implement → polish pipeline.

- Plans:
  - [ ] Plan created for human review
  - [ ] Plan is in `$atk-plan` format (Implementation steps, Decisions, etc)
  - [ ] Plan polished via `$polish-plan` (only with `--max`, and not for trivial plans)
- Code changes:
  - [ ] Worked on in a worktree (not the main working copy)
  - [ ] Worked on in a branch
  - [ ] Verified through `$atk-pr-autofix`; plus `$polish-implementation` when `--max` (unconditional on task size or review-effort)
  - [ ] Impact on real production data analysed and posted (only when relevant; see `impact-analysis()`)
  - [ ] Added prose (markdown and code comments) is concise, non-repetitive, and readable
  - [ ] Readable PR description
  - [ ] CI passing
- Operational:
  - [ ] Kept the user informed on Slack every 15m until resolved (if Slack is available)
  - [ ] Orchestrated with subagents to keep a long-running high-level context window

## Input

- `$request` - required
- `$plan_file` - path to an existing plan; otherwise one is made first
- Options:
  - `--interactive` - pause at confirmation gates for human review; default is unattended
  - `--skip-plan` - no need to plan
  - `--max` - enable the extra rigor passes: `$polish-plan` and `$polish-implementation`. Off by default

## Skill dependencies

Read these to understand context:

- `$atk-plan`
- `$polish-plan`
- `$polish-implementation`
- `$atk-pr-autofix`
- `$pr-description` - for PR description
- `$pr-risk-assessment` - effort level
- `$worktrunk` - optional; used by prepare-worktree() when available
- `$implement-plan` - builds the PR graph, spawns unblocked PRs, monitors until all land
- `$minimise-pr-comments`
- `$trim-tests-and-comments`
- `$prose-deslop`
- `$skimmable` - optional; formatting guidelines when available
- `$pr-review-guide`
- `references/impact-analysis.md` - guidelines for `impact-analysis()`

## Workflow

Follow these instructions; do not assume tasks are too small.

```pseudocode
begin({ $request, $plan_file, … }) {
  reroute-if-needed()

  reframe-request($request)
  notify(Acknowledge, restate reframed request, say that answer is in flight)

  # -- plan phase --
  prepare-worktree()
  create-draft-pr()
  notify(PR created, planning now)
  status-loop() # every ~15m while work is in flight; no-op without a loop tool

  unless (--skip-plan) {
    if (sufficiently-scoped plan already exists in context or tickets) {
      $plan_file ??= ingest from context
    } else {
      $plan_file ??= subagent(fork) { plan() }
    }

    # must return: plan file path, review-effort level (L1-L5), multi-PR (y/n)
    notify(Plan is available: <plan comment url> <plan file>)

    # interactive mode pauses for review; default mode continues automatically
    if (review-effort == L5) {
      confirm-with-user("Is plan OK? Ready to <next step>?")
    }

    # polish only with --max; even then, skip super-easy plans
    if (--max and review-effort >= L2) {
      /polish-plan
    }

    # interactive mode pauses for review; default mode continues automatically
    if (review-effort >= L3) {
      confirm-with-user("Ready to implement?")
    }
  }

  # -- implement phase --
  if ($plan_file and it is split into multiple PRs) {
      Close original PR
      /implement-plan $plan_file
      # /implement-plan only waits for code to land, not CI — each spawned
      # worker's #implement step must still run atk-pr-autofix (and
      # polish-implementation if --max) before this counts as "ready".
      # Pass --max through to workers.
  } else {
      subagent { implement() }
      # implement() can run long (atk-pr-autofix polls CI), up to 1h in some cases
  }

  # skip silently otherwise; see references/impact-analysis.md
  if (change affects behavior that production data can measure over the last 30 days) {
    subagent { impact-analysis() }
  }

  update PR title and description based on plan via `/pr-description` skill

  sanity-check()
  subagent { apply /minimise-pr-comments } # keep it easy to read
  write-handover()

  # write PR review guide comment
  /pr-review-guide

  notify(All PRs ready and passing CI)
}
```

### reroute-if-needed()

This workflow is intended for shipping PRs.
However, this skill tends to be requested for things better handled by other workflows. Pass it off if needed.

- Short question --> answer right away
- Review a pull request --> `$atk-code-review` skill

### prepare-worktree()

Ensure that we're working in a fresh worktree.

If pwd is:

- the project we're working on, and
- is in a branch that is not `main`, and
- it has no differences from `main`,

...then use it. Otherwise, prepare a worktree:

- Use the `$worktrunk` skill's `wt switch --create $branch-name` when available; otherwise `git worktree add`.
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

### notify()

Notify progress in the chat.

For final notification, give when available:

- PR link, plan file location, worktree path, branch name, env `$CLAUDE_CODE_SESSION_ID`
- If using Claude Code: "Resume with cd <dir> && claude --resume <session-id>"

### status-loop()

While the run is in flight, notify the user a short status update every ~15m (Slack or chat, when available).

- Needs a loop/cron tool (Claude Code: `/loop`, CronCreate); skip it when the harness has none — see Guidelines.
- Keep it one line: what step is running, and what is pending.

### plan()

```
def plan($request) {
    # plan and write to markdown file
    /atk-plan $request

    subagent { reformat plan to be /skimmable }
    post-pr-comment()

    return { plan_file, review-effort, multi-PR: y/n }
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

    # only with --max. When enabled, no review-effort or "task is small"
    # judgment skips it
    if (--max) {
      /polish-implementation
    }

    # ensure tests and comments are lean; use fresh subagent.
    # unattended runs skip its approval gate — the PR is the review surface
    subagent { apply /trim-tests-and-comments }

    prose-deslop()

    /atk-pr-autofix
    # atk-pr-autofix polls CI, which can run long. Whatever happens, end
    # with a concrete report: files changed, test/type-check results, and
    # current CI state (pass/fail/pending — name what's still pending). A
    # bare "waiting on CI" with no data is not an acceptable final report.
}
```

### prose-deslop()

Spawn a subagent that edits only lines added on this branch (diff against the base), fixing what `$prose-deslop` finds:

- Markdown prose: apply `$prose-deslop` and `$skimmable`.
- Inline code comments: apply `$prose-deslop`.

Commit and push the result.

### impact-analysis()

Estimate how many production records the change affects, positively and negatively (last 30 days). Follow `references/impact-analysis.md`; post the result on the PR and the linked ticket.

- If the result shows the change is riskier or less useful than assumed, say so in the PR description and `notify()`.
- Link the comment from `write-handover()`; don't repeat the numbers.

### confirm-with-user()

Ask user to review before continuing only when `--interactive` is passed.
Otherwise, skip this and pick the answer that will continue the workflow.

### sanity-check()

- [ ] PR is open, has accurate title and description
- [ ] CI is passing

### write-handover()

write handover doc and leave it as a PR comment. Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead. Include context that may not be there — eg, decisions done midway through implementation.

General format:

~~~ markdown
# :compass: Handover

... {contents here}

---

Get your agent to continue from this session:

```
Read <PR URL> and <GitHub comment URL> for context, let's continue work from here.
```
~~~

## Guidelines

- Use subagents liberally. Act as an orchestrator.
- If Slack tools are not available, ignore all Slack directives in this skill.
- If `/loop` tools (eg, CronCreate) are unavailable, ignore those — loops are a Claude Code feature.
- When invoking subagents, ask them to read this `$ship` skill so they understand context.
- When invoking subagents, pass `--max` through if it was given.
- Planning subagent:
  - If using Claude Code: use *general-purpose* subagent with model=Opus
  - If *agent="reviewer"* is available, use that
- Trim tests / minimise subagent:
  - If *agent="sonic"* is available, use that
