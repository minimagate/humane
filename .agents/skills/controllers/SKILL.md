---
name: controllers
description: Implement or change Rails controllers, request flows, strong parameters, nested resource loading, redirects, or Turbo responses. Use for controller actions and request boundaries; use authorization for policy decisions.
---

# Controllers

Keep controllers as request coordinators. Put domain transitions, execution logic, and reusable validation in models or the existing namespaced domain objects under `app/models/`.

## Trace the request boundary

Before editing, read `config/routes.rb`, the target controller, its policy, the relevant model method, and the nearest controller test. For nested or namespaced routes, also read the relevant base controller.

Preserve these application-wide invariants:

- `ApplicationController` supplies authentication, Pundit, modern-browser enforcement, navigation helpers, `verify_authorized`, and `verify_policy_scoped` for every `index` action.
- Authenticated actions authorize a record, class, or headless symbol. An `index` action both authorizes its class or collection contract and calls `policy_scope`.
- Unauthenticated authentication and OAuth endpoints opt out explicitly. Do not broaden a skip to make a new action pass.
- Namespaced controllers inherit from their established base controller, use its parent-resource context, and load nested records through that parent whenever an association exists.

## Shape actions consistently

- Use conventional REST actions. A state-changing verb that is not CRUD belongs to a small operation resource controller, not a custom action on an already broad resource controller.
- Load repeated member records in a private callback. Scope collection and member lookup through the authorized relation or parent association.
- Prefer `params.expect(resource: [...])` in a private parameter method. Describe nested arrays and hashes explicitly; never use `permit!` or an open-ended hash for model assignment.
- On valid form submissions, redirect to the canonical resource and use a short notice when confirmation helps. On invalid submissions, render the form with `status: :unprocessable_entity` so model errors remain available.
- Use bang persistence when failure is exceptional or already handled by a surrounding rescue/transaction. Use conditional `save` or `update` when the action must render validation errors.
- Keep eager loading next to the query that feeds the view. Add only associations the view actually traverses.
- Return the smallest response the interaction needs: redirect for ordinary HTML flows, `head :no_content` for autosave endpoints, or the existing Turbo Stream template/partial for in-place updates.

## Preserve domain and security boundaries

Do not duplicate lifecycle checks in controllers. Authorize the requested operation, then call the corresponding model command.

Route nesting is not authorization. Confirm that a nested child belongs to the loaded parent even when its policy would otherwise allow the current user to see it through another parent.

## Keep request code lean

- Implement the smallest conventional action. Do not add a service, command, responder, form object, or controller concern for logic that is clear and single-use at this boundary.
- Keep actions straight-line and readable. Move reusable domain decisions to the existing model or namespace instead of accumulating condition trees, callbacks, and duplicated branches across controllers.
- Add only request tests that prove the changed authentication, authorization, persistence, job, or response contract. Do not test Rails routing/rendering mechanics or duplicate model and policy coverage.
- Do not dump params, sessions, records, or responses to logs, and remove temporary debug output. Let an owned domain or external-failure boundary log an actionable failure once rather than logging it again in the controller.

## Verify

Add or update an `ActionDispatch::IntegrationTest` for authentication, authorization, response status or redirect, persistence, jobs, and side effects. Do not assert rendered HTML, selectors, text, partials, or CSS classes. Run the narrow controller test first.
