---
name: mermaid-diagrams
description: >
  Has guidelines for creating Mermaid diagrams and fixing its syntax errors.
    Use this before creating or updating Mermaid diagrams.
---

## Mermaid diagram guidelines

- Quote the labels. Doing so avoids issues with special characters like `/` and `[` and more.

  ```mermaid
  graph TD
  %% avoid:
  A[app/[workspace]/layout.tsx] -->|imports| B[generateDescription]

  %% ok:
  C["app/[workspace]/layout.tsx"] -->|imports| D["generateDescription"]
  ```

- Don't start labels with `-`. These are interpreted as markdown. Use an alternate bullet instead.

  ```
  %% avoid:
  B["- Title here"]
  B["* Title here"]

  %% ok:
  B["· Title here"]
  ```
  
- Use `<br>` for line breaks.

  ```
  %% avoid:
  B["Long title here \n subtext here"]
  %% ok:
  B["Long title here <br> subtext here"]
  ```

- Use double quotes and backticks "` text `" to enclose Markdown text. Consider `**` (bold) and `_` (italic) for flowchart labels. Note that this is only supported in flowchart mode.

  ```
  flowchart LR
  A["`**hello** _world`"]
  ```

- Consider using different shapes when appropriate.

  ```
  flowchart TD
    id1(Title here) %% rounded edges
    id2([Title here]) %% pill
    id2[(Title here)] %% cylinder (database)
    A@{ shape: cloud, label: "Cloud" }
    B@{ shape: lean-r, label: "Skewed rectangle (Input/Output)" }
    C@{ shape: lean-l, label: "Skewed rectangle (Output/Input)" }
    D@{ shape: processes, label: "Stacked rectangles (Multiple processes)" }
  ```
