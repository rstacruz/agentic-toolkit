# execute-plan

Execute a plan in a ticket-by-ticket loop using subagents.

## Usage

Start with a plan file (e.g. from `$spec-mode`):

```
use $execute-plan skill with @artefacts/plan-my-feature.md
```

## How it works

1. Reads the plan and picks the next unblocked ticket
2. Spawns `@general-alpha` agent loaded with `$execute-plan-subagent`
3. Verifies the commit references the ticket ID
4. Repeats until all tickets are done

**Related:** [`execute-plan-subagent`](../execute-plan-subagent/), [`refine-plan`](../refine-plan/)
