---
description: "Analyse and review a PR"
---

Use the *analyse-and-review-pr* skill. Analyse and review the current pull request.

$ARGUMENTS

## Additional context

`````
<context command='date +"%Y-%m%d-%H%M-%S"' description="Timestamp for filename">
!`date +"%Y-%m%d-%H%M-%S"`
</context>

<context command="gh pr view --json number --jq '.number'">
!`gh pr view --json number --jq '.number'`
</context>

<context command="gh pr diff" description="Current PR changes">
!`gh pr diff`
</context>

<context command=" gh pr view --json title,body,author,number,state" description="Get PR details and context">
!`gh pr view --json title,body,author,number,state`
</context>
`````
