---
name: write-prd
description: >
  Gives guidelines on how to do a project plan for a project or epic.
  Gives guidelines on how to write Product Requirements Documents (PRD), Technical Design Document (TDD), and Discovery Document.
  Invoke this when the user asks to work on a PRD or a project plan.
---

# Project planner

Assist the user in planning a project.

Typical artefacts in project planning:

- **Discovery Document** (`discovery.md`) - additional context that would be helpful for project planning, such as: current system state, existing data structures, third party API notes
- **Product Requirements Document (PRD)** (`prd.md`)
- **Technical Design Document (TDD)** (`tdd.md`)
- **Tickets** (`tickets.md`) - Overview of Linear tickets

## PRD guidelines

A PRD typically has these sections. Some may be present or absent depending on the situation.

- Problem statement
- Solution overview
- Functional requirements
- Non-functional requirements
- Technical constraints
- Design considerations
- Open questions
- Out of scope 
  - A list of requirements for future consideration
  - Deferred requirements are placed here
- Roadmap 
   - A list of milestones with tasks in each
   - Optimise milestone and task order to prioritise getting a working version first.
   - Number milestones in the format of "M{number}"
- Additional context 
  - If the user requested additional information or research, place them here

A PRD is considered good if:

- A technical solution plan can be made from it
- Edge cases and error scenarios are addressed
- Engineers can estimate the work without asking too many questions

General guidelines:

- Give hierarchical ID's to sections (eg, `NF<number>` for non-functional requirements, `TC<number>` for constraints)

### Functional requirements

- Give ID's to requirements and sub-requirements
- Give additional context per requirement group if needed

Example:

```
### F2: Worktree creation across repos

**User story:** As a <user>, I want to <action> so that <rationale>

- **F2.1. Repo flag support:** System must support `--repo <name>` flag on `add` command
- **F2.2. Repository lookup:** System must look up repository by name in `repos.yaml`
- **F2.3. Remote worktree creation:** System must create worktree in the specified repository's location

#### <Additional context>

...

#### <Additional context>

...
```

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

## TDD guidelines

Consider if the TDD would need:

- **Pseudocode breakdown:**
  - (if applicable) See "### Pseudocode breakdown" below
- **Data models:**
  - (if any) Types, interfaces, schemas, and data structures
- **Files:**
  - (if applicable) New, modified, removed files. Include reference files for LLM agents
- **CSS classes:**
  - (if any) Styling and layout classes needed
- **Testing strategy:**
  - (if applicable, and if user asked for it) see "### Testing strategy" below

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

Do not include testing strategy unless user asks to add tests.

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

## Actions

You may be asked to do the following tasks.

### Evaluate a PRD

- Evaluate a given PRD document based on the *PRD guidelines*.
- Give some *Open questions*.
- Verify if there are any contradictions.
- Give it a grade of `S`, `A`, `B`, `C`

### Draft or write a PRD

- Write a PRD for the user.
- Ask clarifying questions to the user. See *Open questions* for guidelines.
- Write to `prd.md` unless otherwise specified.
- For *Roadmap* section, leave it as "*TBD - to be filled in later upon request*".

### Defer a task in a PRD

A user may ask for a task to be descoped or deferred.

- Move these tasks to a *Out of scope* section. Create it if it doesn't exist.

### Research a topic

When researching a topic, write findings to the Discovery Document (`discovery.md`).
