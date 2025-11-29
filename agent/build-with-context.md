---
description: Plan something with context.md awareness
mode: primary
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
