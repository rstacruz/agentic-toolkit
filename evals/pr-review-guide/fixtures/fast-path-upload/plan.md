# Fast-path uploads

## Context

- **Upload pipeline:** `runUploadPipeline` in `src/upload/pipeline.ts` runs `validate → scanForMalware → resizeVariants → generateThumbnails → putObject → saveRecord` for every upload.
- **Need:** some callers (bulk imports, chat attachments) only need the upload stored; resizing three variants and generating three thumbnails dominates their latency.

## Decisions

### 1. Opt-in boolean option

- **Chosen:** add `fastPath?: boolean` to `UploadOptions`, off by default; the handler sets it from `?fast=1`.
- **Why:** existing callers don't change, so the default path stays identical.
- **Risk:** 🟢 low — if wrong, callers that want it simply don't get it.

**Alternatives:**

- ✗ A separate `/uploads/fast` route — duplicates the handler and its validation for one flag.

### 2. Skip thumbnails outright

- **Chosen:** don't call `generateThumbnails` on the fast path.
- **Why:** thumbnails are the slowest step; generating them later needs a job queue the service doesn't have.
- **Risk:** 🟡 med — anything that reads thumbnails for a fast-path upload (gallery and list views) gets a 404.

**Alternatives:**

- ✗ Generate thumbnails lazily on first read — needs a queue and a cache-miss path in the image server.

### 3. Resize to the large variant only

- **Chosen:** pass `["large"]` instead of `VARIANTS` to `resizeVariants` on the fast path.
- **Why:** the large variant is the one every client can fall back to.
- **Risk:** 🟡 med — clients that ask for medium or small fall back to large and download several times the bytes.

**Alternatives:**

- ✗ Skip resizing entirely — the original can be 20 MB, too large for any client to display.
