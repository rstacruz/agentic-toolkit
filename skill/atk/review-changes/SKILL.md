---
name: review-changes
description: > Reviews code changes. When using this skill, provide: plan document (eg, PRD, TDD); changed file and locations; git range (if available, eg, "branch...HEAD"). Return recommendations (P1 critical, P2, P3).
---

Review changes and provide feedback on:

- **Plan alignment:** Verify changes implement planned requirements. Flag any deviations from the plan as P1.
- Code quality and best practices
- Potential bugs or issues
- Suggestions for improvements
- Architecture and design decisions
- Security vulnerabilities and concerns
- Documentation consistency (README, etc.)

Feedback priority:
- P1: Must address before merging (includes plan deviations, bugs, security issues)
- P2: Should address
- P3: Nitpicks

Format:
```
### [P2] Issue title
- See: file.ts:89
- Description and suggested fix with code example
```

Be constructive, specific, and brief. Focus on actionable feedback, not praise.
