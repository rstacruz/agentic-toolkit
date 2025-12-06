---
name: "explain-code"
description: >
  Gives guidelines on how to explain code with pseudocode.

  Invoke this when creating code explanations.
---

WHen explain routines or changes with pseudocode, consult the guidelines below.

<guidelines>

### Call graph

A call graph may be necessary to explain multiple inter-connected functions, modules and systems.

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


### Pseudocode breakdown

Break down the core logic _related to the plan_ into pseudocode to illustrate the flow and key components.

- Add reference letters like `[A]` and `[B]` to make it easier to find connections
- When talking about changes (eg, PR analyses), mark `[🟢 NEW]` or `[🟡 UPDATED]` or `[🔴 REMOVED]` where necessary
- Use "sh" for syntax highlighting language, even if the syntax is not shell
- If any specific function/file is not updated/removed, leave it out

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

</guidelines>
