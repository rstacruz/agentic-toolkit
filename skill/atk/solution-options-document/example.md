# Solution Options: Google Calendar Integration

## Overview

This document evaluates different solution approaches for integrating Google Calendar functionality into the application. Each problem space is analyzed independently with multiple solution options.

## Problem space 1: Google Calendar API access

**Context:** Need to authenticate and interact with Google Calendar API to read/write calendar events.

| Feature | Option 1a: Google APIs directly | Option 1b: External provider | Option 1c: Service account |
|---------|----------------------------------|------------------------------|----------------------------|
| **Pricing** | 🟢 Free tier, 1M requests/day | 🔴 $9-99/month per user | 🟢 Free tier, 1M requests/day |
| **Implementation complexity** | 🔴 OAuth flow + token management | 🟢 Simplified auth flow | 🟢 Simple server-side |
| **Feature coverage** | 🟢 Full API access | 🔴 Limited by provider | 🟢 Full API access |
| **Multi-calendar support** | 🔴 Google only | 🟢 Google, Outlook, iCloud | 🔴 Google only |
| **User calendar access** | 🟢 Full access | 🟢 Full access | 🔴 Cannot access personal calendars |
| **Vendor dependency** | 🟢 None (official API) | 🔴 Third-party lock-in | 🟢 None (official API) |
| **Use case fit** | 🟢 Multi-user personal calendars | 🟠 Multi-provider calendars | 🔴 Shared/service calendars only |
| **Recommendation** | **Best for most cases:** Free, full-featured, and no vendor lock-in despite OAuth complexity. | Use only if you need multi-provider support and can justify the cost. | Avoid unless you only need shared/service calendars without personal access. |

### Option 1a: Google APIs directly (recommended)

**Approach:** Use official Google Calendar API v3 with OAuth 2.0 authentication.

**Key details:**
- **Package:** `googleapis` npm package
- **Auth flow:** OAuth 2.0 with refresh tokens stored securely
- **Pricing:** Free tier (1,000,000 requests/day)
- **Setup:** Google Cloud Console project required

**Example code:**

```javascript
import { google } from 'googleapis';

const oauth2Client = new google.auth.OAuth2(
  CLIENT_ID,
  CLIENT_SECRET,
  REDIRECT_URL
);

// Set credentials from stored refresh token
oauth2Client.setCredentials({
  refresh_token: user.refreshToken
});

const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

// List events
const events = await calendar.events.list({
  calendarId: 'primary',
  timeMin: new Date().toISOString(),
  maxResults: 10,
  singleEvents: true,
  orderBy: 'startTime',
});
```

**Pros:**
- **Official support:** Direct access to Google's maintained API
- **Full feature access:** Events, calendars, settings, notifications
- **No third-party dependencies:** No vendor lock-in or external rate limits
- **Version control:** Direct control over API versioning

**Cons:**
- **OAuth complexity:** Must handle redirect URLs, token storage, refresh logic
- **Boilerplate code:** More setup compared to abstracted solutions
- **Cloud Console setup:** Requires project configuration

### Option 1b: External provider (Nylas, Cal.com)

**Approach:** Use calendar aggregation service that handles authentication and API normalization.

**Key details:**
- **Providers:** Nylas, Cal.com, Microsoft Graph (for multi-provider)
- **Pricing:** Nylas starts at $9/month per user
- **Multi-calendar:** Unified API for Google, Outlook, iCloud, Exchange

**Example code (Nylas):**

```javascript
import Nylas from 'nylas';

const nylas = new Nylas({
  apiKey: NYLAS_API_KEY,
  apiUri: 'https://api.nylas.com',
});

// List events across all connected calendars
const events = await nylas.events.list({
  identifier: user.grantId,
  queryParams: {
    start: Math.floor(Date.now() / 1000),
    limit: 10,
  }
});
```

**Pros:**
- **Simplified auth:** Provider handles OAuth complexity
- **Multi-calendar support:** Google, Outlook, iCloud through one API
- **Webhook infrastructure:** Built-in real-time update support
- **Abstracted differences:** Normalized API across providers

