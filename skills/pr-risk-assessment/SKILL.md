---
name: pr-risk-assessment
description: Assesses pull requests or recently merged PRs on a 5-level risk scale, from "glance" to "war room". Use when the user asks for a risk assessment, "how risky is this PR", "review the last N PRs", or wants to triage which changes need careful review vs which are safe to ship.
---

# PR Risk Assessment

Classify each PR on a 5-level scale. **The level is a proxy for review effort required** — what the diff demands of a reviewer, not a category label. The level names are the scale — use them verbatim in the report.

## The 5 levels

| Level | Name | Means | Reviewing effort |
|---|---|---|---|
| 🟢 L1 | **glance** | No behavior change. Docs, comments, tiny data corrections. | Ship blindfolded. |
| 🟢 L2 | **skim** | Visual-only. Styling, refactors claiming behavior-identical, token swaps. | Tests/screenshots suffice. |
| 🟡 L3 | **spot-check** | Data batches (seeds, fixtures), or a simple feature confined to one subsystem with covering tests. Risk is quality, not crashes. | Verify locally, never hold global state in your head. Data: spot-check a sample, trust machine audits with caveats. Feature: read the logic once — tests pin the invariants. |
| 🟠 L4 | **audit** | Touches core state machines, reducers, persistence/migration, or spans multiple subsystems — the changes that take real effort to reason about. | Read line-by-line. One careful reviewer. |
| 🔴 L5 | **war room** | Security, auth, payments, money, data loss, trust boundaries, permissions, secrets. | 3 engineers review. Block merge on doubt. |

## Classification rules

- **Worst-hit-wins.** A PR is L4 if it touches L4 code, even if the rest is skim-level. One L5 file makes it L5.
- **L1 vs L3:** data corrections to existing entries = L1; new data batches = L3 (surface grows, collisions multiply).
- **L2 vs L4:** a "refactor" that rewrites the same strings is L2; a refactor that changes a state shape, reducer actions, or serialized data is L4.
- **Grade features by footprint, not by being a feature.** A simple feature (small diff, one subsystem, covering tests, no state-machine or persistence impact) is L3. A feature that touches core state, serialized data, or several subsystems is L4. "It's a feature" alone never sets the level — the review effort it demands does.
- **Trust but verify.** PR descriptions claim "behavior-identical" or "all tests pass" — verify: check the diff files, confirm tests actually cover the changed paths. A claim without test evidence means the PR can't lean on test-backed safety — assess it at the level the unverified diff demands, not the level the claim suggests.
- **Test coverage moves level only through effort.** Good tests on an L4 PR make it a *reviewable* L4, not an L2 — but a small feature whose logic is fully pinned by tests genuinely demands less review effort and can sit at L3.
- **Mitigations go in the report**: no persistence (no migration risk), rng seams, test names covering invariants, user-approved visual deltas.
- **Grade the change, not the diff size.** "It's only four lines" is not an argument for a lower level.

