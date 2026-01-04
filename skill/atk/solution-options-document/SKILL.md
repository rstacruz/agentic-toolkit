---
name: solution-options-document
description: >
  Write solution options documents to evaluate and compare different technical approaches with trade-off analysis

  Common user requests:
  - "Evaluate options for [problem]"
  - "Compare [solution A] vs [solution B]"
  - "What are the trade-offs between [approach X] and [approach Y]?"
---

# Solution options document

Use this skill when the user asks to evaluate different solutions for a problem, compare technical approaches, or create an options analysis document.

## When to use

**Use this skill when:**

- **Technology/architecture selection:** Databases, frameworks, APIs, hosting platforms, authentication methods
- **Implementation strategy comparison:** Server-side vs client-side, polling vs webhooks, caching strategies
- **Pre-decision documentation:** Team needs to see trade-offs before committing to an approach
- **Technical RFCs or onboarding:** Recording why certain approaches were chosen over alternatives

**Common user requests:**
- "Evaluate options for [problem]"
- "Compare [solution A] vs [solution B]"
- "What are the trade-offs between [approach X] and [approach Y]?"
- "Help me decide between [option 1] and [option 2]"

**When NOT to use:**
- Decision is already made (use a standard technical document instead)
- Only one viable option exists
- User wants implementation details (use TDD instead)
- User wants requirements gathering (use PRD instead)

## Document structure

A solution options document breaks down a problem into independent problem spaces, then evaluates multiple solutions for each space.

### Key components

1. **Overview** - Brief context about the overall problem
2. **Problem spaces** - Independent sub-problems that can be solved separately
3. **Comparison tables** - Feature-by-feature comparison with emoji indicators
4. **Option details** - Detailed explanation of each option with code examples
5. **Recommended solution summary** - Final recommendations across all spaces

## Writing guidelines

### Problem space structure

Each problem space should include:

1. **Context statement** - One sentence explaining what needs to be decided
2. **Comparison table** - Feature comparison across all options
3. **Option details** - Detailed breakdown for each option

### Comparison tables

**Format:**
- Y-axis: Features to compare (pricing, complexity, performance, etc.)
- X-axis: Different options (1a, 1b, 1c, etc.)
- Cells: Start with emoji (🟢/🟠/🔴) followed by brief description
- Final row: **Recommendation** with one-sentence summary per option
  - Use bold emphasis markers for clarity: "**Best for most cases:**", "Use only if", "Avoid unless"

**Emoji usage:**
- 🟢 Green - Good/positive/recommended
- 🟠 Orange - Neutral/acceptable/trade-offs
- 🔴 Red - Poor/negative/avoid

### Option details

For each option, include:

1. **Approach** - One sentence explaining the approach
2. **Key details** - Bullet list with bold labels (pricing, package, use case)
3. **Example code** - Representative code snippet showing usage
4. **Pros/Cons** - Bullet lists with bold labels: `**Category:** Explanation`
5. **Technical notes (optional)** - Implementation tips or gotchas

### Recommended solution summary

At the end, include:

1. **List of recommendations** - One line per problem space
2. **Rationale** - Brief explanation of decision criteria
3. **Trade-offs** - Acknowledge what's being sacrificed
4. **Next steps** (optional) - Implementation order if relevant

## Best practices

1. **Break into problem spaces** - Identify independent decisions that can be solved separately
2. **Be opinionated with evidence** - Make clear recommendations using code examples and honest trade-offs
3. **Keep it scannable** - Use emoji indicators, concise descriptions, and consistent naming (1a/1b/1c)

## What to avoid

- Don't create problem spaces for decisions that are already made
- Don't include options that are clearly non-viable
- Avoid redundancy between table and option details (trim option details)
- Don't use generic pros/cons - be specific to the use case
- Avoid unnecessary horizontal rules (no `---` lines between sections)

## Example