**Cons:**
- **Additional cost:** $9-99/month per user vs free tier
- **Vendor lock-in:** Dependency on third-party service
- **Feature limitations:** May not expose all native API features
- **Data privacy:** Calendar data flows through third party
- **Provider rate limits:** Additional layer of rate limiting

### Option 1c: Service account access

**Approach:** Use Google service account for server-to-server authentication without user OAuth flow.

**Key details:**
- **Use case:** Service-owned calendars, shared calendars, public calendars
- **Domain-wide delegation:** Required for accessing user calendars (needs Workspace admin)
- **Auth:** JSON key file, no refresh tokens needed

**Example code:**

```javascript
import { google } from 'googleapis';

const auth = new google.auth.GoogleAuth({
  keyFile: 'service-account-key.json',
  scopes: ['https://www.googleapis.com/auth/calendar'],
});

const calendar = google.calendar({ version: 'v3', auth });

// Only works for service account's own calendar or delegated access
const events = await calendar.events.list({
  calendarId: 'company-calendar@example.com',
  timeMin: new Date().toISOString(),
});
```

**Pros:**
- **No user OAuth:** Simpler server-side implementation
- **No token expiration:** Service accounts don't require refresh tokens
- **Batch operations:** Good for administrative tasks

**Cons:**
- **Cannot access personal calendars:** Unless domain-wide delegation is granted (requires Google Workspace admin approval)
- **Limited use case:** Only suitable for service-owned or shared calendars
- **Not multi-tenant friendly:** Not designed for user-specific calendar access

## Problem space 2: Storage of calendar data

**Context:** Need to decide how to store calendar events - direct API calls vs local caching.

| Feature | Option 2a: Direct API calls | Option 2b: Local database with sync | Option 2c: Hybrid (Redis cache) |
|---------|----------------------------|-------------------------------------|----------------------------------|
| **Data freshness** | 🟢 Always up-to-date | 🔴 Stale between syncs | 🟠 Fresh with TTL |
| **Read performance** | 🔴 Slower (network latency) | 🟢 Fast (local queries) | 🟢 Fast on cache hit |
| **Implementation complexity** | 🟢 Simple architecture | 🔴 Sync complexity + conflicts | 🟠 Moderate (cache invalidation) |
| **Offline access** | 🔴 None | 🟢 Full offline support | 🔴 None |
| **API usage** | 🔴 Higher usage | 🟢 Reduced (periodic sync) | 🟠 Reduced (on cache hit) |
| **Storage overhead** | 🟢 None | 🔴 Database scaling required | 🟠 Minimal (Redis) |
| **Consistency** | 🟢 Single source of truth | 🔴 Two sources, conflicts | 🟢 Single source of truth |
| **Recommendation** | **Best for most cases:** Simple architecture with always-fresh data, add Redis caching for performance. | Use only if offline access is critical and you can handle sync complexity. | Good middle ground if you need performance but can accept occasional stale data. |

### Option 2a: Direct API calls (recommended)

**Approach:** Query Google Calendar API in real-time, no local storage of events.

**Pros:**
- Always up-to-date with source of truth
- No data synchronization complexity
- No storage overhead or stale data
- Simpler architecture

**Cons:**
- Higher API usage (rate limit considerations)
- Slower response times (network latency)
- Requires internet connectivity
- No offline access

**Technical notes:**
- Implement caching layer (Redis) for frequently accessed data
- Use ETags for conditional requests
- Batch requests where possible

### Option 2b: Local database with sync

**Approach:** Mirror calendar events in local database (PostgreSQL) with periodic sync.

**Pros:**
- Fast read access (local queries)
- Offline capability
- Reduced API calls
- Can add custom fields/metadata

**Cons:**
- Sync complexity (conflict resolution, deletions)
- Storage overhead and scaling concerns
- Stale data risk between syncs
- Two sources of truth (consistency issues)

**Technical notes:**
- Need background job for sync (every 5-15 minutes)
- Store sync token for incremental updates
- Handle webhook notifications for real-time updates

### Option 2c: Hybrid approach

**Approach:** Cache events temporarily (Redis) with TTL, fallback to API.

**Pros:**
- Balance between speed and freshness
- Automatic cache invalidation (TTL)
- Reduced API calls for repeated requests
- Lower complexity than full sync

