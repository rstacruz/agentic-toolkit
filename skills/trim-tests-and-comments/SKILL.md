---
name: trim-tests-and-comments
description: Delete comments by default and cut weak tests in this branch; report first, then apply on approval.
---

Comments are deleted by default. A comment survives only by matching the keep list below. When unsure a keep applies, it dies.

- **Gather context:**
  - Get a list of tests added
  - Get a list of comments added
  - Unless specified, gather them from this branch/PR

- **Assess tests:**
  - Which tests are load bearing?
  - Which test the contract, and which test the implementation?
  - Are there redundant tests (eg, multiple tests per failure mode)?
  - Could test code be simplified?

- **Assess comments:**
  - Applies equally to `//`, `/* */`, and JSDoc `/** */`. A docstring isn't exempt for being "documentation".
  - List every comment block (line range + word count) before judging. Don't spot-check.
  - Hunt targets: narration, banners, commented-out code, workaround sermons, diff-relative notes.
  - Judge each block against the keep list. No match, or doubt, means delete.
  - Check suppressions (`eslint-disable`, `@ts-ignore`, `@ts-expect-error`, and similar) against the rule they silence.
  - Check scent comments (`IMPORTANT`, `do not remove`, `too risky`, `fine for now`, long justifications). Read nearby code first. If the claim isn't obvious there, check the named symbol (its definition and callers). Only a foreign gotcha proven true today on a live path survives.

- **Report first:**
  - Name touched files, deletion count, `MUST KILL` flags (one line each), and skips.
  - Every flag names code inside the scope and tells the truth. Invent nothing.
  - Wait for approval before editing.

- **Go:**
  - Delete the comments and cut or consolidate the tests.
  - Never write application code. Refactors stay `MUST KILL` flags for the user.

## Keep list

Only these survive.

- **License or legal headers.**
- **Foreign gotchas:** non-obvious behavior forced by an external dependency, platform, vendor, or protocol we cannot reshape. Must be proven true today on a live path (see Examples).
- **Lint and format directives:** `// prettier-ignore`, and a lint suppression only when its rule is faulty, pedantic, or style-only.
- **Public API doc contracts:** doc comments defining a contract consumers rely on.
- **One-line JSDoc:** a `/** ... */` on a single line stays if it is accurate and short (see Style for survivors). Multi-line JSDoc dies unless it is a public API contract. A one-liner that lies dies.
- **Issue, RFC, ADR, or ticket links** that explain a constraint code cannot express. A bare ticket ID stays only when it is the sole source of context (a magic value, blocklist entry, or timestamp whose reason lives only in the ticket). Cut IDs whose comment already states the reusable context (see Examples).
- **Concrete evidence for a foreign constraint:** a cited upstream doc section, a measured number, or a version pin. Keep the number and date it. Cut the argument built around it.
- **Hedges about undocumented foreign behavior:** keep them as hedges. Never upgrade a guess into a false certainty while shortening (see Examples).
- **Deliberate omissions:** a recorded choice, not an oversight (see Examples).

## Surprises in our own code

A comment explaining a surprise in code we own (a workaround, an invariant, a cross-file contract, why a value is hardcoded) is meat, not a keep.

- Delete the comment.
- Flag the exact symbol `MUST KILL` for the rename, extract, type, or rearchitecture that makes the behavior obvious without prose.
- A long justification with no proven keep is a confession. Delete it and flag the symbol. Never polish it into a shorter alibi.
- A suppression that silences a rule protecting correctness or safety: delete it and flag the symbol.

## Style for survivors

Applies only to comments that passed the keep list.

- Limit blocks to 10 words, unless the keep entry needs more (a license header, a public contract). Judge the block as a whole.
- One-line JSDoc says what the symbol is or does, in 10 words or fewer. Cut the how, the history, the rationale, and edge-case tails (see Examples).
- Avoid duplication within the block or elsewhere in the file. Keep the durable fact, cut operational detail (queue names, retry counts, worker IDs).
- Put each note next to the line it explains, not in a summary block above (see Examples).
- State the fact, not the instruction. Cut "don't change this without re-measuring", keep the measurement (see Examples).
- Prefer one concrete example over prose (see Examples).
- Date empirical claims with a month or date.
- Avoid non-ascii characters like em dashes and emoji's.
- Comments shouldn't end with a `.`. Internal sentence periods stay (see Examples).
- Avoid diff-relative language ("now", "no longer", "previously", "used to"). Describe the current state, not the change (see Examples).
- Single-line separator labels only across several parallel blocks, short and consistent. Never a lone trivial line.

## Examples

**Restatement, cut it:**

```
// ✗ Cut: restates the type signature right below it
// Returns a string or null
function buildCacheKey(input): string | null { ... }

// ✗ Cut: restates an argument sitting two lines below
// Alerts are routed to #alerts-payments by the `team:payments` tag
createMonitor({ team: 'payments', ... })
```

