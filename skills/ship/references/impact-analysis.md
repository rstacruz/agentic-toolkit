# Impact analysis

Measure how many real production records a change affects. Read-only.

## When relevant

Run only if **both** hold:

1. The change alters behavior applied to existing records (validation, matching, scoring, gating, flag rollout, query or migration on a hot table, a bug with a claimed prevalence).
2. Production data can measure it (BigQuery, Firestore, Datadog) over the last 30 days.

Otherwise skip silently. Not relevant: docs, tests, tooling, refactors, copy, dependency bumps, brand-new behavior with no history, unreachable data. If unsure, run one cheap feasibility query.

## Method

- State the affected population in plain words, matching the code's actual condition rather than the ticket's paraphrase.
- Give exact window dates and the total records in that window.
- Split into **positive**, **negative** (regressions, false positives, overwritten values, extra cost or latency), and **touched, no change**.
- Measure when stored data can answer it. Otherwise replay a sample and extrapolate, labelled as an estimate with sample size.
- Put as much effort into the negative side as the positive; report zero with how you know.
- Hand-check a few real records.
- Cite examples: at least one record ID per bucket (positive, negative), with a one-line before/after, and flag records you could not verify. Use IDs and generic descriptions only (no names or other PII).

## Sources

Use whatever read-only data access the project already has:

- BigQuery for counts and segments.
- Firestore (or the application's database) for spot checks.
- Datadog for event rates and latency (use a subagent for logs).

Rules: SELECT only; `--dry_run` large scans; exclude test/internal workspaces; no PII in write-ups (IDs and aggregates only).

## Output

One comment on the PR and on the linked ticket (edit if it exists), headline first:

~~~ markdown
### Impact analysis: <title>

**N of M records (X%) in the last 30 days are affected: A improve, B regress.**

| | Records | % |
| -- | --: | --: |
| Total (<dates>) | M | 100% |
| Positive | A | |
| Negative | B | |
| Touched, no change | C | |

**Positive:** <what improves, with 1-3 examples: `<record ID>` before → after>

**Negative / risks:** <what regresses, count or estimate, with 1-3 examples: `<record ID>` before → after; say which examples are unverified>

**Method:** predicate, source, exclusions, measured vs estimated (sample size), limits.

<details><summary>Queries</summary>

```sql
...
```

</details>
~~~
