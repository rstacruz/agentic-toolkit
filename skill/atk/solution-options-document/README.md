# Solution Options Document

Evaluate and compare technical approaches with trade-off analysis.

**Use when:** Technology selection, architecture decisions, implementation strategy comparison, technical RFCs

**Don't use:** Decision already made, only one viable option, need implementation details (use TDD), need requirements (use PRD)

## Example: Database selection

> **User:** Evaluate database options for multi-tenant SaaS
>
> **Agent:** (Researches options) (Creates comparison tables)
>
> ```markdown
> # Solution Options: Database Selection
>
> ## Problem space 1: Database engine
>
> | Feature | 1a: PostgreSQL | 1b: MongoDB | 1c: SQLite |
> |---------|---------------|-------------|-----------|
> | **Scalability** | 🟢 Millions of rows | 🟢 Horizontal scaling | 🔴 Limited |
> | **Query complexity** | 🟢 Full SQL | 🟠 Limited joins | 🟢 Full SQL |
> | **Setup** | 🟠 Requires server | 🟠 Requires server | 🟢 File-based |
> | **Recommendation** | **Best for production:** Proven scalability | Use only if need flexible schemas | Avoid for multi-user |
>
> ### Option 1a: PostgreSQL (recommended)
>
> **Approach:** PostgreSQL with Prisma ORM
>
> **Key details:**
> - **Hosting:** Supabase, Railway, Render
> - **Cost:** Free tier available
>
> **Example:**
> ```typescript
> const tasks = await prisma.task.findMany({
>   where: { userId: user.id }
> });
> ```
>
> **Pros:**
> - **Proven scale:** Millions of rows
> - **Full SQL:** Complex queries, transactions
>
> **Cons:**
> - **Server required:** Can't use offline-first
> - **Migrations:** Schema planning needed
>
> ## Recommended solution
>
> **Option 1a (PostgreSQL)** — Multi-user support, relational model fits domain. Trade-off: requires server infrastructure.
> ```

## Example: Auth strategy

> **User:** Compare JWT vs session cookies for API auth
>
> **Agent:** (Creates comparison) (Recommends based on use case: JWT for stateless APIs, sessions for server-rendered apps)

## Structure

1. **Overview** — Brief problem context
2. **Problem spaces** — Independent sub-problems
3. **Comparison tables** — Emoji indicators (🟢 good, 🟠 neutral, 🔴 poor)
4. **Option details** — Approach, key details, code examples, pros/cons
5. **Recommendation** — Final choice with rationale and trade-offs

**See also:** [Full example](./example.md)

**Related:** [`plan-with-tdd-and-prd`](../plan-with-tdd-and-prd/)
