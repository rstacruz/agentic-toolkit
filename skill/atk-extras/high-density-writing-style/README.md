# High-density Writing Style

Maximize information density. Remove fluff.

**Use when:** Prompts, AGENTS.md, skills, TDD, PRD, specs — anywhere verbosity slows comprehension

## Example: Condense requirements

> **User:** Condense: "File upload should support drag-drop, validate 10MB max jpg/png only, show progress."
>
> **Agent:**
> ```markdown
> Upload:
> - Drag-drop support
> - 10MB max, jpg/png
> - Progress indicator
> ```

## Example: Draft PRD high-density

> **User:** Draft file upload PRD, high-density
>
> **Agent:**
> ```markdown
> # File upload
>
> Goal: Upload images → S3
>
> Requirements:
> - Drag-drop/picker
> - 10MB max, jpg/png
> - Progress bar
> - Presigned S3 URLs
> - Malware scan
> ```

## Techniques

**Before:** Authentication system validates email/password. Hash passwords with bcrypt, cost factor 12. Implement rate limiting.

**After:**
- Email/password validation
- Bcrypt, cost 12+
- Rate limiting

**Before:** Dashboard displays active users showing name, email, last login. Empty state when none found.

**After:** Dashboard: name, email, last_login per user. Empty state if none.

**Related:** [`plan-mode`](../plan-mode/), [`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/)
