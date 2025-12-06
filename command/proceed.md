---
description: "Proceed and build from plan"
agent: "build+"
---

Proceed and build from plan.

$ARGUMENTS

After the implementation:

- do *post-verification steps*
- If verifications steps fail, rectify them, then continue
- *update the log*
- spawn a `general` subagent to perform a *change review*.

## Post-verification steps

- Identify with steps to verify the work done.
- Come up with automated verification steps (eg, running unit tests) and manual verficiation steps (eg, run commands and examine output, use devtools for browser work if needed).
- When working with the browser:
  - Use the devtools tool.
  - Take screenshots at key points and save to `artefacts/`.
- Perform these steps.

## Updating the log

Update or create `artefacts/changelog.md`. In there, put:

- **Background:** context required to understand the work. This is often a problem statement.
- **Scope:** Summary of work done.
- **Automated verification:** Steps taken to verify. Show as a short list, minimise verbosity.
- **Manual verification:** Steps taken to verify, along with relevant outputs.

General guidelines:

- Avoid running the full test suite; instead, run relevant test files in isolation.
- The purpose is to communicate to another engineer that the work has been done sufficiently.
- Aim for brevity. Minimise tokens; broken grammar OK.
- For manual verification steps and code snippets, aim to have them be self-contained that include set up from a clean git clone of this repo. That is, give information on any CLI commands needed, database entries to manually add, UI steps to take, and so on.

## Change review

Ask a `general` subagent to review the task. Give the subagent:

- These `change-review-guidelines` below
- A short summary of the changes done
- A short list of files and locations changed
- A command to view the changes done (eg, `git diff --no-ext-diff`)

<change-review-guidelines>

- Add feedback points (see below for format).
- Add dependency update notes (if needed).

Look at the changes and provide thoughtful feedback on:

- Code quality and best practices
- Potential bugs or issues
- Suggestions for improvements
- Overall architecture and design decisions
- Security: vulnerabilities and concerns
- Documentation consistency: Verify that README.md and other documentation files are updated to reflect any code changes (especially new inputs, features, or configuration options)

For each feedback point, give it a priority:

- P1 - Must address before merging
- P2 - Somewhere in between
- P3 - Nitpicks

General notes:

- Aim for brevity
- Avoid too many positive points ("Readme is updated, examples are clear, no security issues"). There should only be one sentence of positive points max. This helps us concentrate on actionable feedback.

Be constructive and specific in your feedback. Give inline comments where applicable.

### Feedback points format

````
## Feedback points

### [P2] Extract magic numbers

- See: `blog/publish.ts:89`
- Consider defining constants for numbers for clarity.

 ```typescript
 // Current:
 if (post.content.length < 100) { ... }

 // Suggest:
 const MIN_POST_LENGTH = 100;
 if (post.content.length < MIN_POST_LENGTH) { ... }
 ```


### [P3] Type safety concern

- See: `blog/types.ts:12`
- `post.scheduledDate` is optional but `scheduleForPublication()` doesn't validate it
- Could result in runtime errors - add validation or make type non-nullable

````

</change-review-guidelines>
