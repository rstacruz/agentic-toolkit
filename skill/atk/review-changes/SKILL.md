---
name: review-changes
description: Use when reviewing code changes against a plan — returns P1/P2/P3 recommendations on alignment, quality, bugs, and security
---

**When invoking, provide:**
- Plan/spec document (PRD, TDD, or spec file)
- Changed files and locations, or git range (e.g. `branch...HEAD`, `git diff --cached`)

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
