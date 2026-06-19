# Changelog

### [v4](https://github.com/rstacruz/agentic-toolkit/tree/v4)

- Replaces the entire skill set with the atk4 family.
- Drops turboplan, turbobuild, spec-tech-design, spec-product-requirements,
  spec-implementation-plan, refine-spec, implement-spec-subagent,
  review-changes, mermaid-diagrams, and polish.
- Adds polish-implementation, polish-plan, pr-plan, triangulate-plan.
- Updates brainstorm (adds related-resources search, post-implementation
  verification, suggested plan structure) and babysit-pr (adds Copilot
  review re-request and review-wait/triage phases).
- Renames skill directories: drops the `atk.` prefix.
- Rewrites docs around the new flow.
- Removes `pull.sh` and `push.sh`; these were local sync tooling and are no longer published.
- Switches versioning to sequential (v4).

### [main](https://github.com/rstacruz/agentic-toolkit/tree/main)

- TBD
- Merges `implement-spec` into `turbobuild`; `turbobuild` now strengthens ticket planning when needed before running ticket-by-ticket execution.
- Renames the public build skill from `implement-spec` to `turbobuild` and updates docs accordingly.
- Removes atk-extras, spec-mode

### [v26.03](https://github.com/rstacruz/agentic-toolkit/tree/v26.03)

- Most compact version of the skill-first toolkit.
- Moves foundation skills like `coding-practices`, `testing-practices`, and `refine-tests` into a separate extras bundle.
- Compared with `v26.01`, the visible changes are mostly docs and layout cleanup.

### [v26.01](https://github.com/rstacruz/agentic-toolkit/tree/v26.01)

- Introduces the skill-first workflow: `brainstorm -> spec-mode -> implement-spec -> refine/review`.
- Adds the spec/refine/review family and newer operational skills like `babysit-pr`.
- README becomes much slimmer and points to `docs/skills.md` for the quick start.

### [v25.12](https://github.com/rstacruz/agentic-toolkit/tree/v25.12)

- Uses the older `plan+`, `/proceed`, and `/continue-from-here` workflow.
- README is more command- and prompt-oriented, with detailed usage examples inline.
- Predates the later spec-oriented docs and skill layout introduced in `v26.01`.