**Cons:**
- Cache miss penalty (API call latency)
- Additional infrastructure (Redis)
- Still requires internet for fresh data
- Cache invalidation on calendar changes

**Technical notes:**
- Set TTL based on use case (5-60 minutes)
- Invalidate cache on write operations
- Use webhook to invalidate on external changes

## Problem space 3: Event creation and updates

**Context:** How to handle creating and modifying calendar events from the application.

| Feature | Option 3a: Server-side API calls | Option 3b: Client-side SDK |
|---------|----------------------------------|----------------------------|
| **Security** | 🟢 Tokens secured server-side | 🔴 Tokens in browser memory |
| **Implementation complexity** | 🔴 Additional backend endpoints | 🟢 Direct communication, simpler |
| **Rate limiting** | 🟢 Server-side control | 🔴 Harder to control |
| **Network latency** | 🔴 Extra hop (client → backend → Google) | 🟢 Direct to Google |
| **Error handling** | 🟢 Consistent server-side | 🔴 Client-side, harder to debug |
| **Audit logging** | 🟢 Easy to implement | 🔴 Difficult |
| **Production suitability** | 🟢 Multi-user apps | 🔴 Single-user desktop apps only |
| **Recommendation** | **Required for production:** Security and audit requirements make server-side the only viable option for multi-user apps. | Avoid for production apps due to security risks; only suitable for single-user desktop applications. |

### Option 3a: Server-side API calls (recommended)

**Approach:** All calendar mutations go through backend API routes.

**Pros:**
- Secure token storage (not exposed to client)
- Rate limiting and validation server-side
- Audit logging and access control
- Consistent error handling

**Cons:**
- Additional backend code required
- Extra network hop (client → backend → Google)
- Backend becomes single point of failure

**Technical notes:**
- Create REST endpoints (`POST /api/calendar/events`)
- Validate event data server-side
- Return normalized responses

### Option 3b: Client-side SDK

**Approach:** Use Google Calendar JavaScript SDK in browser with client-side OAuth.

**Pros:**
- Direct communication (fewer hops)
- Reduced server load
- Official Google SDK handles edge cases

**Cons:**
- **Security risk:** Tokens in browser memory/storage
- CORS configuration required
- Rate limiting harder to control
- Client-side errors harder to debug

**Technical notes:**
- Not recommended for production multi-user apps
- Suitable for single-user desktop apps only

## Problem space 4: Real-time synchronization

**Context:** How to keep application state synchronized when calendar events change externally.

| Feature | Option 4a: Google Calendar webhooks | Option 4b: Polling | Option 4c: No synchronization |
|---------|-------------------------------------|--------------------|-----------------------------|
| **Update latency** | 🟢 Real-time (within seconds) | 🔴 2-5 minute delay | 🔴 Manual refresh only |
| **Implementation complexity** | 🔴 Webhook infrastructure + renewal | 🟢 Simple polling logic | 🟢 Simplest |
| **API efficiency** | 🟢 Event-driven, efficient | 🔴 Polling overhead | 🟢 Minimal usage |
| **Scalability** | 🟢 Scales well | 🔴 Poor with many users | 🟢 No background load |
| **Infrastructure requirements** | 🔴 Public webhook URL | 🟢 None | 🟢 None |
| **Reliability** | 🔴 Webhook registration renewal needed | 🟢 Consistent | 🔴 User-dependent |
| **User experience** | 🟢 Excellent (real-time) | 🟠 Acceptable (delayed) | 🔴 Poor (manual) |
| **Recommendation** | **Best for real-time needs:** Provides best UX with real-time updates, worth the infrastructure complexity. | Acceptable fallback if webhook infrastructure is not feasible or for MVP. | Avoid unless building read-only, low-frequency access tool with no collaboration. |

### Option 4a: Google Calendar webhooks (recommended)

**Approach:** Register webhook endpoints to receive push notifications for calendar changes.

**Pros:**
- Real-time updates (within seconds)
- Efficient (no polling overhead)
- Scales well with multiple users
- Official Google support

**Cons:**
- Requires publicly accessible webhook URL
- Need to verify webhook signatures
- Webhook registration renewal (7 days by default)
- Complexity in handling notification payload

