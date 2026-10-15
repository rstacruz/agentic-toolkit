---
name: implement-plan
description: Implements a plan via subagents — one worktree per PR (or a single PR if the plan isn't split), starting with unblocked PRs and unblocking dependents as their base branch lands a real commit. Use for implementing a plan/metaplan, especially with multiple stacked/dependent PRs. Stops once every PR has landed code.
---

**Scope: get code written, in parallel, across every PR in a plan.**

## Workflow

```
set -eou pipefail

begin {
  #1-build-pr-graph
  #2-show-pr-graph   // print it, then spawn — do NOT ask to confirm

  loop {
    #3-spawn-unblocked-prs
    #4-monitor-for-activity {
      on (LANDED) {
        #5-unblock
      }
      if (STUCK) {
        continue and flag later
      }
    }
  } until(nothing to do)

  #6-report
}
```

## 1. Build the PR graph

Find each plan's PR breakdown — there may be one plan or several, merge them into a single graph.

- Look for a "Ship as N PRs" / "Implementation steps" section per plan — eg. `### PR-A`, `### PR-B` headings with "Requires PR-X merged first".
- **Plan does not state dependencies?** Treat PRs as independent (base = default branch), unless the plan's ordering or the code makes the dependency obvious (eg, one PR calls something another adds).
- **Not split into PRs?** Treat the whole plan as a single PR — no `depends_on`, base = default branch.
- **Multiple plans?** Keep ids unambiguous across plans; cross-plan `depends_on` is fine.

For each PR, note:

- **id** — eg. `PR-A`
- **what to implement** — short description, or a pointer to the plan file + section
- prefer the pointer over inlining the whole description — keeps subagent prompts short
- **`depends_on`** — other PR ids that must land first (stacked work)
- **base branch** — repo default, or the dependency's branch if stacked

## 2. Show the plan

Print a table, then **go straight to spawning — do not ask the user to confirm the graph.** The table is there so they can follow along and interrupt if it looks wrong, not as a gate.

| PR id | depends_on | base branch | what to implement |
|---|---|---|---|
| ... | ... | ... | ... |

Surface anything genuinely undecided as a note *alongside* the spawn, not as a blocking question. Two exceptions still warrant asking first:

- The plan has no usable PR breakdown and the split would be your invention rather than the plan's.
- A PR's scope depends on an unresolved decision in the plan, so spawning would hardcode a guess.

## 3. Spawn unblocked PRs

A PR is unblocked once every `depends_on` entry has landed (step 4).

```sh
# one worktree per PR (Worktrunk when available; else `git worktree add <dir> -b <branch>`)
wt switch --create <branch> --base <base-branch> --no-cd --no-hooks
# --no-cd leaves you in the caller's directory: enter the new worktree first
cd <worktree-dir>
# empty commit + push, so gh has something to open a PR against
git commit --allow-empty -m "start <id>" && git push -u origin HEAD
gh pr create --draft --title "<title>" --body ""
```

Then spawn a subagent in that worktree (in Claude Code: the `Agent` tool, without `isolation: "worktree"` — the worktree already exists):

```
You are working in <worktree-dir> on branch <branch>.
All edits must stay in that worktree.
Implement: <PR description or plan-file pointer>.
Then commit and push, and finish the run with `$polish-implementation` (when `--max`)
and `$atk-pr-autofix` — see `$ship`'s implement() for the sequence.
```

- Omit `--base` for PRs with no dependency (default branch).
- Get `<worktree-dir>` from the `wt switch` output or `wt list`.
- Append a line to a tracking file: `<id> <base> <branch> <worktree-dir>`
- **Don't** let the subagent tool create its own isolated worktree (Claude Code: `Agent({isolation: "worktree"})`) — it keys the worktree to the harness's internal agent id on a throwaway branch, not `<branch>`. Pre-create each worktree (the `$worktrunk` skill's "Parallel sub-Agents" pattern, when available) so path and branch stay aligned.

## 4. Monitor for activity

Every branch starts with one empty commit (step 3) — branch existence isn't "landed", a non-empty diff is.

```sh
bash <SKILL_DIR>/scripts/monitor.sh <tracking-file> [poll-seconds]
```

- Emits one `LANDED <id> <branch>` line per PR as it lands.
- Exits once every id has landed.
- Run it as a background process (in Claude Code: the `Monitor` tool with `persistent: true`) and react to each `LANDED` event.

## 5. Unblock and repeat

On each `LANDED` event:

- Re-scan the graph for any not-yet-spawned PR whose `depends_on` is now fully landed.
- Spawn it (step 3), then append it to the tracking file so the running monitor picks it up too. If the monitor already exited (it stops once every id it has seen has landed), start it again.

**Stuck detection:** implementation runs take roughly 5min–1hr. Past that with no diff → flag as stuck in the final report, don't let it block the others.

## 6. Report

| PR id | branch | PR URL | landed | notes |
|---|---|---|---|---|
| ... | ... | ... | y/n + rough time | stuck ones called out |

State explicitly: this only covers implementation. Nothing further to do or recommend once every PR has landed.

## Guidelines

- Review, CI, merge are not this skill's job. Don't recommend a next step for them — the spawned agent's own run handles whatever comes after.
- Runs entirely as in-process subagents — no terminal multiplexer (tmux, zellij, …) required. If a metaplan is known, update its work-item status/PR link after each spawn.
- Tradeoff vs a terminal-pane design: each PR now runs as a subagent of this session, not a detached pane. If this session ends mid-run, in-flight subagents end with it — there's nothing surviving independently to reattach to.

