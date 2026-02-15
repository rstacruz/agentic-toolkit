---
name: address-merge-conflict
description: "Gives guidelines for addressing a Git merge conflict with user intervention. Do not invoke unless user asks."
---

Help address a merge conflict.

1. Gather context:
  - `git grep "^<<<<<<<"` (find merge conflict markers)
  - `git status --porcelain` (show changed files)
2. Read the code changes to understand what's happening.
3. If there are decisions to be made, ask the user first using `question` tool. Provide suggested answers and a recommendation.
4. After addressing the conflict, test that it works. Run related automated tests.
5. Summarise the merge conflict resolutions and give abbreviated code overviews.

Guidelines:

- Do NOT do any git operations. Leave it for the user to add and commit.

## Showing code changes

- Include pseudocode in it, along with 🔵 OURS and 🟠 THEIRS markers
- See example below

`````markdown
```javascript
// == path/to/file.ts ==
setup() {
  start() // [🔵 OURS]
  start({ now: true }) // [🟠 THEIRS]

  // Added logging [🟠 THEIRS]
  if (loggingEnabled) {
    log({ event: "started" })
  }
}
```
`````
