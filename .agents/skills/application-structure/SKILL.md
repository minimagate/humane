---
name: application-structure
description: Organize Rails application code, namespaces, concerns, domain objects, and autoload paths. Use when deciding where code belongs, reducing structural clutter, or fixing Zeitwerk naming and reloading issues; do not use to introduce speculative architecture.
---

# Application Structure

Keep the repository easy to navigate by following Rails conventions and giving each behavior one obvious owner.

## Apply the project philosophy

- Start with Rails conventions and the existing application structure. Add a custom layer only when the domain requires a boundary Rails does not already provide.
- Give every rule, query, presentation decision, side effect, and failure one obvious owner. Do not maintain the same knowledge in several layers.
- Implement the smallest coherent change that satisfies the current requirement. Do not build for hypothetical reuse, scale, providers, or workflows.
- Prefer direct, readable code over indirection, DSLs, registries, generic wrappers, and one-method object proliferation.
- Test only meaningful behavior at its narrowest public boundary. Do not duplicate framework behavior or the same contract across layers.
- Log an actionable failure once at the boundary that owns it. Remove debug output, temporary instrumentation, obsolete branches, and superseded abstractions before finishing.

## Follow Zeitwerk conventions

- Make each file path match the constant it defines, with directories representing namespaces.
- Do not `require` application code under autoload paths. Require standard-library and gem files normally when needed.
- Put ordinary application classes under a suitable `app/` directory; Rails autoloads custom `app` subdirectories automatically.
- Use `lib` for code that is not application domain code, and configure `config.autoload_lib(ignore:)` deliberately when its Ruby code should reload and eager load.

## Choose the smallest natural owner

- Keep request coordination in controllers, persisted domain rules in models, presentation in views/helpers/components, and asynchronous coordination in jobs.
- Put reusable non-persistent domain behavior in a plainly named object or cohesive namespace under `app/`. Name it for the business responsibility, not a generic technical suffix alone.
- Create a form, query, policy, serializer, or similar object only when it owns a distinct contract that would otherwise blur an existing layer.
- Do not add a `services` dumping ground, parallel architecture, or abstraction layer for one short use case.

## Use namespaces and concerns carefully

- Namespace classes when they form a cohesive domain or interface boundary, not merely because a directory has grown.
- Extract a concern only for one capability shared by multiple owners. A concern must make each including class easier to understand.
- Keep constants private to their namespace when they are not part of the application-wide API.
- Avoid circular dependencies and bidirectional orchestration between namespaces.

## Preserve reload safety

- Do not cache reloadable class or module objects in long-lived framework state.
- Use Rails reloader hooks for boot-time integration with reloadable application code; use autoload-once paths only when the framework must retain the class object.
- Keep initializers focused on configuration and integration setup. Do not place evolving domain logic in `config/initializers`.
- Ensure eager loading can load every production constant without relying on request order.

## Keep the tree tidy

- Remove dead code, abandoned wrappers, duplicate helpers, and empty namespaces when a change makes them obsolete.
- Mirror source namespaces in tests and keep supporting files close to their owner.
- Preserve established repository names and locations unless the move materially improves ownership. Update every constant reference when moving code.
- Prefer a few cohesive files over many one-method objects or one file containing unrelated responsibilities.
- When a new owner replaces an old path, remove the old path in the same change instead of leaving aliases, duplicate entry points, or speculative compatibility code.

## Verify

Run the narrow behavioral tests, the configured Ruby linter, and `bin/rails zeitwerk:check`. Boot in the relevant environment when changing initializers, eager-loading behavior, or autoload paths.

Framework reference: [Autoloading and Reloading Constants](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html).
