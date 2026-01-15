# Ralph loop

Iteratively implement features from a PRD using a story-by-story feedback loop.

See: <https://ghuntley.com/ralph/>

1. Create a PRD with user stories ([`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/) ca help)
2. Say `proceed with plan using *ralph-loop*`

Examples:

```
# simple:
proceed with @artefacts/prd-my-feature.md using *ralph-loop*

# advanced with preamble
proceed with @artefacts/prd-my-feature.md using *ralph-loop*, max 5 iterations

include preamble: use design-guidelines skill, use devtools on localhost:3000 on browser verification
```

**Related:** [`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/), [`verify-implementation`](../verify-implementation/)
