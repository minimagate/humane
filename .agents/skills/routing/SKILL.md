---
name: routing
description: Add or change Rails routes, resource nesting, URL helpers, namespaced modules, or operation endpoints. Use when mapping HTTP resources to controllers; keep routes resourceful and aligned with controller ownership.
---

# Routing

Keep `config/routes.rb` compact, resourceful, and readable from top to bottom. Inspect `bin/rails routes` and the affected controller/view helpers before changing it.

## Follow the current map

- Top-level authenticated navigation uses ordinary plural resources.
- Parent-owned controllers live in a matching module while URLs remain nested under the parent; express this with `scope module:` inside the parent `resources` block.
- Use singular `resource` for one conceptual operation per parent.
- Use plural `resources` for collections and member records.
- Declare `only:` for every resource. Do not expose unused Rails actions.
- Use `controller:` when the public resource name should differ from the implementation name.
- Use `as:` sparingly to make nested operation helpers read naturally and avoid collisions.

## Model actions as resources

Do not add `member` or `collection` verbs to an already broad controller when a small operation resource gives the action its own policy and controller. Prefer a dedicated operation resource over a custom verb handled by the parent controller.

Nest only when the parent is part of identity, authorization context, or navigation. When a route is nested, the controller must verify the child belongs to that parent; URL structure alone does not enforce it.

Keep route names in product language. Internal class names may differ through `module`, `scope`, `controller`, and `as` without leaking awkward implementation terms into URLs.

## Update consumers together

When changing a route, update controllers, redirects, `form_with` model arrays, `link_to`/`button_to`, Turbo templates, mailers, and controller tests in the same change. Prefer generated helpers over string URLs.

## Keep the route map lean

- Add the smallest resourceful route that exposes the required operation. Do not create routing concerns, helper wrappers, alias families, or a custom DSL for one route or speculative reuse.
- Keep ownership visible in the route hierarchy and controller module. Avoid duplicate paths to the same command, deeply nested resources, and operation logic split between route constraints and controllers.
- Add only request coverage for the changed endpoint, authorization, and observable result. Do not test every generated helper, duplicate Rails recognition behavior, or repeat model and policy contracts.
- Routing changes must not add request dumps, debug middleware, or per-route logging. Keep operational failures logged once by the controller, domain command, or external boundary that owns them.

## Verify

Run `bin/rails routes` and inspect the exact verb, path, controller action, and helper. Then run the narrow controller tests that exercise the changed helpers and request contract.