**Technical notes:**
- Use `/api/calendar/webhook` endpoint
- Implement signature verification
- Store channel IDs for renewal
- Handle notification batching

### Option 4b: Polling

**Approach:** Periodically query Google Calendar API for changes using sync tokens.

**Pros:**
- Simpler to implement
- No webhook infrastructure needed
- Works behind firewalls
- Easier to test and debug

**Cons:**
- Delayed updates (polling interval)
- Higher API usage (even with no changes)
- Scales poorly with many users
- Inefficient resource usage

**Technical notes:**
- Poll every 2-5 minutes
- Use sync tokens for incremental updates
- Implement exponential backoff on errors

### Option 4c: No synchronization

**Approach:** Only update calendar data when user explicitly refreshes.

**Pros:**
- Simplest implementation
- Lowest API usage
- No background jobs needed

**Cons:**
- **Poor user experience** (stale data)
- User must manually refresh
- Conflicts on concurrent edits
- Not suitable for collaborative features

**Technical notes:**
- Only viable for read-only, infrequent access patterns

## Problem space 5: Time zone handling

**Context:** Need to correctly handle event times across different user time zones.

| Feature | Option 5a: Store UTC, display local | Option 5b: Store in event's original time zone |
|---------|-------------------------------------|------------------------------------------------|
| **Implementation complexity** | 🟢 Standard practice | 🔴 Complex comparison logic |
| **Server-side logic** | 🟢 Consistent | 🔴 Multiple time zones in database |
| **DST handling** | 🟢 Handles correctly | 🟠 Requires careful handling |
| **Multi-timezone support** | 🟢 Easy to support | 🔴 Harder to query/sort events |
| **Semantic preservation** | 🔴 Loses "local time" meaning | 🟢 Preserves semantic meaning |
| **Query complexity** | 🟢 Simple comparisons | 🔴 Complex time zone conversions |
| **Edge cases** | 🟢 Standard patterns exist | 🔴 Time zone change edge cases |
| **Recommendation** | **Industry standard:** Follow established best practices for time zone handling to avoid bugs and complexity. | Avoid unless semantic preservation is absolutely critical and you can handle the added complexity. |

### Option 5a: Store UTC, display local (recommended)

**Approach:** Store all times in UTC, convert to user's time zone for display.

**Pros:**
- Standard practice (reduces bugs)
- Consistent server-side logic
- Handles DST transitions correctly
- Easy to support multiple time zones

**Cons:**
- Requires time zone detection/storage per user
- Conversion logic in display layer
- Must handle "floating" time (no time zone) events

**Technical notes:**
- Use `date-fns-tz` or `luxon` for conversions
- Store user time zone in profile
- Google Calendar API returns both UTC and time zone

### Option 5b: Store in event's original time zone

**Approach:** Preserve original time zone from Google Calendar event.

**Pros:**
- Preserves semantic meaning (e.g., "9 AM local time")
- Matches Google Calendar behavior
- Useful for recurring events

**Cons:**
- Complex comparison logic
- Multiple time zones in database
- Harder to query/sort events
- Edge cases with time zone changes

**Technical notes:**
- Google Calendar stores time zone per event
- Need to convert for user display anyway
- Adds complexity without clear benefit

## Recommended solution summary

**Problem space 1:** Option 1a (Google APIs directly)  
**Problem space 2:** Option 2a (Direct API calls with Redis caching)  
**Problem space 3:** Option 3a (Server-side API calls)  
**Problem space 4:** Option 4a (Google Calendar webhooks)  
**Problem space 5:** Option 5a (Store UTC, display local)

**Rationale:**
- Prioritizes security (server-side token management)
- Balances performance and data freshness
- Uses official APIs with full feature access
- Real-time updates with webhook infrastructure
- Standard time zone handling practices

**Trade-offs:**
- More backend infrastructure required (webhook endpoint, Redis)
- Higher initial implementation complexity
- Depends on webhook reliability (fallback to polling needed)

**Next steps:**
1. Set up Google Cloud Console project and OAuth credentials
2. Implement OAuth flow and token storage
3. Build calendar API wrapper service
4. Set up Redis caching layer
5. Implement webhook endpoint and signature verification
6. Build frontend components with time zone support
