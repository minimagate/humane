---
name: active-storage
description: Implement or revise Rails Active Storage attachments, direct uploads, variants, previews, service configuration, access control, and cleanup. Use for file-upload and attachment behavior; use security for broader threat review.
---

# Active Storage

Treat attachments as persisted domain relationships and uploaded bytes as untrusted external input.

## Define attachment ownership

- Choose `has_one_attached` or `has_many_attached` from the real domain cardinality and lifecycle.
- Attach only after the owning record and authorization context are established. Route access through the owner rather than treating a blob key as permission.
- Use `with_attached_*` scopes when rendering collections that traverse attachments; avoid per-record metadata queries.
- Keep attachment replacement and deletion behavior explicit. Use `purge_later` after commit when asynchronous cleanup is acceptable.

## Validate uploads safely

- Enforce size, expected content categories, and required presence at the application boundary and domain layer where appropriate.
- Do not trust the filename extension or client-provided content type. Analyze or inspect content server-side when the risk requires it.
- Sanitize displayed filenames and never use them directly as filesystem paths.
- Decide how failed validation and abandoned direct uploads are cleaned up; unattached blobs must not grow without bounds.

## Process files deliberately

- Generate only the variants or previews the product needs. Make processor resource limits and failure behavior suitable for untrusted input.
- Prefer asynchronous analysis and transformation for expensive media work.
- Keep variant definitions stable and named when they are reused. A changed transformation creates a new derived artifact and may require old derivatives to expire naturally or be cleaned up.
- Do not perform large downloads or transformations inside a request when the result can be prepared asynchronously.

## Control delivery and storage

- Configure services per environment without embedding credentials in source.
- Choose redirect, proxy, public, or authenticated delivery from the actual access model. A signed service URL is not a substitute for authorizing the owning record.
- Set content disposition and content type defensively for formats that could execute in a browser.
- Use mirrors, CDNs, or service migration features only with an operational plan for consistency and cleanup.

## Keep attachment code lean

- Implement the smallest attachment flow that satisfies the current file lifecycle and access requirements.
- Use Active Storage's attachment, variant, analyzer, and delivery primitives directly. Do not add a repository, uploader hierarchy, or storage wrapper for one attachment type.
- Keep validation, authorization, processing, and cleanup each with one obvious owner. Do not repeat attachment rules in models, controllers, jobs, and views.
- Add variants, analyzers, services, and metadata only for current product behavior, not hypothetical file types or providers.
- Add only tests for ownership, validation, lifecycle, job effects, and access boundaries. Do not test Active Storage internals or rendered presentation.
- Do not log file bodies, signed URLs, full metadata, or routine upload progress. Report an actionable processing or provider failure once at its owning boundary.
- Remove obsolete variants, preview paths, callbacks, and cleanup branches when replacing an attachment workflow.

## Verify

Test attachment ownership, replacement or purge behavior, invalid size/type boundaries, and any job side effects using small fixture files. Do not assert visual rendering. Exercise direct upload and download authorization in the browser when those flows change.

Framework reference: [Active Storage Overview](https://guides.rubyonrails.org/active_storage_overview.html).
