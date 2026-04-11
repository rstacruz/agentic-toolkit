---
name: coding-practices
description: >
  Contains important guidelines for software engineering, coding, programming. Includes (but not limited to):
    - CP1: Functional core, imperative shell
    - CP2: Operational vs unexpected errors
    - CP3: Result-oriented interface pattern
    - CP4: Presentational vs container components
    - CP5: Log context builder pattern
  Use this when writing, editing, debugging, planning, or otherwise working with:
    - Any programming work
    - UI components in React, Vue, or similar
    - JavaScript, TypeScript, Rust, or any programming language
---

## CP1: Functional core, imperative shell

Separate pure logic (core) from side effects (shell).

**Functional core:**
- Pure functions only
- No I/O, DB calls, external state
- Testable in isolation
- Operates on given data only

**Imperative shell:**
- Handles all side effects
- DB calls, network, file I/O
- Calls core for business logic
- Thin layer around core

> Further reading: <https://testing.googleblog.com/2025/10/simplify-your-code-functional-core.html>

AVOID: mixed

```js
function sendExpiryEmails() {
  for (const user of db.getUsers()) {
    if (user.subscriptionEndDate <= Date.now() && !user.isFreeTrial) {
      email.send(user.email, `Expired ${user.name}`);
    }
  }
}
```

BETTER: separated

```js
// Core
function getExpiredUsers(users, cutoff) {
  return users.filter((u) => u.subscriptionEndDate <= cutoff && !u.isFreeTrial);
}

function generateEmails(users) {
  return users.map((u) => [u.email, `Expired ${u.name}`]);
}

// Shell
const expiredUsers = getExpiredUsers(db.getUsers(), Date.now());
if (expiredUsers.length > 0) {
  email.bulkSend(generateEmails(expiredUsers));
}
```

## CP2. Operational vs unexpected errors

Distinguish error types for appropriate handling.

**Operational:**
- Expected failures during normal operation
- User issues, validation failures, network timeouts
- Handle gracefully, log, continue
- Return error values not exceptions

**Unexpected:**
- Programming bugs, system failures
- Memory leaks, null refs, logic errors
- Throw exceptions, crash/restart
- Should not occur in production

> Further reading: <https://github.com/goldbergyoni/nodebestpractices/blob/master/sections/errorhandling/operationalvsprogrammererror.md>

AVOID: treat all errors same

```js
function publishArticle(articleId) {
  const article = db.getArticle(articleId);
  if (!article) throw new Error("Article not found"); // operational as exception
  if (article.wordCount < 300) throw new Error("Too short");
  article.status = "published";
  db.save(article);
  return article;
}

try {
  publishArticle(456);
} catch (err) {
  logger.error(err);
  process.exit(1); // crashing for operational
}
```

BETTER: different handling per type

```js
// Returns error objects for operational
function validateArticleForPublishing(article) {
  if (!article) return { ok: false, error: "Article not found" };
  if (article.wordCount < 300) return { ok: false, error: "Article too short" };
  if (!article.title) return { ok: false, error: "Missing title" };
  return { ok: true };
}

function markAsPublished(article) {
  return { ...article, status: "published", publishedAt: Date.now() };
}

function publish(articleId) {
  const article = db.getArticle(articleId);
  const validation = validateArticleForPublishing(article);

  if (!validation.ok) {
    logger.info(`Cannot publish article 456`, { error: validation.error }); // log and continue
    return res.status(400).json({ error: validation.error });
  }

  const published = markAsPublished(article);
  db.save(published);
}
```

## CP3: Result-oriented interface pattern

Use result objects for complex operations with expected failures.

**Result objects:**
- Success: `{ ok: true, result, data }`
- Failure: `{ ok: false, result, error }`
- Names flexible per project
- Return parseable result code when possible

AVOID: exceptions for expected errors

```ts
function parseJson(input: string) {
  if (!input.trim()) throw new Error("Empty input");
  try {
    return JSON.parse(input);
  } catch {
    throw new Error("Invalid JSON");
  }
}
```

BETTER: result objects

```ts
function parseJson(input: string) {
  if (!input.trim()) return { ok: false, result: "EMPTY_INPUT" };
  try {
    return { ok: true, result: "OK", data: JSON.parse(input) };
  } catch {
    return { ok: false, result: "INVALID_JSON" };
  }
}
```

> Further reading: [Railway-oriented programming](https://fsharpforfunandprofit.com/rop/) (F#, Rust's `Result<T, E>`)

## CP4: Presentational vs container components

Separate React components by responsibility.

**Presentational:**
- Concerned with appearance
- Receive data/callbacks via props
- No API calls or state management
- Focus on markup/styling
- Highly reusable

**Container:**
- Concerned with behaviour
- Manage state and side effects
- Handle data fetching, business logic
- Pass data/callbacks to presentational

AVOID: mixed

```tsx
function UserProfile() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchUser().then(setUser).catch(setError)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!user) return <div>No user found</div>;

  return (
    <div className="user-profile">
      <img src={user.avatar} alt={user.name} className="avatar" />
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      <button onClick={() => updateUserStatus(user.id, "active")}>
        Activate
      </button>
    </div>
  );
}
```

BETTER: separated (View presentational, Profile container, useUser hook)

```tsx
function UserProfileView({ user, onActivate }: UserViewProps) {
  return (
    <div className="user-profile">
      <img src={user.avatar} alt={user.name} className="avatar" />
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      <button onClick={onActivate}>Activate</button>
    </div>
  );
}

function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchUser(userId).then(setUser).catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  const activate = useCallback(() => {
    if (user) updateUserStatus(user.id, "active");
  }, [user]);

  return { user, loading, error, activate };
}

function UserProfile({ userId }: { userId: string }) {
  const { user, loading, error, activate } = useUser(userId);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!user) return <div>No user found</div>;

  return <UserProfileView user={user} onActivate={activate} />;
}
```

> Further reading: <https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0>

## CP5. Log context builder pattern

When logging gets redundant, build log context incrementally. Only use if reduces lines.

AVOID: repetitive

```ts
function acceptLatestEvent(session) {
  const user = session.getUser();
  if (!user) log.info("No user found", { session_id: session.id });

  const event = user.getLatestEvent();
  if (!event)
    log.info("No event found", {
      session_id: session.id, user_id: user.id, profile_id: user.profileId,
    });

  logContext.event_id = event.id;
  event.accept();
  log("Event accepted", {
    session_id: session.id, user_id: user.id, profile_id: user.profileId, event_id: event.id,
  });
}
```

BETTER: construct context as you go

```ts
function acceptLatestEvent(session) {
  const logContext = {
    session_id: session.id, user_id: null, profile_id: null, event_id: null,
  };

  const user = getUser();
  if (!user) log.info("No user found", logContext);

  logContext.user_id = user.id;
  logContext.profile_id = user.profileId;
  const event = user.getLatestEvent();
  if (!event) log.info("No event found", logContext);

  logContext.event_id = event.id;
  event.accept();
  log("Event accepted", logContext);
}
```

