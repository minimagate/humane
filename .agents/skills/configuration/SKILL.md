---
name: configuration
description: Add or revise Rails application configuration, environment settings, initializers, credentials, and external-service options. Use for boot-time or environment-dependent behavior; do not scatter configuration reads through domain code.
---

# Configuration

Keep configuration explicit, environment-aware, and separate from application behavior.

## Put settings at the right level

- Use `config/application.rb` for application-wide defaults, `config/environments/*.rb` for environment behavior, and focused initializers for library integration.
- Use `Rails.application.config.x` or a small typed configuration object for application-specific settings that multiple owners consume.
- Read configuration at a boundary and pass values inward when that makes domain code easier to test.
- Do not branch repeatedly on `Rails.env` throughout models, controllers, or jobs. Express the environment difference once in configuration.

## Handle secrets safely

- Store secrets in encrypted Rails credentials or the deployment environment. Never commit plaintext secrets, production tokens, or generated local keys intended to remain private.
- Distinguish a missing required secret from an optional feature. Fail clearly at boot for required production configuration rather than much later in a request.
- Do not log configuration objects, credentials, authorization headers, or secret-bearing URLs.
- Keep example environment files limited to names and safe placeholders.

## Keep initializers reload-safe

- Do not reference reloadable application constants directly from initializers unless using the documented reloader hook or autoload-once mechanism.
- Keep initializer ordering independent where possible. If order is essential, make the dependency explicit and narrow.
- Configure a library through its public API. Do not monkey-patch framework behavior for a setting the framework already exposes.
- Avoid network calls, database writes, and other mutable external work during boot.

## Preserve operational clarity

- Centralize external-service endpoints, timeouts, retry limits, sender identities, and feature defaults. Use safe production defaults.
- Keep development conveniences from weakening test or production behavior.
- Treat a feature flag as temporary product state with an owner and removal path, not a permanent substitute for clear code.
- Document non-obvious required settings next to the configuration surface that consumes them.

## Keep configuration lean

- Add the smallest setting at the narrowest correct level. Do not introduce a configuration wrapper, registry, DSL, or environment matrix for one value.
- Keep one canonical source for each setting. Do not mirror the same value across credentials, environment variables, initializers, constants, and model code.
- Extend the framework or library's existing configuration surface before inventing a parallel one.
- Remove retired settings, fallbacks, feature flags, and compatibility branches when their callers disappear.
- Test only application-specific configuration behavior and required-setting failures. Do not test Rails configuration mechanics.
- Do not print configuration during boot or leave diagnostic logging behind. Report a missing required setting once without revealing its value.

## Verify

Boot the application in affected environments or with representative configuration, run `bin/rails runner` for the configured value when safe, and test failure behavior for missing required settings without exposing their contents. Run `bin/rails zeitwerk:check` when autoloading configuration changes.

Framework reference: [Configuring Rails Applications](https://guides.rubyonrails.org/configuring.html).
