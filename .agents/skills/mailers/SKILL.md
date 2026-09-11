---
name: mailers
description: Implement or revise Rails Action Mailer classes, delivery workflows, multipart templates, previews, and mailer tests. Use for transactional email; keep domain decisions outside mailers and use jobs for non-request delivery.
---

# Mailers

Keep mailers as message builders. The domain layer decides whether a message should be sent and to whom; the mailer turns explicit inputs into a delivery.

## Define a clear delivery contract

- Give each mailer action one purpose and explicit inputs. Avoid inferring recipients or business state from broad global context.
- Set `to`, `from`, `reply_to`, subject, and any delivery headers intentionally. Keep environment-specific hosts and sender defaults in configuration.
- Use generated URL helpers with an explicit host. Email clients cannot use relative URLs.
- Do not send mail from model save callbacks. Coordinate delivery after the relevant transaction commits.

## Keep rendering maintainable

- Provide text and HTML parts when both are part of the product contract. Keep shared structure in mailer layouts or focused partials.
- Reuse the application's view helpers for formatting, escaping, and localization. Do not duplicate domain calculations in templates.
- Keep user-controlled content escaped. Treat attachments, filenames, and custom headers as untrusted input.
- Use previews for manual inspection of meaningful states without sending real mail.

## Deliver asynchronously

- Prefer `deliver_later` for request-triggered mail unless the caller must synchronously observe delivery.
- Pass durable, minimal parameters. Re-fetch current records and handle missing recipients or obsolete state deliberately.
- Preserve locale and time-zone context when content depends on them.
- Make the upstream command idempotent when retries could enqueue or deliver duplicate messages.

## Protect privacy and operations

- Do not place secrets or unnecessary personal data in subjects, queue arguments, headers, or logs.
- Use BCC and bulk delivery carefully; never expose one recipient's address to another unintentionally.
- Let delivery failures reach the job adapter and error reporter. Retry transient provider failures through the job boundary rather than swallowing them in the mailer.

## Keep mailer code lean

- Build the smallest message that fulfills one delivery purpose. Do not create a mailer DSL, presenter layer, or custom delivery wrapper for a single message.
- Keep recipient selection, delivery eligibility, and idempotency in their existing domain owner; keep envelope and rendering choices in the mailer.
- Share layouts, partials, and helpers only when multiple real messages use them. Remove obsolete templates and actions when replacing a delivery path.
- Add only tests for the delivery contract and domain-visible effects. Do not duplicate job, model, localization, or rendering coverage.
- Do not add delivery-success chatter, rendered-body logging, or temporary mail diagnostics. Report an actionable provider failure once through the job or delivery boundary.

## Verify

Test the delivery contract: recipients, sender, subject, selected headers, attachments when relevant, enqueueing, and domain-visible side effects. Do not add assertions for rendered HTML, selectors, CSS classes, or visual layout. Inspect representative messages through previews in both text and HTML forms.

Framework reference: [Action Mailer Basics](https://guides.rubyonrails.org/action_mailer_basics.html).
