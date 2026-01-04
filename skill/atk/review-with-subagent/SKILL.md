---
name: review-with-subagent
description: Instructions for reviewing changes using subagents. Use after implementation and verification are complete
---

# Review with Subagent

Spawn a `general` subagent to review changes against the plan and quality standards.

## Workflow

1. **Prepare review data:**
   - Plan document (TDD/PRD)
   - Change summary and file locations
   - `git diff --no-ext-diff` output

2. **Provide guidelines to subagent:**

```markdown
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
### [P2] Issue title
- See: file.ts:89
- Description and suggested fix with code example

Be constructive, specific, and brief. Focus on actionable feedback, not praise.
```

3. **Address feedback:**
   - Fix P1 issues immediately
   - Address P2/P3 as appropriate

