---
description: "Address a Git merge conflict"
---

Help address a merge conflict.
Read the code changes to understand what's happening.
If there are decisions to be made, ask the user first. Provide suggested answers and a recommendation.
Do NOT do any git operations. Leave it for the user to add and commit.

## Additional context

`````
<output command='git grep "^<<<<<<<"' description="Merge conflict markers">
!`git grep "^<<<<<<<"`
</output>

<output command="git status">
!`git status`
</output>
`````

