---
name: analyse-pr
description: Analyse a pull request
---

You are a senior software engineer. Produce a **PR analysis report** for this pull request. The goal is to help human reviewers understand the pull request.

## Additional context

Consider getting context via:

- `date +"%Y-%m%d-%H%M-%S"`
- `gh pr view --json number --jq '.number'`
- `gh pr diff --name-only`
 `gh pr diff`
- `gh pr view --json title,body,author,number,state`

## General guidelines

- Omit details that may be obvious to an experienced engineer (eg, "updates tests", "best practices" etc)
- Aim for brevity. Aim for 300 words max.

## PR analysis report

- Call graph (h2):
  - See "### Call graph" below
- Pseudocode breakdown (h2):
  - Break down the core logic into pseudocode to illustrate the flow and key components.
  - Highlight what is _new_, _changed_ or _removed_.
- Background (h2):
  - Brief bullet points explaining the situation and the this solves
- Changes (h2):
  - List key files/components modified. Highlight any breaking changes. Note any new tdependencies or configuration.
- Secondary changes (h2):
  - OPTIONAL: List changes that may not be directly related to the main problem
- Data models (h2):
  - Find out what data models are used in this PR. List down if they are _new_, _changed_, or _removed_.
- Dependency updates (h2):
  - See "### Dependency updates" below
- Feedback points (h2)
- Alternatives to consider (h2):
  - Deduce the purpose of the pull request, and assess if there are alternative solutions to consider.
- Test breakdown (h2):
  - Show an annotated version of the tests added or changed. Add comments to what each logical block of code does. Simplify for brevity. The aim is to help human reviewers skim the tests.

### Call graph

Create a call graph of the key functions and entities in this PR.

- use Mermaid graphs with \`graph LR\`.
- highlight the new ones in green, updated ones in yellow, removed references in red.
- also include any references removed.
- if possible, search the repo to find references to what uses new/updated components, even if they are not part of the PR.
- Add reference letters like `[A]` and `[B]` to correlate them to the pseudocode examples below.
- Trace them all the way back to the entry points (eg, API route, GraphQL query/mutation, event handler, and so on).

Example format:

```
## Call graph

\`\`\`mermaid
graph LR
  subgraph "file.ts"
    A["item1"]
    B["[A] item2"]:::new
  end
  subgraph "file2.ts"
    C["item3"]:::updated
    D["item4"]
  end
  A -->|"uses"| B
  B -->|"configured with"| C
  B -->|"renders via"| D

  classDef updated fill:#ff9,stroke:#333,color:#333
  classDef new fill:#9f9,stroke:#333,color:#333
  classDef removed fill:#f99,stroke:#333,color:#333
\`\`\`
```

### Pseudocode

- Add reference letters like `[A]` and `[B]` to make it easier to find connections
- Mark `[🟢 NEW]` or `[🟡 UPDATED]` or `[🔴 REMOVED]` where necessary
- Use "sh" for syntax highlighting language, even if the syntax is not shell

Example format:

````
**publishBlogPost:** publishes a blog post

```sh
# == blog/publish.ts ==

publishBlogPost(post) # [🟢 NEW]
  → validatePostContent(post) # [🟢 NEW: checks for required fields]
  → saveDraftToDB(post) # [🟡 UPDATED: now supports tags]
  → generateSlug(post.title) # [🟢 NEW]
  → scheduleForPublication(post, date) # [🟢 NEW: supports future dates]
  → notifySubscribers(post) # [🟢 NEW]
```

`[A]` **saveDraftToDB:** saves or updates a blog post draft

```sh
# == blog/db.ts ==

saveDraftToDB(post)
  if post.id exists:
    → update existing draft
  else:
    → create new draft
  → update tags # [🟡 UPDATED: now supports multiple tags]
```
````

### Dependency updates

If there are dependency updates:

- Assess its impact. Check if there are any breaking changes.
- Summarise why the dependency is needed. Use `grep` and `bun why`
- Consult the web for change logs.
- Assess code paths where that dependency is used.

Example format:

```
## Dependency updates

- `@sendgrid/mail` (7.2.1 → 8.0.0)
  - ⚠️ Breaking change: send() method now returns promise with different structure
  - Impact: Used in notifySubscribers() - verify error handling matches new API
  - Changelog: https://github.com/sendgrid/sendgrid-nodejs/releases/tag/v8.0.0
```

### Feedback points

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

Example format:

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

</analysis-and-feedback-guidelines>
