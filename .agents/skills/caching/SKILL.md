---
name: caching
description: Add, revise, or diagnose Rails fragment, collection, low-level, and HTTP caching. Use when repeated work needs acceleration or cache invalidation is wrong; never use caching as the source of truth for correctness or authorization.
---

# Caching

Add caching only around correct behavior with a measurable reuse opportunity. Every cache needs an owner, a key, and an invalidation story.

## Choose the narrowest cache

- Prefer HTTP conditional responses for whole-response freshness and fragment or collection caching for expensive rendered regions.
- Use low-level `Rails.cache.fetch` for expensive non-view computation shared across requests.
- Reuse Active Record cache keys and versions for record-derived content. Use nested fragment caching only when parent freshness follows child changes intentionally.
- Do not cache merely to hide an N+1 query, missing index, or unnecessarily repeated computation inside one request.

## Design complete keys

- Include every dimension that changes the result: record versions, locale, format, feature state, tenant or account, and other relevant inputs.
- Never share authorization-sensitive or user-specific content under a global key.
- Prefer structured key arrays and stable identifiers over hand-built strings.
- Version key formats when changing the meaning or serialization of cached values.

## Own invalidation

- Prefer versioned keys and dependency changes over broad wildcard deletion.
- Use `touch` propagation only when the child truly changes every cached representation of the parent and the write amplification is acceptable.
- Give low-level entries an appropriate expiration. Avoid permanent caches for data that can change outside the key.
- Do not cache Active Record instances in low-level caches; cache identifiers or plain serialized values and re-query current records.

## Preserve correctness under concurrency

- Expect cold misses and concurrent fills. Cached work must be safe to compute more than once.
- Use race-condition protection or locking only when stampedes are demonstrated and the cache store supports the intended semantics.
- Do not use the cache as a lock, idempotency ledger, job claim, or durable state machine.
- Treat cache failure as a performance degradation unless the product explicitly defines otherwise.

## Keep caching lean

- Cache the smallest stable unit that removes demonstrated repeated work. Do not add a cache wrapper, repository layer, or key DSL for one entry.
- Keep each cached result and its invalidation rule with one owner. Avoid overlapping low-level, fragment, and HTTP caches for the same work unless each layer has a measured purpose.
- Do not cache speculative future traffic patterns or every method that appears expensive. Measure the real consumer first.
- Add only tests for application-owned key dimensions, invalidation, isolation, and fallback behavior. Do not test cache-store internals.
- Do not log values, full keys containing sensitive dimensions, hit chatter, or temporary cache diagnostics in application code. Remove instrumentation used for investigation before finishing.
- Remove obsolete keys, expiry code, and invalidation callbacks when a cache path is retired.

## Verify

Test the uncached behavior first. Then verify key variation, expiration or version invalidation, and authorization isolation with caching enabled. Use development cache toggles and instrumentation to confirm meaningful hits without asserting framework implementation details.

Framework reference: [Caching with Rails](https://guides.rubyonrails.org/caching_with_rails.html).
