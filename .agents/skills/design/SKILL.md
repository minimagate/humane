---
name: design
description: Design or visually refine any application page, component, interaction, or Tailwind styling. Use for all UI appearance work to keep the product compact, borderless, purposeful, consistent, and equally resolved in light and dark mode.
---

# Design

Design a precise technical workspace, not a generic generated dashboard. Every visual choice must improve hierarchy, comprehension, state awareness, or interaction.

## Reject UI slop

Do not introduce decorative dashboard tropes: oversized hero copy, huge empty spacing, gradient blobs, glass effects, gratuitous shadows, fake metrics, ornamental charts, random pills, status dots without meaning, “online” labels without operational value, or invented metadata.

Do not use eyebrow text. A small uppercase label above a heading is not hierarchy; write one clear heading instead. Uppercase remains acceptable only where the content itself is a functional compact label, such as a table column heading.

Tags and badges must encode a real state, type, format, count, filter, or action-relevant distinction. If removing one would not reduce comprehension, remove it.

## Build borderless surfaces

- Do not add hairline borders, divider grids, or outlined cards. Separate regions with surface color, spacing, grouping, and restrained typography.
- Preserve accessibility outlines and focus rings; they are interaction signals, not decoration.
- Reuse the existing menu frame and specialized controls when required by their component contract, but do not spread that treatment to ordinary cards.
- Use shadows only for true elevation such as an open popover. Ordinary cards and panels should remain flat.

Favor well-rounded cards and panels. Use the design system's named semantic radius tokens rather than arbitrary radii.

For nested rounded surfaces, preserve concentric corners:

`outer radius = inner radius + the visible padding between them`

Choose the named radius and padding pair that most closely satisfies this relationship. Apply the rule consistently on all four corners; do not place a sharply rounded inner card inside an almost equally rounded outer card.

## Keep scale fine and compact

- Use the established sans-serif typeface; use monospace only for code, JSON, logs, identifiers, and other technical data.
- Keep page headings at the existing title scale. Do not add display-sized text.
- Use the established body, label, and card text scales for ordinary content; use meta/caption sizes only for genuinely secondary information.
- Prefer medium or semibold hierarchy with good ink contrast over size inflation.
- Keep spacing deliberate and compact. Use small gaps and padding that support scanning; avoid large dead zones, excessive section margins, and roomy cards with little content.
- Keep copy widths readable without forcing sparse layouts.

## Preserve and extend the palette correctly

Start with the existing palette in the application's design-token source. Reuse established semantic surface, text, status, danger, and interaction utilities before adding anything.

When a new distinction genuinely needs color:

1. Add or extend a raw palette token.
2. Add a purpose-named semantic token.
3. Define light and dark values together with `light-dark(...)`.
4. Use the semantic utility in markup.

Never solve dark mode by scattering `dark:` overrides when one semantic token can express both themes. Do not assume a light surface maps to the same numeric shade in dark mode.

## Let technical purpose drive composition

Prioritize the information users need to operate the product: workflow order, current status, inputs and outputs, errors and logs, identity, ownership, timestamps, and available actions. Use progressive disclosure for dense execution detail, but keep the current state and next action visible.

Empty, loading, paused, failed, and completed states must be designed as deliberately as the default state. Color is supportive; pair it with text or accessible labels. Keep action placement stable and controls recognizable.

Preserve the existing palette and component language when editing a page. Add a new pattern only when established components cannot express the product need.

## Keep the design system lean

- Reuse the smallest existing visual pattern that communicates the requirement. Do not create a new design system, layout primitive, token family, or variant for one screen or hypothetical reuse.
- Give each visual role one clear treatment. Remove nested wrappers, competing hierarchies, and class or variant proliferation that makes the page harder to change.
- Verify only the affected flows and meaningful states in the browser. Do not add visual snapshots, DOM assertions, component tests, or exhaustive viewport/theme combinations to the automated suite.
- Cosmetic work never justifies console logging, debug output, telemetry, or new operational logs. Express state visibly; keep actual failure logging at the existing application boundary that owns the failure.

## Review before finishing

Inspect the actual page in both light and dark mode, at desktop and narrow widths. Check nested corner geometry, density, contrast, focus, hover, disabled states, long technical content, empty/error states, and whether every badge or decoration earns its place. If the result resembles a generic template before it resembles the product, simplify it.
