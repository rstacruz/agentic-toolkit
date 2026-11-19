# Skills

## Skill map

```mermaid
graph LR
  cook["cook"] --> atk_plan["atk-plan"]
  atk_plan --> polish_plan["polish-plan"]
  atk_plan --> triangulate_plan["triangulate-plan"]
  atk_plan --> pr_risk_assessment["pr-risk-assessment"]
  polish_plan --> self_review["atk-pr-autofix --reviewers self"]
  triangulate_plan --> self_review
  self_review --> atk_code_review["atk-code-review"]
  self_review --> trim_tests_and_comments["trim-tests-and-comments"]
  trim_tests_and_comments --> deslop_prose["deslop-prose"]
  deslop_prose --> atk_pr_autofix["atk-pr-autofix"]
  atk_pr_autofix --> minimise_pr_comments["minimise-pr-comments"]
  minimise_pr_comments --> pr_review_guide["pr-review-guide"]

  cook -.-> worktrunk["worktrunk (external)"]
  cook -.-> pr_description["pr-description (external)"]
  cook -.-> impact_analysis["impact-analysis (external)"]
  cook -.-> skimmable["skimmable (external)"]
  atk_plan -.-> skimmable
  atk_code_review -.-> skimmable
```

Solid edges trace `/cook`'s plan → implement → ship pipeline; dashed edges are optional dependencies, used when present.

## Skills reference

### Orchestration

- [`/cook`](../skills/cook/SKILL.md) — Runs an open-ended request through the whole pipeline unattended: reframe → plan → implement → polish → CI, in a worktree and branch with a draft PR

Cook runs under goal mode: `/goal /cook <request>` — the `/goal` wrapper keeps the run going until the request is done.

### Planning

- [`/atk-plan`](../skills/atk-plan/SKILL.md) — Compact, non-interactive plan in a fixed format: decides everything for the user, never asks, saves the Markdown to `~/.artefacts/`
- [`/atk-plan-legacy`](../skills/atk-plan-legacy/SKILL.md) — The previous fuller planner: decide-first ladder, stakes levels, grounds facts, and asks on mid/high-stakes branches with `--interactive`

### Refining

- [`/polish-plan`](../skills/polish-plan/SKILL.md) — Strengthen a plan into an implementation-ready plan via a subagent review loop, catching inaccuracies before execution
- [`/triangulate-plan`](../skills/triangulate-plan/SKILL.md) — Generate an independent second opinion on a plan and merge the best of both into an implementation-ready plan

### Implementing

- [`/atk-pr-autofix --reviewers self`](../skills/atk-pr-autofix/SKILL.md) — Self-review loop against a GitHub PR: `/atk-code-review` threads get fixed, replied to, and resolved, up to 4 passes

### Shipping

- [`/atk-pr-autofix`](../skills/atk-pr-autofix/SKILL.md) — Monitor a PR's CI status in a loop until it passes or needs human input
- [`/pr-review-guide`](../skills/pr-review-guide/SKILL.md) — Reviewer walkthrough narrative: call graph, chapters, sequence diagrams, decision points
- [`/trim-tests-and-comments`](../skills/trim-tests-and-comments/SKILL.md) — Reports, then cuts, weak tests and low-value comments added on the branch
- [`/deslop-prose`](../skills/deslop-prose/SKILL.md) — Flags AI-sounding prose, clichés, filler, and unnatural phrasing in added prose and code comments
- [`/minimise-pr-comments`](../skills/minimise-pr-comments/SKILL.md) — Hides low-signal PR comments and reviews (bot noise, superseded review passes) while keeping signal

### Reviewing

- [`/atk-code-review`](../skills/atk-code-review/SKILL.md) — Structured code review that posts findings as GitHub PR review threads (or plain text when no PR exists)
- [`/pr-risk-assessment`](../skills/pr-risk-assessment/SKILL.md) — Rates PRs on a 5-level risk scale to triage how carefully they need reviewing

## Optional dependencies

Used when present, with fallbacks otherwise:

- `/pr-description` <sup>external</sup> — PR title/body guidelines for `/cook`; a plain summary is written when it is missing
- `/impact-analysis` <sup>external</sup> — production-data estimates for `/cook`; the analysis is skipped when it is missing
- [`/worktrunk`](https://github.com/max-sixty/worktrunk) <sup>external</sup> — worktree management for `/cook`'s implement-plan.md; plain `git worktree add` otherwise
- [`/skimmable`](https://github.com/rstacruz/skimmable) <sup>external</sup> — formatting guidelines for `/cook`, `/atk-plan`, and `/atk-code-review`

## Make them your own

These skills are starting points, not sealed products: copy them into your setup and rewrite them for your conventions, tooling, and review process. The [optional dependencies](#optional-dependencies) above are the most personal of the lot — write your own versions of those rather than importing mine.
