---
name: security
description: Review or implement Rails security controls for authentication, sessions, CSRF, XSS, SQL injection, redirects, secrets, uploads, and external requests. Use for security-sensitive boundaries; use authorization for resource permission rules.
---

# Security

Preserve Rails' secure defaults and make trust boundaries explicit. Fix the smallest owning boundary instead of spreading defensive checks throughout the application.

## Treat input as untrusted

- Constrain mass assignment with explicit strong parameters. Never use `permit!` or assign an open-ended request hash to a model.
- Use bound Active Record conditions and sanitized order clauses. Never interpolate request data into SQL.
- Validate shape, size, and allowed values at the boundary, then enforce durable invariants in models and the database.
- Treat filenames, MIME types, URLs, headers, webhook bodies, and serialized objects as untrusted input.

## Preserve browser protections

- Keep CSRF protection enabled for browser sessions. Exempt an endpoint only when it uses a different authenticated protocol and cannot rely on cookies.
- Rely on Action View escaping. Avoid `raw` and `html_safe`; sanitize rich content with a narrow allowlist.
- Keep session identifiers in secure, HTTP-only, appropriately same-site cookies. Rotate the session after authentication and privilege changes.
- Redirect only to trusted destinations. Validate any user-supplied return URL and prefer internal route helpers.

## Separate authentication and authorization

- Authenticate identity at the request boundary and authorize every protected operation through the authorization skill.
- Do not rely on hidden controls, route nesting, record IDs, or client-side checks as permission enforcement.
- Compare secrets and signed tokens with framework verification APIs or constant-time comparison where applicable.
- Expire credentials and one-time links, bind them to their intended purpose, and make replay behavior explicit.

## Protect secrets and sensitive data

- Keep secrets in encrypted credentials or the deployment environment. Filter sensitive parameters and never log credentials, session contents, tokens, or full personal records.
- Collect and retain only the sensitive data the feature needs. Use Active Record Encryption when application-level encrypted columns are required.
- Keep error responses useful without exposing stack traces, SQL, secret configuration, or internal object inspection outside development.
- Apply security headers and Content Security Policy through centralized Rails configuration rather than ad hoc response mutations.

## Secure external boundaries

- Allow only expected URL schemes and destinations for server-side requests. Defend against SSRF by resolving ownership of destination selection and blocking internal or metadata endpoints where input influences the target.
- Verify webhook signatures against the raw body, enforce freshness when supported, and make processing idempotent.
- Use timeouts for every network call and verify TLS. Do not disable certificate verification.
- Scan, transform, or quarantine uploaded content according to its risk; never trust the browser-declared content type alone.

## Keep security controls focused

- Prefer Rails' built-in protections and the application's established authentication and authorization boundaries. Do not build a parallel security framework for one feature.
- Give each trust decision one owner at the boundary that enforces it, then pass a constrained value inward. Do not scatter equivalent sanitization or permission checks across every layer.
- Add the smallest control that closes the demonstrated risk without broadening data collection, logging, or product scope.
- Add only tests for meaningful allow, deny, malformed, replay, or isolation boundaries. Do not duplicate framework security tests or every equivalent input spelling.
- Log only actionable security events at one established boundary with safe minimal context. Do not log routine allows, raw payloads, secrets, or speculative threat telemetry.
- Remove temporary bypasses, diagnostic endpoints, weakened headers, and superseded compatibility paths before finishing.

## Verify

Add focused tests for the changed security boundary, including a denied or malformed case. Run the narrow suite and `bin/brakeman`; run the dependency audit for release-ready changes when network access is available. Report any finding that cannot be resolved without changing product behavior.

Framework reference: [Securing Rails Applications](https://guides.rubyonrails.org/security.html).
