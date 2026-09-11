---
name: models
description: Implement or revise Rails domain models, associations, validations, callbacks, state transitions, and persistence behavior. Use for model-layer business rules; use migrations for schema changes and queries for complex relation construction.
---

# Models

Keep persisted state and the business rules that govern it together. Before editing, read the schema, relevant migrations, associations, callers, and nearest model tests.

## Model the domain explicitly

- Follow Rails naming and schema conventions unless an existing integration requires an override.
- Put invariants, state predicates, and domain transitions on the model or a cohesive namespaced domain object. Keep controllers and jobs as coordinators.
- Use Active Model or a plain Ruby object for domain behavior that does not need persistence. Do not create a database table merely to gain validations or naming behavior.
- Prefer small intention-revealing public methods over exposing sequences of attribute mutations to callers.

## Define associations deliberately

- Specify only association options whose behavior is intentional. Choose `dependent:` from the real ownership lifecycle; never add cascading deletion by reflex.
- Keep both sides, foreign keys, nullability, and inverse behavior consistent. Back required ownership and uniqueness with database constraints through the migrations skill.
- Avoid callbacks that silently repair invalid associations. Reject invalid state or perform the transition explicitly.
- Use counter caches, touch propagation, polymorphism, and single-table inheritance only when their lifecycle and query costs are understood.

## Validate durable rules

- Validate user-correctable input and domain constraints close to the model. Keep database constraints for invariants that must survive races and non-Rails writers.
- Back uniqueness validation with a unique index. Validation alone is not concurrency-safe.
- Use conditional validations and custom contexts sparingly; if an object has unrelated validity modes, reconsider the model boundary.
- Add custom validators only when the rule is reused or clearer as its own object.

## Keep callbacks narrow

- Prefer explicit domain methods for multi-step transitions and observable side effects.
- Use callbacks for local model bookkeeping that must happen for every persistence path. Do not hide network calls, job orchestration, or unrelated record creation in ordinary save callbacks.
- Use transaction callbacks such as `after_commit` when an external side effect must observe committed data. Make the receiving operation idempotent.
- Do not use persistence methods that skip callbacks or validations unless bypassing them is intentional and proven safe.

## Preserve transactional integrity

- Wrap a business transition in a transaction when its writes must succeed or fail together.
- Raise or propagate failure inside transactions; do not swallow an exception and commit partial state.
- Use locking only for a demonstrated race. Keep the locked section short and protect the same invariant with a database constraint when possible.

## Keep model code lean

- Implement the smallest model API that expresses the current invariant or transition. Do not add speculative states, callbacks, extension points, or generic lifecycle machinery.
- Group associations, validations, scopes, callbacks, and public domain methods consistently with the repository style.
- Extract a concern only for a cohesive capability shared by multiple classes. Do not use concerns to hide unrelated chunks of a large model.
- Do not create service, command, or form-object layers for one short rule that belongs naturally on the model.
- Keep each invariant and transition in one owner. Do not repeat the same lifecycle checks across models, controllers, jobs, and policies.
- Add only tests that protect distinct public behavior or a material boundary; do not test Rails persistence mechanics or duplicate request coverage.
- Do not add routine persistence logging, callback chatter, or debug output. Log an actionable external failure once at the boundary that owns it.
- Remove obsolete callbacks, scopes, compatibility methods, and superseded state paths when the new behavior replaces them.

## Verify

Add focused model tests for public behavior, validation boundaries, lifecycle transitions, and persistence effects. Run the narrow model test, relevant integration tests, and `bin/rails zeitwerk:check` when constants or namespaces change.

Framework reference: [Active Record Basics](https://guides.rubyonrails.org/active_record_basics.html), including the linked association, validation, and callback guides.
