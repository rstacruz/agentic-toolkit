---
name: testing-practices
description: >
  Contains important guidelines for writing and maintaining tests. Includes (but not limited to):
    - TP1: Reduce test repetition with constants
    - TP2: Test readability
    - TP3: Test quality over quantity
  Use this when writing, editing, debugging, planning, or otherwise working with:
    - Vitest, Jest, or any test framework
    - JavaScript, TypeScript, Rust, or any programming language
---

## TP1: Reduce test repetition with constants

Use object literal constants for compact, readable tests. Avoid helper functions when objects suffice.

AVOID: repetitive

```ts
it("publishes", () => {
  const article = article.create({
    title: "My article", body: "This is an article body", author: "myles-davis",
  });
  expect(article.publish().result).toEqual("PUBLISHED");
});
it("publishes in future", () => {
  const article = article.create({
    title: "My article", body: "This is an article body", author: "myles-davis",
    publishAt: "2030-05-30T00:00:00Z",
  });
  expect(article.publish().result).toEqual("SCHEDULED");
});
```

AVOID: helper functions add cognitive load

```ts
function generateArticle(overrides) {
  return {
    title: "My article", body: "This is an article body", author: "myles-davis",
    ...overrides,
  };
}
it("publishes", () => {
  const article = article.create(generateArticle({}));
  expect(article.publish().result).toEqual("PUBLISHED");
});
```

BETTER: constants

```ts
const BASE_ARTICLE = {
  title: "My article", body: "This is an article body", author: "myles-davis",
} as const;

it("publishes", () => {
  const article = article.create({ ...BASE_ARTICLE });
  expect(article.publish().result).toEqual("PUBLISHED");
});
it("publishes in future", () => {
  const article = article.create({
    ...BASE_ARTICLE, publishAt: "2030-05-30T00:00:00Z",
  });
  expect(article.publish().result).toEqual("SCHEDULED");
});
```

## TP2: Test readability

Prioritize scannability:

- **Target: 10 lines max per test** — scannable at glance
- **Prefer reusable pieces order:**
  1. Reusable constants (only if semantic value or 2+ lines)
  2. Test helper functions (render, interaction helpers)
  3. Mock setup functions
- **Define constants only if:**
  - Semantic value (`DEBOUNCE_DELAY`, `MAX_RETRIES`)
  - OR 2+ lines (multi-line strings, objects)
- **Don't extract trivial data** — `'hello'` clearer inline
- **Maximum reuse** — if multiple tests use same data/helpers, extract
- **Reuse existing helpers** — check before creating new
- **Name descriptively** — verb phrases: `typeAndWait()`, `renderEditable()`
- **Group related operations** — combine in single `act()` blocks
- **Place helpers at end** — after tests, use hoisting. Keeps tests at top for scanning.

```ts
// ✅ Good: semantic constants and helpers
const DEBOUNCE_DELAY = 2000

it('debounces input', () => {
  const textarea = renderEditable({ initialValue: 'Hello' })
  typeAndWait(textarea, 'test', DEBOUNCE_DELAY / 2)
  expect(mockFn).not.toHaveBeenCalled()

  advanceTime(DEBOUNCE_DELAY / 2)
  expect(mockFn).toHaveBeenCalled()
})

function renderEditable(props = {}) {
  const defaultProps = { lang: 'es', initialValue: '' }
  render(<Component {...defaultProps} {...props} />)
  return screen.getByRole('textbox')
}

function typeAndWait(textarea: HTMLElement, value: string, ms: number) {
  act(() => {
    fireEvent.change(textarea, { target: { value } })
    vi.advanceTimersByTime(ms)
  })
}

// ❌ Avoid: extracting every value
const TEST_VALUE_1 = 'hello'
const TEST_VALUE_2 = 'world'
```

## TP3: Test quality over quantity

Focus on behaviour and critical paths vs 100% coverage.

**Avoid testing (noise without value):**
- **CSS/Styling** — no Tailwind classes, color values, style objects (`expect(element).toHaveClass('text-yellow-500')`)
- **HTML defaults** — no browser/framework defaults (button focus, auto-ARIA)
- **Framework behaviour** — no third-party library testing (Radix UI, React Router)
- **Duplicate edge cases** — no separate tests for null vs undefined if handled identically
- **Mirror tests** — no testing both add/remove if logic identical

**Focus on (catches real bugs):**
- **User interactions** — state changes, form submissions, navigation
- **Critical paths** — auth, authorization, data integrity, payments
- **Error handling** — network failures, validation errors, fallbacks
- **Business logic** — calculations, transformations, conditional rendering

**Quantity guidelines:**
- Simple components (<100 lines): 3-8 tests typical
- Complex components (100-300 lines): 8-15 tests typical
- Critical services/utilities: 10-20 tests typical
- If significantly exceeding, review for redundancy

## TP4: Use it.each

**Use it.each** for repeated cases with different inputs/outputs — improves readability, reduces duplication

```js
// Avoid:
it("extracts domain from alice@example.com", () => {
  expect(getDomain("alice@example.com")).toBe("example.com");
});
it("extracts domain from bob@sub.domain.org", () => {
  expect(getDomain("bob@sub.domain.org")).toBe("sub.domain.org");
});

// Prefer:
it.each([
  ["alice@example.com", "example.com"],
  ["bob@sub.domain.org", "sub.domain.org"],
  ["carol@company.co.uk", "company.co.uk"],
])("extracts domain from %s", (email, expectedDomain) => {
  expect(getDomain(email)).toBe(expectedDomain);
});
```


## TP5: Avoid log assertions

**Avoid log assertions** — test observable behaviour or return values
