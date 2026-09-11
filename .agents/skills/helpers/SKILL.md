---
name: helpers
description: Create or revise Rails view helpers for formatting, tags, links, and small presentation decisions. Use when reusable display logic does not own a full visual structure; use frontend for templates, partials, components, or browser behavior.
---

# Helpers

Keep helpers small, deterministic, and presentation-only. A helper should make a template easier to read without becoming a hidden controller or domain layer.

## Choose the right owner

- Keep controller-specific helpers in the matching helper module. Put a helper in `ApplicationHelper` only when it is genuinely application-wide.
- Use a partial or component when the abstraction owns meaningful markup structure, slots, or several coordinated elements.
- Keep domain calculations and state transitions on models or domain objects. Helpers may translate domain state into labels or tags, but must not define the state itself.
- Do not query the database, mutate records, enqueue jobs, or make network calls from a helper.

## Build safe markup

- Prefer Rails tag helpers, `safe_join`, and built-in formatting helpers over string-built HTML.
- Rely on Rails escaping. Never mark user-controlled or assembled strings as `html_safe`; sanitize only with an explicit allowlist when rich content is a real requirement.
- Use generated route helpers instead of concatenating URLs.
- Keep accessibility semantics in the generated markup: labels, names, roles, and text alternatives must remain explicit.

## Keep APIs obvious

- Accept the values the helper needs rather than reaching through controller instance variables or global state.
- Use names that describe the rendered meaning, not the implementation mechanism.
- Return one predictable kind of value. Avoid helpers that sometimes mutate a block, sometimes return markup, and sometimes return plain data.
- Keep option hashes narrow. Do not recreate a generic component framework inside a helper.

## Preserve formatting conventions

- Use Rails number, date, time, translation, and URL helpers so escaping and localization stay consistent.
- Keep user-facing strings in I18n when the application localizes copy.
- Do not use a helper to conceal repeated expensive work; prepare collections and eager loading before rendering.

## Keep the helper layer lean

- Add the smallest helper that makes the caller clearer. Do not create a helper DSL, presenter hierarchy, or option-heavy abstraction for one formatting rule.
- Keep each presentation decision in one owner. Do not duplicate it across helpers, partials, components, and model methods.
- Promote code to a shared helper only after independent callers need the same behavior; keep one-screen logic with that screen.
- Remove superseded helpers and call sites when consolidating behavior. Do not leave aliases or wrapper methods for hypothetical compatibility.
- Do not add helper logging, debug markup, temporary counters, or instrumentation. Presentation code must not become an operational logging boundary.

## Verify

Exercise the helper through the affected page in the browser, including empty values, long content, accessibility, and escaping-sensitive input. Follow the repository rule against new rendering, selector, DOM, or presentation tests; test any extracted non-presentation rule at its domain boundary instead.

Framework reference: [Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html).
