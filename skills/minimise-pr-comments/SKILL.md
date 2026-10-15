---
name: minimise-pr-comments
description: Hide (minimize) noisy PR comments/reviews while keeping signal — human feedback, deploy notifications, manual-verification notes, and only the latest Copilot review pass. Use when the user asks to clean up, declutter, or minimise/collapse comments on a GitHub PR.
---

# Minimise PR comments

Hides low-signal PR comments via GitHub's `minimizeComment` mutation. Reversible
(`unminimizeComment`). Show the classification table, then apply — no
confirmation needed.

## Default rule

**Minimize everything except:**

1. A non-bot comment/review from someone who isn't the PR author (real reviewer feedback)
2. A bot comment about a deployment/preview notification (Vercel, Netlify, etc. — Pulumi previews are minimized, see `keepbots` in the script)
3. A PR-author comment/review about manual verification (testing steps, screenshots, "verified in nonprod", etc.), or explainer, or review guide
4. **Only the single most recent Copilot review** (its overview text, plus any inline comments attached to that same review) — regardless of what it says

Everything else — bot admin noise (ticket-tracker linkback, CI gate pings), every *earlier* Copilot review pass and its inline findings (superseded once a newer Copilot review exists), and the PR author's own replies/self-reviews (unless about manual verification) — gets minimized.

Already-minimized items: leave alone, don't touch.

For rule 4: group Copilot's reviews by submission time, keep only the last one (and its child comments) unminimized, minimize all earlier ones — same "latest supersedes" pattern deploy bots already apply to their own preview comments.

## Steps

1. **Run the script** — it fetches, classifies, and prints the table in one shot. `owner`/`repo`/`pr-number` are optional; omitted ones default to the current repo/PR (via `gh`):

   ```sh
   scripts/minimise.sh [owner] [repo] [pr-number]
   ```

   Review the printed table. Then apply:

   ```sh
   scripts/minimise.sh [owner] [repo] [pr-number] --apply
   ```

The script encodes the default rule deterministically (structural checks for reviewer/author/Copilot-recency, a login allowlist for deploy/preview bots) — no body-reading judgement needed except one narrow regex for PR-author manual-verification keywords. If a PR surfaces a bot or phrasing the script misclassifies, fix the regex/allowlist in `scripts/minimise.sh` rather than falling back to manual mutation calls.

## Example classification

For a PR with author `<pr-author>` and a handful of Copilot review passes over time:

| Author | Type | What it is | Verdict |
|---|---|---|---|
| deploy bot | Bot | "Preview deployed" / build link | **keep** — deploy notification |
| pulumi[bot] | Bot | stack preview ("Update (preview) ... was successful", resource diff) | minimize — admin noise, not in `keepbots`; repeats every push |
| `<reviewer>` | User (not author) | inline review feedback | **keep** — real reviewer feedback |
| Copilot | Bot | most recent review pass (any content) | **keep** — only the latest Copilot review survives |
| ticket-tracker bot | Bot | issue/ticket linkback | minimize — admin noise |
| CI bot | Bot | "re-run this if the gate is stuck" tip | minimize — admin noise |
| Copilot | Bot | earlier review pass + its inline findings | minimize — superseded by the later Copilot review |
| `<pr-author>` | User (PR author) | self-review / reply to a Copilot finding | minimize — author, not manual verification |
| `<pr-author>` | User (PR author) | "tested this in nonprod, screenshots attached" | **keep** — manual verification