Restatement includes what a linked doc already covers. If the comment carries the pointer, it need not also summarise the destination.

**Surprise in our own code, kill the comment and flag the symbol:**

```
// ✗ Cut, then flag `retries` MUST KILL: rename to `retriesAfterFirstAttempt`
// Counts retries, not attempts, so 3 means 4 calls in total
retries: 3,
```

**Foreign gotcha, keep (proven today):**

```
// ✓ Keep: the vendor API returns 200 with an error body on rate limits
if (body.error) throw new RateLimited(body.error)
```

**One-line JSDoc, keep if accurate:**

```
// ✓ Keep
/** Splits the registrable domain into labels */
function domainLabels(domain: string): string[] { ... }

// ✗ Cut: multi-line and not a public contract
/**
 * Splits the registrable domain into labels, taking care to handle
 * public suffixes via the PSL.
 */
```

**Shorten one-line JSDoc, say what, not how:**

```
// ✗ Narrates how and why
/** Whether this session can show the widget: a main session in the TUI. */
/** Nothing streaming or queued, so a recap painted now cannot be stale. */
/** A host that can run side turns; older hosts (and upstream pi) lack the entry point. */

// ✓ What it is
/** Main session in the TUI */
/** Idle with nothing queued */
/** Host that supports side turns */
```

**Example over description:**

```
// ✗ Weaker: describes instead of showing
/** Splits the registrable domain into labels */
function domainLabels(domain: string): string[] { ... }

// ✓ Keep
/** "shop.acme-motors.com.au" -> ["shop", "acme-motors"] */
function domainLabels(domain: string): string[] { ... }
```

**Collocate rather than summarise:**

```
// ✗ Summary block: needs a label per item to disambiguate
// Limits come from 14 days of load data:
//   - Burst 200: p99 concurrent requests peaked at 140
//   - Timeout 70s: slowest healthy request took 55s
limits: {
  burst: 200,
  timeoutMs: 70_000,
}

// ✓ Collocated
limits: {
  // p99 concurrent requests peaked at 140
  burst: 200,
  // Slowest healthy request took 55s
  timeoutMs: 70_000,
}
```

**Fact over instruction, and date it:**

```
// ✗ The warning is implied by the number, and the number has no date
// Measured, not the library default. Do not restore the default without re-measuring
timeoutMs: 70_000,

// ✓ Dated fact; the reader draws the conclusion themselves
// Slowest healthy request took 55s, measured over 14 days to Aug 2026
timeoutMs: 70_000,
```

**Deliberate omission, keep it:**

```
// ✗ Over-trimmed: reads as an oversight, invites a "fix"
function mapGeocodeResult(data) { /* city/region/country never touched */ }

// ✓ Keep: the choice is recorded
// Note: city/region/country are not mapped; out of scope.
function mapGeocodeResult(data) { ... }
```

**Hedge turned into false certainty, don't do this:**

```
// ✗ Over-trimmed: states an upstream behavior as fact
// A 'match' field means the upstream API found an exact match.

// ✓ Keep: records that this is a guess about undocumented behavior
// Handle a 'match' field in response (possibly for exact match cases).
```

**Doc/ADR pointer, keep it when it explains a constraint code can't express:**

```
// ✓ Keep: points to a real doc explaining a design decision
// See ADR-004 for why retries and circuit-breaking are configured separately.
```

**Ticket ID, keep only if it's the sole source of context:**

```
// ✓ Keep: no clue here why this URL is bad, the investigation lives in the ticket
// PROJ-195
'https://assets.vendor-cdn.com/thumbnails/938/...',

// ✗ Cut: the comment already states the reusable context, ID adds nothing
// PROJ-309: fix for the thing the designer reported

// ✗ Untrimmed: comment is self-contained, ID is redundant
// PROJ-494: assets.vendor-cdn.com returns 403 on every thumbnail download
// since 2026-07-25 (vendor-confirmed CDN outage). Remove once the vendor confirms
// public read access is restored.

// ✓ Trimmed: ID dropped, prose kept
// Returns 403 on every thumbnail download since a July 2026 CDN
// outage. Remove once the vendor restores public read access.
```

**Diff-relative language, describe the state, not the change:**

```
// ✗ The client now retries on 429
// ✓ The client retries on 429
```

**Trailing period, cut it:**

```
// ✗ Publishes the metric.
// ✓ Publishes the metric

// ✗ Uses the cached value. Falls back to a live fetch if stale.
// ✓ Uses the cached value. Falls back to a live fetch if stale
```

**Single-line separators, reformat, don't leave numbered/verbose:**

```
// ✗ Verbose/numbered:
// 1. Phone (Primary Identifier)
if (payload.phone) { ... }
// 2. Email (Primary Identifier)
if (payload.email) { ... }

// ✓ Trimmed:
// Phone
if (payload.phone) { ... }
// Email
if (payload.email) { ... }
```
