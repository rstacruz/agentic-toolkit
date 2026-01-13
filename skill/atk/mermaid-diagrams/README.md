# Mermaid Diagrams

Guidelines for creating valid Mermaid diagrams and avoiding syntax errors.

**Use when:** Before creating/updating Mermaid diagrams in documentation, PRs, explanations

## Example: Fix syntax error

> **User:** Fix this Mermaid diagram
>
> ```mermaid
> graph LR
> A[api/[id]/route.ts] --> B[validateInput]
> ```
>
> **Agent:** Special characters need quotes:
>
> ```mermaid
> graph LR
> A["api/[id]/route.ts"] --> B["validateInput"]
> ```

## Example: Create call graph

> **User:** Create call graph for auth flow
>
> **Agent:**
> ```mermaid
> graph LR
>   subgraph "auth/login.ts"
>     A["handleLogin"]:::new
>     B["validateCredentials"]:::new
>   end
>   A -->|"validates via"| B
>   
>   classDef new fill:#9f9,stroke:#333
> ```

## Common fixes

**Quote labels:** Use `"..."` for special chars like `/`, `[`, `]`

**Line breaks:** Use `<br>` not `\n`

**Avoid markdown bullets:** Don't start labels with `-` or `*` (use `·` instead)

**Markdown in labels:** Flowchart only, use backtick wrapper: `` ["`**bold** _italic_`"] ``

**Shapes:** Consider different shapes for clarity — `(Rounded)`, `([Pill])`, `[(Database)]`, `@{ shape: cloud }`

**Related:** [`explain-code`](../explain-code/), [`analyse-and-review-pr`](../analyse-and-review-pr/)
