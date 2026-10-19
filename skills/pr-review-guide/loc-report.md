# LOC report

A breakdown of a pull request's added and removed lines by category, with per-file counts. It goes inside the `<details><summary>LOC report</summary>` shell of the PR review guide comment (see `SKILL.md`). It can also be posted on its own when asked for a "LOC breakdown".

## 1. Get the numbers from the PR

Use the PR's own diff stats. NEVER use `git diff main...HEAD`: a local branch can be ahead of a stale `main`, or carry merge commits that pull in unrelated changes.

```sh
gh pr view <number> --json additions,deletions
gh pr view <number> --json files -q '.files[] | "\(.additions)\t\(.deletions)\t\(.path)"'
```

The per-file sums MUST match the PR totals. If they don't, the wrong PR was used. Fix that first.

## 2. Group files into categories

Read the diff (not only the path) to see what each change is _for_. A file lands in exactly one category.

- **One category per distinct feature or concern.** Name it after what it does, not the ticket ID.
- **Docs**: documentation changes.
- **Tests**: all test files, even when they cover one feature. Mention that in a note if it helps.
- **Build, config, and small import/type edits** belong to the feature that needs them. No generic "config" category.
- **Deleted or moved code** goes with the feature that replaced it. Say so in a note.
- Don't pad the list. 2–6 categories is typical.

Category totals MUST add up to the PR totals (additions and deletions).

## 3. Format

Lead with the total and a summary table, then one collapsed `<details>` per category.

- Summary table: one row per category, largest additions first, right-aligned number columns, no prose in cells.
- `<summary>` is `<code>[+X/-X]</code>` followed by the category name.
- Inside each block: files as `` - `[+X/-X]` `path` ``, sorted by additions descending, pure deletions last.
- Category totals are the sum of their files.
- If most files share a path prefix, strip it and say so (`Paths are relative to ...`). Otherwise use full repo paths.
- Put a short note inside a category block when a file's placement isn't obvious.
- Leave a blank line after `<summary>` and before `</details>`, or GitHub won't render the markdown.
- In `<summary>`, only `<code>` is allowed as HTML. Backticks don't render there, so wrap identifiers in `<code>`.
- When embedded in the review guide, drop the `## LOC report` heading (the outer `<summary>` already provides it).

## 4. Post it

Standalone:

```sh
gh pr comment <number> --body-file /tmp/loc-comment.md
```

Use `--body-file`. For `gh api`, use `-F body=@file`, not `-f`.

Inside the review guide, include it in that comment as described in `SKILL.md`. Don't post a second comment.

## Example

````markdown
**Total: `+500 / -120`**

| Category | Added | Removed |
| --- | ---: | ---: |
| Parser rewrite | +300 | -90 |
| Tests | +150 | -20 |
| Docs | +50 | -10 |

<details>
<summary><code>[+300/-90]</code> Parser rewrite</summary>

Paths are relative to `src/parser/`.

- `[+210/-0]` `tokenizer.ts`
- `[+60/-30]` `index.ts`
- `[+30/-0]` `types.ts`
- `[+0/-60]` `legacy.ts`

`legacy.ts` is here because the rewrite replaces it.

</details>

<details>
<summary><code>[+150/-20]</code> Tests</summary>

- `[+120/-0]` `src/parser/__tests__/tokenizer.test.ts`
- `[+30/-0]` `src/parser/__tests__/index.test.ts`
- `[+0/-20]` `src/parser/__tests__/legacy.test.ts`

</details>

<details>
<summary><code>[+50/-10]</code> Docs</summary>

- `[+50/-10]` `docs/parser.md`

</details>
````

In a real report, list every file.
