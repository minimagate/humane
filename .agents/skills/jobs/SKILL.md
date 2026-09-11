---
name: jobs
description: Implement or revise Rails Active Job workflows, queue selection, retries, idempotency, concurrency handling, and job tests. Use for work that runs outside the request; keep business transitions in models or domain objects.
---

# Jobs

Treat a job as a durable coordinator that may run later, more than once, and after surrounding application state has changed.

## Keep the payload durable

- Pass small serializable values or records supported by GlobalID. Do not enqueue open connections, relations, request objects, or large mutable payloads.
- Pass identifiers when the job must handle a record being deleted or replaced explicitly. Re-fetch current state in `perform`.
- Treat job arguments as potentially visible in queue administration and logs; do not include secrets or unnecessary personal data.
- Version or normalize long-lived payloads when queued jobs may survive a deployment that changes their shape.

## Make execution safe

- Make externally visible operations idempotent. A retry must not duplicate children, charges, messages, or other side effects.
- Re-check lifecycle preconditions when the job runs. Do not assume state remains as it was when enqueued.
- Keep transactions around database state transitions, not network calls. Record an idempotency key or claimed state before invoking an external boundary when appropriate.
- Enqueue work only after the state it depends on commits. Use `after_commit` or an equivalent transaction-aware boundary.

## Handle failure deliberately

- Let unexpected errors reach the queue adapter and error reporter. Do not blanket-rescue and mark failed work successful.
- Configure `retry_on` only for transient failures, with bounded attempts and suitable backoff. Use `discard_on` only when dropping the job is an explicit product decision.
- Separate permanent validation or authorization failure from transient provider failure.
- Log one actionable failure at the boundary that owns it, with identifiers and safe context rather than full payloads.

## Keep queues operable

- Choose queue names from operational priority and isolation needs. Do not create a queue per class without a scheduling reason.
- Keep jobs short enough for worker shutdown and retry behavior. Split independent units of work when that improves recovery, not merely to create more classes.
- Use bulk enqueue APIs for large independent sets when supported. Avoid enqueueing unbounded numbers of jobs inside one request.
- Add concurrency controls only for a demonstrated collision and ensure their keys match the business invariant.

## Keep job code lean

- Give `perform` one orchestration responsibility and delegate the domain transition to its existing owner. Do not recreate business rules in the job.
- Use the smallest job and queue structure that meets the operational need. Do not add wrapper jobs, job hierarchies, middleware, or queue abstractions for one workflow.
- Keep each retry, claim, and idempotency rule in one place. Remove obsolete execution paths when a job replaces synchronous or legacy work.
- Add only tests for delegation, resulting state, idempotency, and meaningful failure behavior. Do not duplicate model tests or Active Job internals.
- Do not emit per-record progress chatter or duplicate an error already reported by the owned external boundary. Remove temporary instrumentation before finishing.

## Verify

Test delegation, resulting application state, idempotency, and meaningful retry or discard behavior with the configured Active Job test helpers. Do not test adapter internals. Run the narrow job test and, when relevant, exercise the configured development queue adapter end to end.

Framework reference: [Active Job Basics](https://guides.rubyonrails.org/active_job_basics.html).
