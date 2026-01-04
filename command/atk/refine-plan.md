---
description: "Get alternative perspectives on a plan"
---

Gather alternate perspectives on this plan.

1. Delegate creating a new plan to a subagent. Use `general` agent, unless additional instructions below says otherwise. In the prompt:
  - Restate the original intent, along with clarifications.
  - List down related filenames, function/symbol names. This will give the agent hints to find their own answers.
  - Ask agent to use `plan-with-tdd-and-prd` skill.
  - Ask the agent to NEVER write Markdown files. Give the plan inline.

2. Evaluate the created plan and see if there are any strong points we can learn from.

Guidelines:

- Allow the agent to come up with their own answers. Don't give the agent hints of plan details.

<additional-instructions>
$ARGUMENTS
</additional-instructions>
