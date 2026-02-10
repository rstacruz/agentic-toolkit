# Analyse and Review PR

Produce PR analysis reports and feedback for code reviews.

**Use when:** Post-PR review, understanding complex changes, onboarding to unfamiliar PRs

## Example: Full analysis with feedback

> **User:** Analyse PR #123
>
> **Agent:** (Fetches PR metadata, diff, files) (Generates call graph) (Writes pseudocode) (Checks dependency updates)
>
> ```markdown
> ## Call graph
>
> graph LR
>   subgraph "notify.ts"
>     A["[A] sendEmail"]:::updated
>   end
>   subgraph "publish.ts"
>     B["publishPost"]:::new
>   end
>   B -->|"triggers"| A
>
> ## Dependency updates
>
> - `@sendgrid/mail` (7.2.1 → 8.0.0)
>   - ⚠️ Breaking: send() returns different promise structure
>   - Impact: Used in sendEmail() - verify error handling
>   - Changelog: github.com/sendgrid/sendgrid-nodejs/releases/tag/v8.0.0
>
> ## Feedback points
>
> ### [P1] Validate optional field
>
> - See: publish.ts:45
> - `scheduledDate` optional but no validation before use
> - Add check or make non-nullable
> ```
>
> (Saves to `artefacts/pr_123_analysis.md` and `pr_123_feedback.md`)

## Example: Quick feedback only

> **User:** Review PR #456
>
> **Agent:** (Skips analysis) (Produces feedback only)
>
> ```markdown
> ## Feedback points
>
> ### [P2] Extract magic numbers
>
> - See: validator.ts:89
> - Define MIN_POST_LENGTH constant
>
> ### [P3] Type safety
>
> - post.tags typed as `any[]` - use `string[]`
> ```
>
> (Saves to `artefacts/pr_456_feedback.md`)

## Example: Inline output

> **User:** Analyse PR #789 inline
>
> **Agent:** (Performs full analysis + feedback) (Outputs directly in response, no files)

## Output options

- **Full analysis:** Call graph, pseudocode, background, changes, data models, dependency updates, feedback (saved to `artefacts/`)
- **Feedback only:** Priority-ranked feedback (P1/P2/P3) saved to `artefacts/`
- **Inline:** Output in response, no files

**Related:** [`explain-code`](../explain-code/)
