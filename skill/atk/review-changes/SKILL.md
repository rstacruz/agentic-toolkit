---
name: review-changes
description: "Use when reviewing code changes against a plan. Provide: plan/spec doc; git range or changed files (eg, branch...HEAD). Returns P1/P2/P3 on alignment, quality, bugs, security."
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
