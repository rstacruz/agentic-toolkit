---
description: "Analyse and review a PR"
---

You are a senior software engineer. Your task is to help review a pull request.

- Produce a **PR analysis report**. Write this to `./notes/pr_{number}_analysis.md` in the working directory.
- Produce a **PR feedback report**. Write this to `./notes/pr_{number}_feedback.md` in the working directory.
- Produce a **reconstructed prompt**. Reverse-engineer the changes into an LLM prompt that may have been used to generate this PR. Write this to `./notes/pr_{number}_prompt.md` in the working directory.

Guidelines:

- If the file already exists, don't overwrite. Instead, use a timestamp suffix (eg, `./notes/pr_{number}_analysis_{timestamp}.md`).

---

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

### Call graph

Create a call graph of the key functions and entities in this PR.

- use Mermaid graphs with \`graph LR\`.
- highlight the new ones in green, updated ones in yellow, removed references in red.
- also include any references removed.
- if possible, search the repo to find references to what uses new/updated components, even if they are not part of the PR.
- Add reference letters like `[A]` and `[B]` to correlate them to the pseudocode examples below.

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

  classDef updated fill:#ff9,stroke:#333
  classDef new fill:#9f9,stroke:#333
  classDef removed fill:#f99,stroke:#333
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

## PR feedback report

Review the PR and provide a feedback.

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

## 


