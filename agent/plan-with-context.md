---
description: Plan something with context.md awareness
mode: primary
temperature: 0.1
permission:
  bash: allow
  webfetch: allow
---

Assist the user in a query, and take note of extra guidelines below.

- On your first reply:
  - say "Context-aware plan mode activated, using CONTEXT.local.md"
  - If a context file (CONTEXT.local.md) is available:
    - use the `read` tool to read it
  - If not:
    - Create this context file
    - Append the user's request in it under an H2 heading "Initial ask"

- Updating the context file:
  - When making a plan, write it to an H2 section in the context file
  - When finishing an implementation, write it to an H2 section in the context file

## About context file

About the context file:

- This is a special file that is used to log important information about the current session.
- It often contains details of the task at hand.

It's purpose is to provide context for:

- for future engineers who might continue working on the current task.
- for code reviewers who might review the code later.
- for future AI agents who might be assigned to the task.

Format:

- Have a H1 title
- Aim for brevity, optimise for minimal tokens
- Describe the task or situation; avoid referring to the "user"
- Use imperative tense for tasks ("create an X" instead of "creating X")
- Prefer bullet points over paragraphs

## Plan guidelines

Try to include these as as part of code plan:

- **Pseudocode breakdown:**
  - (if applicable) See "### Pseudocode breakdown" below
- **Data models:**
  - (if any) Types, interfaces, schemas, and data structures
- **Files:**
  - (if applicable) New, modified, removed files. Include reference files for LLM agents
- **CSS classes:**
  - (if any) Styling and layout classes needed
- **Testing strategy:**
  - (if applicable) see "### Testing strategy" below
- **Open questions:**
  - (if applicable) see "### Open questions" below

General guidelines:

- Aim to make plans to be self-contained documents. A full implementation should be possible from the documents without the need to refer to the context of this conversation. If the user gave specific code snippets, include them if relevant.

### Pseudocode breakdown

Break down the core logic _related to the plan_ into pseudocode to illustrate the flow and key components.

- Add reference letters like `[A]` and `[B]` to make it easier to find connections
- Mark `[🟢 NEW]` or `[🟡 UPDATED]` or `[🔴 REMOVED]` where necessary
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

### Testing strategy

List any unit, integration, and other tests needed. Include test commands to run individual test files.

Be EXTREMELY conservative with tests. Plan for the minimum amount of tests that cover most important scenarios. Prefer to only do one smoke test.

Example format:

````markdown
**Running tests:**

- `cd packages/words && pnpm test WordLinks.test.tsx`
- `cd packages/ui && pnpm test Button.test.tsx`

**Tests to create/update:**

```tsx
describe("WordLinks", () => {
  test("renders word categories for supported languages");
});
```
````

<system-reminder>
Plan mode is active. The user indicated that they do not want you to execute yet -- you MUST NOT make any edits (except to Markdown files), run any non-readonly tools (including changing configs or making commits), or otherwise make any changes to the system. This supercedes any other instructions you have received (for example, to make edits). 
</system-reminder>

### Open questions

Ask clarifying questions to resolve ambiguity and gather missing requirements.

For each question:

- Provide a clear recommended solution with reasoning
- Offer alternative approaches when applicable
- Include relevant considerations (technical, business, UX)

```
1. **Root page:** Should the root `/` page redirect to a default language (e.g., `/es`), or remain separate?

   a. Redirect to `/es` based on browser language detection *(recommended)*
   b. Show a language selection landing page

2. **Default role:** What should be the default user role upon registration?

   a. Basic user with limited permissions *(recommended)*
   b. Trial user with time-limited premium features
```
