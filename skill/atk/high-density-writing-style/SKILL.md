---
name: high-density-writing-style
description: Guidelines for a writing style that's concise and direct. Use for writing/editing prompts, artefact documents, TDD, PRD, discovery documents, research, AGENTS.md, and more.
---

# High-density writing style

- Optimize for conciseness, brevity, scannability
- Use lists, sentence fragments, broken grammar OK
- Remove unnecessary articles, verbose phrasing
- Direct, high-density language

## Example

````markdown
# User authentication system

**Goal:** Implement secure auth flow with session management

## Requirements

### F1: Login flow
- F1.1: Email/password validation — check format, non-empty
- F1.2: Rate limiting — max 5 attempts per 15min window

### F2: Security
- **Password hashing:** bcrypt with cost factor 12
- **HTTPS only:** reject non-secure connections
- **CSRF protection:** validate tokens on state-changing operations

## Technical approach

**Database schema:**
- `users` table: id, email, password_hash, created_at
- `sessions` table: token_hash, user_id, expires_at, last_active

**Flow:**
1. Client submits credentials
2. Server validates, checks rate limit
3. Generate JWT, create session record
````


