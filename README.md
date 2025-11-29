# Agentic toolkit

Some indispensable prompts and tools I use with [Opencode](https://opencode.ai/).

## Installation

- Install OpenCode
- Copy `agent/` files into `~/.config/opencode/agent/`
- Copy `command/` files into `~/.config/opencode/command/`

Not an OpenCode user? These are pretty tool-agnostic, it should work with Claude Code and Gemini CLI and other tools (with some edits).

## Use cases

### plan-with-context agent

Use this to plan your work instead of the usual `plan` mode.

```markdown

## User

(switch to plan-with-context mode)

plan this work:
- in the `workmux add` command, i want to add `--name <name>` to name the worktree 

because:
- branch names can be very long, they dont make very good worktree names

also research:
- are there places in the codebase that don't make a distinction between worktree name and branch name? because those need to change

## Assistant

I've researched the codebase and created a comprehensive implementation plan for adding --name <name> to the workmux add command.

## User

(switch to build-with-context mode)

proceed and implement
```

It has some differences from the regular plan mode:

- It will keep its plans in a file called `CONTEXT.local.md`. This is a form of intentional compaction
- It optimises the plan for scanability. It has pseudocode, list of files, etc

### build-with-context agent

Same as a regular `build` agent, but has instructions to read and write `CONTEXT.local.md` as it goes.

That means it can read the plan build with *plan-with-context*, and update it with progress, etc.

It helps keep the agent on track across long sessions with multiple session compactions.

### /continue-from-here

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
    return db.word.where({ word })
}
```

Inspired by [Aider's watch files mode](https://aider.chat/docs/usage/watch.html).
