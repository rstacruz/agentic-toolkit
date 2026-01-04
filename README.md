# Agentic toolkit

Some indispensable prompts and tools I use with [Opencode](https://opencode.ai/).

## Installation

Consider this repo as a glimpse into what I do, *not* a pre-packaged system to install. I recommend perusing it and taking what you need.

1. Install [OpenCode](https://opencode.ai).
2. Set up artefacts directories:
  - Add to global gitignore: `echo artefacts >> ~/.config/git/global_ignore` (or wherever your global ignore is)
  - Exclude from global rgignore (for OpenCode): `echo '!artefacts' >> ~/.rgignore`
3. Pick-and-choose what you want to copy:
  - Copy `command/atk/` files into `~/.config/opencode/command/atk/`
  - Copy `skill/atk/` files into `~/.config/opencode/skill/atk/` (ensure you use OpenCode 1.0.190+)

Not an OpenCode user? These are pretty tool-agnostic, it should work with Claude Code and Gemini CLI and other tools (with some edits).

## Core tools

### Plan mode

> [`/plan` command](command/atk/plan.md) +
> [`plan-mode` skill](command/atk/plan-mode.md)

Use this to plan your work instead of the usual `plan` mode.

```markdown
## User

/plan add dark mode toggle to settings

## Assistant

**Plan mode engaged.**

[Researches codebase, creates todo list]

Before I draft the plan, I have a clarifying question:

1. **Theme detection:** Should the app detect system theme preference automatically?
   - a. Yes, respect system preference (recommended)
   - b. No, manual toggle only

## User

1a

## Assistant

Here's the implementation plan:

1. Add theme context provider with system detection
2. Create toggle component in settings page
3. Update CSS with theme variables
4. Persist preference to localStorage

Ready when you say **go**.

## User

go

## Assistant

**Plan mode disengaged.** [Begins implementation]
```

### Plan with TDD and PRD

> [`plan-with-tdd-and-prd` skill](skill/atk/plan-with-tdd-and-prd/SKILL.md)

Use this for complex features and technical research requiring structured planning before implementation.

Creates comprehensive planning documents:
- **Discovery documents** - environmental context and constraints
- **PRD** (Product Requirements Document) - product requirements with user flows
- **TDD** (Technical Design Document) - implementation plans with pseudocode

```markdown
## User

Write a PRD for a notification system

## Assistant

**Now writing a PRD.**

[Researches codebase, creates discovery document]

Before I draft the PRD, I have clarifying questions:

1. **Delivery channels:** Which notification channels should be supported?
   - a. In-app and email (recommended)
   - b. In-app only

## User

1a

## Assistant

[Writes `artefacts/prd-notifications.md` with requirements, user flows, screen interactions]

PRD complete. Would you like me to write the TDD?

## User

Yes, write the TDD

## Assistant

**Now writing a TDD.**

[Writes `artefacts/tdd-notifications.md` with pseudocode, data models, files, testing strategy]

TDD complete. Ready for implementation.
```

### Execute plan

> [`/proceed` command](command/atk/proceed.md) +
> [`execute-plan` skill](skill/atk/execute-plan/SKILL.md)

Use this to execute implementation plans from the planning phase to verified completion.

Orchestrates the full implementation workflow:
1. Execute the plan (tests first when applicable)
2. Run verification checks
3. Perform peer review with subagent
4. Generate changelog to `artefacts/changelog.md`

Use this after creating a plan with `/plan` or writing a TDD.

### Analyse PR

> [`/pr-analyse` command](command/atk/pr-analyse.md) +
> [`analyse-and-review-pr` skill](skill/atk/analyse-and-review-pr.md)

Analyse a PR. It creates 2 artefacts: a *PR analysis* which summarises a PR for a human to understand what's going on, and *PR feedback* for some comments.

Use for:

- Help you to review colleague PR's

```
gh pr checkout 1234
opencode run --command atk/pr-analyse
.
.
cat pr_analysis.md
cat pr_feedback.md
```

### Reflect

> [`/reflect` command](command/atk/reflect.md) +
> [`reflect` skill](skill/atk/reflect/SKILL.md)

Use this to improve the toolkit itself by distilling learnings from your sessions.

Examines the current session and provides suggestions to:
- Refine skill prompts to better fit your needs
- Update project guidelines (AGENTS.md) to prevent future issues
- Capture patterns and best practices

Run this after completing work to continuously improve your development workflow.

## Extras

### Address merge conflict

> [`/address-merge-conflict` command](command/atk/address-merge-conflict.md)

Use this after a nasty `git pull`. It'll assess the situation and give suggestions. You can ask the agent to resolve the conflict afterwards.

### Continue from here

> [`/continue-from-here` command](command/atk/continue-from-here.md)

One of my favourite ways to work! Forget prompting, just add comments.

- Add `// AI:` comments around your code.
- Run `/continue-from-here`.

```ts
// schema.prisma
model Word {
  id   String @id @default(uuid())
  word String
  // AI: add `language` column

  @@unique([lang, word])
  @@map("words")
}

// word.ts
function getWord(word: string /* AI: also query by `language` */ ) {
  // AI: use validateWord here
    return db.word.where({ word })
}

function validateWord(wordObject) {
  // AI: implement this. add typescript types to the params
}
```

Inspired by [Aider's watch files mode](https://aider.chat/docs/usage/watch.html).

