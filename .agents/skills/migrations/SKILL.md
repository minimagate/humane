---
name: migrations
description: "Create or revise Rails schema migrations, indexes, foreign keys, defaults, or constraints. Use for database structure changes. This application is development-only: keep migrations schema-only and never add data backfills or staged rollout choreography."
---

# Migrations

This is currently a development-only application with no production dataset to preserve. Optimize migrations for a clean, correct schema—not for rolling upgrades across live versions.

## Keep every migration simple

- Use `ActiveRecord::Migration[8.1]` and prefer a reversible `change` method with Rails' migration DSL.
- Create tables with the final intended columns, nullability, defaults, timestamps, references, foreign keys, and indexes.
- Add or remove columns, references, indexes, and constraints directly. Prefer explicit names for composite or partial indexes when the generated name would be unclear.
- Put durable invariants in the database: foreign keys for ownership, unique indexes for uniqueness, and adapter-supported conditional indexes for conditional uniqueness.
- Match the application's existing database adapter and storage choices. Use native structured-data types when they provide useful semantics, and readable string statuses.

## Never backfill development data

Do not write `UPDATE`, `DELETE`, row loops, temporary models, data migrations, dual writes, compatibility columns, phased nullability changes, or expand/contract rollout steps to preserve local records. Do not copy historical backfill-heavy migrations as precedent.

If a schema change conflicts with disposable development data, make the target schema correct and reset/reseed the affected local database. A database reset is destructive, so obtain the user's approval immediately before running it.

Do not add a complicated `up`/`down` migration merely to transform values that can be recreated. Use `up`/`down` only when the schema operation itself cannot be represented reversibly with `change`.

## Manage migration history deliberately

Create a new migration for changes already shared in repository history. An unshared migration on the current feature branch may be corrected in place when doing so keeps the history simpler. Never rewrite a migration known to have been applied by someone else without explicit direction.

Do not edit `db/schema.rb` by hand. Run the migration so Rails updates it, then inspect the schema diff for only the intended version and structure changes.

## Keep schema changes lean

- Express the final schema with the smallest Rails migration. Do not introduce migration helpers, custom DSLs, temporary application models, callbacks, or abstractions for a one-off schema operation.
- Keep each migration readable from top to bottom and limited to one coherent schema change. Avoid conditional environment branches, runtime dependencies, and cross-migration control flow.
- Validate the resulting schema and only the application invariants affected by it. Do not add tests that reproduce Rails migration behavior or preserve disposable development-data permutations.
- Do not add progress output, per-row messages, debug logging, or audit chatter to migrations. These migrations are schema-only; report failures through the migration command itself.

## Verify

Run `bin/rails db:migrate`, the relevant model tests, and a rollback/reapply check when reversibility is not obvious. For a brand-new or reset database path, use `bin/rails db:test:prepare` or the repository setup command and confirm constraints appear in `db/schema.rb`.
