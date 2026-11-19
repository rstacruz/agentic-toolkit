DRY RUN. GitHub and git are unavailable. The PR is frozen in pr.json
(plus diff.patch and source files, if present); treat it as the live PR. Do
not run commands, and do not create or modify any file outside outputs/.
Instead of performing any write action, record it in outputs/plan.json, in
the order you would do it. Read plan.schema.json first: plan.json must
validate against it, using only its action types and bucket values, with
`triage` present even when empty.

The snapshot never changes, so plan one pass. End with a `wait` action if you
would wait for new activity, or `stop` (with a reason) if you would stop.
