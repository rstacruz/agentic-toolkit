---
name: refine-implementation
description: Refine an implementation
---
# Refine implementation

Refine implementation (uncommitted changes, branch, PR) by identifying bugs/impacts, predicting issues, verifying changes.

## Workflow

### 1. Determine what to review

Based on the input provided, determine which type of review to perform:

1. **No arguments (default)**: Review all uncommitted changes
   - Run: `git diff` for unstaged changes
   - Run: `git diff --cached` for staged changes

2. **Commit hash** (40-char SHA or short hash): Review that specific commit
   - Run: `git show $ARGUMENTS`

3. **Branch name**: Compare current branch to the specified branch
   - Run: `git diff $ARGUMENTS...HEAD`

4. **PR URL or number** (contains "github.com" or "pull" or looks like a PR number): Review the pull request
   - Run: `gh pr view $ARGUMENTS` to get PR context
   - Run: `gh pr diff $ARGUMENTS` to get the diff

Use best judgement when processing input.

### 2. Gather context

**Diffs alone are not enough.** After getting the diff, read the entire file(s) being modified to understand the full context. Code that looks wrong in isolation may be correct given surrounding logic—and vice versa.

- Use the diff to identify which files changed
- Read the full file to understand existing patterns, control flow, and error handling
- Check for existing style guide or conventions files (CONVENTIONS.md, AGENTS.md, .editorconfig, etc.)

### 3. Identify refinements

**Bugs** - Your primary focus
- Logic errors, off-by-one mistakes, incorrect conditionals
- If-else guards: missing guards, incorrect branching, unreachable code paths
- Edge cases: null/empty/undefined inputs, error conditions, race conditions
- Security issues: injection, auth bypass, data exposure
- Broken error handling that swallows failures, throws unexpectedly or returns error types that are not caught.

**Impact** - Your secondary focus
- Integration points affected: APIs, shared state, database schema, config changes
- Downstream consumers: UI components, services, scripts that call modified code
- Cross-cutting concerns touched: auth, logging, caching, error handling
- Migration implications: data transforms, backwards compatibility breaks
- Follow code paths through changed functions to assess ripple effects

**Structure** - Does the code fit the codebase?
- Does it follow existing patterns and conventions?
- Are there established abstractions it should use but doesn't?
- Excessive nesting that could be flattened with early returns or extraction

**Performance** - Only flag if obviously problematic
- O(n²) on unbounded data, N+1 queries, blocking I/O on hot paths

**Consistency**
- Verify implementation aligns with existing codebase patterns and project guidelines
- Naming conventions, testing strategies, architectural style
- Code/tests follow AGENTS.md guidelines (if provided)

**Polish**
 - Outdated documentation or comments?
 - Opportunities to simplify?
 - Accessibility issues? (eg, wrong role, missing labels)

**Before you flag something:**

**Be certain.** If you're going to call something a bug, you need to be confident it actually is one.

- Only review the changes - do not review pre-existing code that wasn't modified
- Don't flag something as a bug if you're unsure - investigate first
- Don't invent hypothetical problems - if an edge case matters, explain the realistic scenario where it breaks
- If you need more context to be sure, use the available tools to get it
- If concerns require user decisions/context, ask focused clarifying questions before refining

**Don't be a zealot about style.** When checking code against conventions:

- Verify the code is *actually* in violation. Don't complain about else statements if early returns are already being used correctly.
- Some "violations" are acceptable when they're the simplest option. A `let` statement is fine if the alternative is convoluted.
- Excessive nesting is a legitimate concern regardless of other style choices.
- Don't flag style preferences as issues unless they clearly violate established project conventions.

### 4. Do updates

**Implement changes** - Make changes based on your analysis.

### 5. Verify

Use the *verify-implementation* skill to verify the implementation.

Look out for tests to run, linting, formatting, other preflight checks, and so on.

### 6. Report

Give a summary of what has transpired.

Also give this session a final summary code: `CHANGES_DONE` or `NO_CHANGES_REQUIRED`

## Guidelines

- Focus refinements on high-signal feedback—not style nitpicks
- Propose concrete alternatives, not just problems
- Provide assessments in the conversation for user review; don't write Markdown files
- Remember your goal is to refine these changes to be ready for merging into the main branch
