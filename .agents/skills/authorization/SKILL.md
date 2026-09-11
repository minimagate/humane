---
name: authorization
description: Design or change Rails Pundit policies, scopes, roles, ownership checks, operation permissions, or authorization tests. Use for who may see or mutate data; do not put authorization rules only in views or controllers.
---

# Authorization

Treat policies as the single readable expression of access rules and scopes as the database-level expression of visible records.

## Start closed

`ApplicationPolicy` denies every action and requires every scope to implement `resolve`. Add only the permissions the resource needs. Rely on the inherited `new? -> create?` and `edit? -> update?` aliases unless the actions genuinely differ.

Every authenticated controller action must continue to satisfy `verify_authorized`. Every `index` action must also use `policy_scope` and satisfy `verify_policy_scoped`. A view-level `policy(...)` check controls presentation only; it never substitutes for controller authorization.

## Choose the right policy record

- Authorize an Active Record instance for record operations.
- Authorize the class for collection actions such as `index`.
- Use a headless symbol for singleton capabilities such as the dashboard or settings.
- Use a dedicated operation policy when the permission is about a domain command rather than generic CRUD. Pass `policy_class:` explicitly from the controller.

Keep policy inputs to `user` and `record`. If a rule appears to require unrelated request context, first select a better domain record.

## Compose existing authority

When access to a parent resource is membership-based:

- Member access grants visibility.
- Owner or admin access grants parent-resource administration.
- Owner access grants destructive owner-only operations.
- The owner membership is immutable; policies must not offer transitions that the model rejects.

When a child resource derives permission from its parent, delegate to the owning policy instead of reimplementing the membership query. Keep small intent-revealing ownership, membership, and administration predicates private.

Do not confuse creator ownership with membership in a shared parent resource. Preserve those distinct authorization dimensions unless the product behavior is intentionally changed across policy, controller, model, and tests.

## Build safe scopes

- Return an `ActiveRecord::Relation`, not an array.
- Express visibility in SQL with joins, subqueries, `or`, and `distinct`; do not load records and filter in Ruby.
- Accept a class or relation so callers may scope through a parent resource first.
- Reuse another policy scope when visibility is derived from it.
- Make scope and predicate agree. A record obtainable from a scope should pass its corresponding visibility predicate.

## Keep authorization simple

- Add the smallest rule that expresses the product permission. Compose existing policies and scopes instead of introducing a role engine, permission DSL, or speculative capability layer.
- Keep each decision in one policy and each visibility query in one scope. Do not scatter the same membership logic through controllers, views, models, and SQL fragments.
- Test only meaningful role, ownership, lifecycle, and scope boundaries. Do not generate a Cartesian matrix of cases that merely repeats inherited predicates or Pundit behavior.
- Do not log routine allows, denials, policy inputs, or request parameters. Add security-event logging only for an explicit operational requirement, at one established boundary, with safe minimal context.

## Test the matrix

Test the changed permission with an allowed and denied case, then add only the owner/admin/member,
personal/shared, lifecycle, or scope distinction that materially changes that rule. Test actual
boundary conditions; do not enumerate unaffected roles or merely restate method names.
