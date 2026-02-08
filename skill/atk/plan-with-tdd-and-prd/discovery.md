# Discovery Documents

Discovery documents (`artefacts/discovery-<title>.md`) capture environmental context, constraints, and existing architecture for planning.

## Purpose

Capture environmental constraints/context for planning. NOT implementation details or obvious info.

Answers: "What's needed about the environment for good planning decisions?"
Not: "How will I implement this?" (that's TDD)

## When to use

**Use when:**
- Non-obvious findings about existing systems/constraints
- New technology or quirky APIs
- Complex features requiring research before PRD/TDD

**Skip when:**
- Task is well-understood and technology is familiar
- Constraints are obvious from codebase inspection
- Standard patterns apply without investigation

## Typical inclusions

- Current system architecture/patterns
- Existing code structures to follow
- Technical constraints/limitations
- Database schemas/data formats
- Third-party APIs and quirks
- Non-obvious edge cases with business impact
- Library research (capabilities, usage, tradeoffs)

## Typical exclusions

- Implementation pseudocode/code samples (→ TDD)
- Obvious edge cases (eg, "React handles HTML escaping")
- Migration strategies/rollback plans (→ TDD)
- Backwards compatibility solutions (→ TDD)
- "Next steps" or implementation order (→ TDD)
- Test cases/testing strategy (→ TDD)
- Effort estimates/timelines (→ PRD roadmap)

## Condensed summary

Include "condensed summary" H2 at beginning. Write condensed prompt guiding future agents to research independently and reach same conclusions. Prefer code citations over examples.

Include: context (required), function/symbol names with locations, glossary, issues, key insights.

## Discovery vs TDD

Test: "Would this info still be true if we chose completely different implementation?"

- YES → Discovery (eg, "Database uses SQLite", "Tailwind v4 has no config file")
- NO → TDD (eg, "Use buildPrompt() function", "Handle errors with try/catch")

## Patterns to avoid

- Don't document obvious behaviors ("React handles HTML escaping", "UTF-8 works in database")
- Don't include implementation details ("Use try/catch for errors")
