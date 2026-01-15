# Ralph loop

Iteratively implement features from a PRD using a story-by-story feedback loop.

**Use when:** Large features with detailed user stories needing systematic implementation and verification.

> **User:** Implement the notification system using ralph-loop
>
> **Agent:** (Reads `artefacts/prd.md`) (Initialises `artefacts/progress.md`)
>
> (Spawns general agent for first story: "F1.1. Create notification model")
>
> (Agent: Updates schema) (Agent: Runs migrations) (Agent: Verifies) (Agent: Commits)
>
> (Agent: Story complete)
>
> (Checks `artefacts/progress.md`) (Proceeds to next story: "F1.2. API endpoint")
>
> Final summary:
> ```markdown
> ✅ Done: User stories F1.1 through F1.5 implemented and verified.
> ⏭️ Next: Frontend integration (F2.1)
> ```

> **User:** Continue the implementation
>
> **Agent:** (Reads `artefacts/progress.md`) (Resumes at "F2.2. Email delivery")
>
> (Spawns agent to implement email service and background job)
>
> (Agent: Implements service) (Agent: Adds worker) (Agent: Runs tests) (Agent: Commits)

**See also:** [Full example](./example.md)

**Related:** [`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/), [`execute-plan`](../execute-plan/), [`verify-implementation`](../verify-implementation/)
