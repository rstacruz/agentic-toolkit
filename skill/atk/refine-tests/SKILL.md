---
name: refine-tests
description: "Guidelines for identifying redundant tests, coverage gaps, opportunities for improving tests"
---

Plan mode.

Analyse the tests added in this branch and produce a comprehensive test analysis report.

## Goal

Minimum tests with maximum coverage. High-value tests that catch regressions. Improve readability and maintainability.

**The value/cost test:** For every test, ask: *"If this test fails in six months, will it tell me exactly what broke — or will it just tell me that I changed a line of code?"* Tests that only answer the latter are low-value candidates for removal.

**High-value tests** (keep): focus on requirements/behavior, survive internal refactors, document domain rules, cover edge cases and boundary conditions, run fast and deterministically.

**Low-value tests** (remove): pin implementation details, duplicate coverage already provided by a higher-level test, verify trivial/obvious behavior, or exist only as TDD scaffolding that was never cleaned up.

## How to analyse

### Analysis approach

Systematically examine tests across 4 dimensions:

- **Low-value** — redundant, brittle, or trivial tests to remove (§2 criteria)
- **Gaps** — missing branches, errors, edge cases, integration coverage (§3 criteria)
- **Quality** — weak assertions, missing negative cases (§4)
- **Readability** — apply testing-practices guidelines TP1-TP3 (§5)

## Output format

Structure your analysis as a report.

For each issue found, include: location (file/line), what's wrong, and specific recommendation with code example where applicable.

Sections:

### 1. Test inventory
Group by file type (unit/integration/e2e). For each file:
- Filename with test count
- Numbered list of test descriptions
- Running total

### 2. Low-value test analysis
Identify tests that should be removed. For each, state the category and confidence:

**Redundancy** — duplicate coverage of the same code path:
- **HIGH:** Identical logic, same code path → recommend removal
- **MEDIUM:** Same behavior at different layers → consider consolidation
- **LOW:** Similar setup but different concerns → keep both

**Brittle** — pins implementation details rather than behavior:
- Tests that break when a private variable is renamed, a method is extracted, or internal call order changes — without any change to observable behavior
- Ask: would this test still pass after a pure refactor? If no, it's brittle → recommend removal

**Trivial** — tests obvious or boilerplate behavior with no regression value:
- Simple getters/setters, standard library behavior (e.g., array appends an item), class instantiation checks ("can this be constructed?")
- TDD scaffolding left over from the red phase that no longer documents anything meaningful
- → recommend removal

### 3. Coverage gaps
Identify missing tests with priority levels:

**Gap criteria:**
- **HIGH:** Untested main flows, missing integration points, unhandled errors
- **MEDIUM:** Edge cases, secondary flows, missing layer coverage
- **LOW:** Rare scenarios, defensive checks

### 4. Assertions & behaviour
Check test quality and what they actually verify:

**Check for:**
- **Weak assertions:** Assertions that always pass (e.g., `expect(true).toBe(true)`), or don't verify the actual behaviour (e.g., checking function was called but not what it returned)
- **Missing negative cases:** Tests for what should NOT happen (invalid inputs, error states, edge cases that should fail)
- **Missing side effects:** Tests that verify the primary outcome but miss secondary effects (state changes, events fired, cache updates, downstream calls)

### 5. Readability improvements
Reference TP1, TP2, TP3 guidelines.

### 6. Recommendations summary
Provide actionable summary with quantifiable impact:

- **Remove** (N tests → save ~X lines): ❌ [File] - "[test name]" (R1)
- **Add** (N critical tests → ~X lines): ✅ [Description] (G1)
- **Refactor** (N improvements): 🔧 [Description] (I1)

**Net result:**
- Tests: X → Y (remove N, add M)
- Coverage: ~X% → ~Y%
- Maintainability: [Qualitative assessment]
- Lines: ~X → ~Y

## Notes

- Use git commands to identify test files: `git diff origin/main...HEAD --name-only | grep -E '\.(test|spec)\.'`
- Reference testing-practices skill for detailed TP guidelines

## Example output

```markdown
# Test analysis plan

## Test inventory
### Unit tests (1 file, 3 tests)
**`auth.test.ts` (3 tests):**
1. Validates correct password
2. Rejects incorrect password
3. Throws on missing user
**Total: 3 tests**

## Low-value test analysis
### Redundancy (HIGH) - Recommend removal
**R1: Password validation tested twice**
- `auth.test.ts` test #1 and integration test both verify bcrypt comparison
- **Why redundant:** Integration test covers the full flow including unit behavior
- **Recommendation:** Keep integration test, remove unit test #1
- **Confidence:** HIGH - no unique value in unit test

### Brittle (HIGH) - Recommend removal
**R2: Test pins internal call order, not behavior**
- `auth.test.ts` test #3 "Throws on missing user" asserts `db.findUser` was called before `bcrypt.compare`
- **Why brittle:** Verifies internal implementation order, not the observable outcome (the thrown error); breaks on any refactor that reorders calls
- **Recommendation:** Remove call-order assertion; the thrown error is already verified by the `toThrow` assertion
- **Confidence:** HIGH - tells you a line of code changed, not that logic broke

## Coverage gaps
### HIGH gaps - Must address
**G1: Missing session token generation test**
- **Missing:** No test verifies JWT token creation after successful login
- **Location:** `auth.ts:45` - `generateToken()` call
- **Impact:** HIGH - core auth flow
- **Recommendation:** Add test in `auth.test.ts` verifying token structure and expiry

## Assertions & behaviour
### Weak assertion - always passes
**A1: `validateUser` test doesn't verify actual validation**
- **Location:** `auth.test.ts` test #2 "rejects incorrect password"
- **Issue:** Assertion mocks bcrypt but never verifies the actual error message or return value
- **Fix:** Add assertion that checks the thrown error contains "Invalid credentials"

### Missing negative case
**A2: No test for malformed token format**
- **Location:** Missing test for `verifyToken()` with invalid JWT format
- **Issue:** Only tests valid and expired tokens, not malformed/invalid format
- **Fix:** Add test case with token "not.a.valid.jwt" expecting specific error

## Readability improvements (TP guidelines)
### TP1: Reduce test repetition with constants
**I1: Repeated test user credentials**
- **Location:** All tests in `auth.test.ts`
- **Issue:** `email: 'test@example.com'` duplicated 5 times
- **Recommendation:** Extract `const TEST_USER = { email: 'test@example.com', password: 'pass123' }`

## Recommendations summary
### Remove (2 tests → save ~25 lines)
1. Remove `auth.test.ts` - "validates correct password" (R1)
2. Remove `auth.test.ts` - call-order assertion in "Throws on missing user" (R2)
### Add (1 critical test → ~20 lines)
1. Add session token generation test (G1)
### Fix assertions (2 improvements)
1. Fix weak assertion in `validateUser` (A1)
2. Add negative test for invalid token format (A2)
### Refactor (1 improvement)
1. Extract test user constants (I1)
### Net result
- **Tests:** 3 → 4 (remove 1, add 2)
- **Coverage:** ~60% → ~90% (adds token generation, negative case)
- **Maintainability:** Improved via constants and stronger assertions
- **Lines:** ~50 → ~60 (slight increase, better quality)
```