```markdown
# Solution Options: Database Selection

## Overview

This document evaluates different database options for a task management application with 10K+ users.

## Problem space 1: Database engine

**Context:** Need to choose a primary database engine for storing user data and tasks.

| Feature | Option 1a: PostgreSQL | Option 1b: MongoDB | Option 1c: SQLite |
|---------|----------------------|--------------------|--------------------|
| **Scalability** | 🟢 Excellent (millions of rows) | 🟢 Excellent (horizontal scaling) | 🔴 Limited (single file) |
| **Query complexity** | 🟢 Full SQL support | 🟠 Limited joins | 🟢 Full SQL support |
| **Setup complexity** | 🟠 Requires server | 🟠 Requires server | 🟢 File-based, no server |
| **Cost** | 🟢 Free (open source) | 🟢 Free (open source) | 🟢 Free (public domain) |
| **Recommendation** | **Best for production:** Proven scalability with full relational features. | Use only if you need flexible schemas and horizontal scaling. | Avoid for multi-user apps; suitable only for local-first tools. |

### Option 1a: PostgreSQL (recommended)

**Approach:** Use PostgreSQL as primary relational database with Prisma ORM.

**Key details:**
- **Package:** Prisma ORM
- **Hosting:** Can use managed services (Supabase, Railway, Render)
- **Cost:** Free tier available on most platforms

**Example code:**

\`\`\`typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const tasks = await prisma.task.findMany({
  where: { userId: user.id },
  include: { assignee: true },
  orderBy: { createdAt: 'desc' }
});
\`\`\`

**Pros:**
- **Proven scalability:** Handles millions of rows efficiently
- **Full SQL support:** Complex queries, transactions, foreign keys
- **Strong ecosystem:** Excellent tooling and managed hosting options
- **ACID compliance:** Data integrity guarantees

**Cons:**
- **Requires server:** Can't use for offline-first applications
- **Schema migrations:** Requires planning for schema changes
- **Connection limits:** Need connection pooling for high concurrency

### Option 1b: MongoDB

**Approach:** Use MongoDB document database with Mongoose ODM.

**Key details:**
- **Package:** Mongoose ODM
- **Hosting:** MongoDB Atlas (managed service)
- **Cost:** Free tier (512 MB)

**Example code:**

\`\`\`javascript
import mongoose from 'mongoose';

const Task = mongoose.model('Task', {
  title: String,
  userId: mongoose.ObjectId,
  status: String,
  createdAt: Date
});

const tasks = await Task.find({ userId: user.id }).sort({ createdAt: -1 });
\`\`\`

**Pros:**
- **Flexible schemas:** Easy to add fields without migrations
- **Horizontal scaling:** Built-in sharding support
- **JSON-native:** Natural fit for JavaScript applications

**Cons:**
- **Limited joins:** Poor performance for relational queries
- **Data duplication:** Often requires denormalization
- **Transaction limitations:** Multi-document transactions are complex

### Option 1c: SQLite

**Approach:** Use SQLite file-based database for local storage.

**Key details:**
- **Package:** `better-sqlite3` npm package
- **Storage:** Single `.db` file on filesystem
- **Cost:** Free (public domain)

**Example code:**

\`\`\`javascript
import Database from 'better-sqlite3';

const db = new Database('tasks.db');

const tasks = db.prepare(`
  SELECT * FROM tasks 
  WHERE user_id = ? 
  ORDER BY created_at DESC
`).all(userId);
\`\`\`

**Pros:**
- **Zero setup:** No server or configuration needed
- **Excellent performance:** Fast for small-medium datasets
- **Full SQL support:** Complete SQL feature set

**Cons:**
- **Single-user limitation:** No concurrent writes from multiple servers
- **Size constraints:** Performance degrades with large datasets
- **No replication:** Difficult to backup and replicate

## Recommended solution summary

**Problem space 1:** Option 1a (PostgreSQL)

**Rationale:**
- Need multi-user support with concurrent access
- Relational data model fits task management domain
- Excellent managed hosting options available

**Trade-offs:**
- Requires server infrastructure (can't use for offline-first)
- Schema migrations add deployment complexity

**Next steps:**
1. Set up PostgreSQL instance (use Supabase free tier)
2. Define Prisma schema with Task and User models
3. Implement connection pooling for production
```

