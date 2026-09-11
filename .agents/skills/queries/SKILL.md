---
name: queries
description: Build, review, or optimize Active Record queries, scopes, eager loading, batching, aggregation, and locking. Use when data access shape or query performance is the main concern; use models for domain behavior and migrations for indexes or constraints.
---

# Queries

Build composable relations that express the intended dataset in SQL and execute only where the result is consumed.

## Start from the access boundary

- Scope from the authorized relation or owning association before adding filters. A later filter must not broaden visibility.
- Return `ActiveRecord::Relation` from scopes and reusable query methods so callers can compose ordering, limits, and additional constraints.
- Keep query ownership near the model whose records are returned. Use a namespaced query object only when a multi-model query is reused and no model is a natural owner.
- Avoid `default_scope`; make ordering, tenancy, and visibility explicit at the call site or authorized boundary.

## Keep SQL safe and intentional

- Use hash conditions, bound parameters, and sanitized order fragments. Never interpolate request input into SQL.
- Use `find_by` when absence is expected and `find_by!` or `find` when absence should abort the flow.
- Use `exists?`, `pick`, `pluck`, `count`, and database aggregation when full records are unnecessary.
- Preserve relations until execution. Avoid converting to arrays early or filtering database-sized datasets in Ruby.

## Control loading

- Inspect how the consumer traverses associations. Add `includes`, `preload`, or `eager_load` only for associations actually used.
- Choose preload behavior deliberately: separate queries avoid join multiplication; joins are appropriate when filtering or ordering by the related table.
- Use `strict_loading` where it usefully exposes accidental lazy loading.
- Do not fix one N+1 by eagerly loading a large graph for every caller. Keep loading decisions next to the query that needs them.

## Handle large datasets

- Use `find_each`, `find_in_batches`, or cursor-based iteration for unbounded collections. Do not load an entire table into memory.
- Select only required columns for large exports or calculations, while preserving columns Rails needs for identity and associations.
- Keep deterministic ordering for pagination and batch work. Include a stable tie-breaker when the primary sort is not unique.
- Treat offsets on large or changing datasets cautiously; prefer keyset/cursor pagination when consistency or scale requires it.

## Preserve concurrency rules

- Use transactions for atomic groups of reads and writes, but do not hold transactions open across network calls or user interaction.
- Use optimistic or pessimistic locking only for a concrete race. Retry narrowly and cap retries.
- Enforce uniqueness and ownership in the database; a preflight query is useful feedback, not a concurrency guarantee.

## Keep query code lean

- Use the smallest relation that expresses the required dataset. Do not add a query object, query DSL, or generic filter framework for one readable relation.
- Keep each visibility rule and reusable filter in one owner. Do not duplicate equivalent SQL fragments across policies, controllers, models, and jobs.
- Extract a named scope or query object only when it makes multiple real callers clearer; remove superseded paths when consolidating.
- Test only membership, ordering, boundaries, and performance characteristics that belong to the application contract. Do not assert incidental SQL text or Active Record internals.
- Do not leave query dumps, temporary counters, benchmark output, or verbose SQL logging in application code. Use diagnostic tooling during investigation and remove it before finishing.

## Verify behavior and cost

Test returned membership, ordering, boundaries, and composability. Reproduce suspected N+1s with the actual consumer. Use query logs or `explain` for a demonstrated performance concern, and add an index through the migrations skill only when the query plan and data shape justify it.

Framework reference: [Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html).
