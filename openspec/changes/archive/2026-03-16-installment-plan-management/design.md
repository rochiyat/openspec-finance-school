## Context

The codebase now supports billing creation, but every billing is still a single lump-sum obligation. The PRD defines `InstallmentPlan` and `InstallmentItem` as separate entities with their own due dates and statuses, so the next dependency after billing management is to introduce installment planning for billings whose billing type allows installments.

## Goals / Non-Goals

**Goals:**
- Let authorized staff create installment plans tied to existing billing records.
- Generate installment items with sequence numbers, due dates, amounts, and statuses.
- Enforce that installments can only be created for billings marked as installment-eligible.
- Provide a basic frontend screen for creating and viewing installment plans.

**Non-Goals:**
- Payment allocation across installments.
- Reminder scheduling or overdue notification delivery.
- Installment plan editing, rescheduling, or deletion.

## Decisions

### Decision: Implement a dedicated installments module with plan and item records
Installments are not just billing metadata; they have their own lifecycle and statuses. A dedicated module with plan and item data keeps installment behavior isolated from billing records while allowing future payment flows to reference installment items directly.

Alternative considered: storing installment details as embedded arrays on billing records only. This was rejected because it would make item-level status tracking and future payment linkage harder to evolve.

### Decision: Restrict installment management to `FINANCE` and `SUPERADMIN`
The PRD gives finance responsibility for managing installments, and superadmin remains the system-wide fallback operator. Reusing the same authorization shape as billing management keeps financial administration consistent across related capabilities.

Alternative considered: finance-only access. This was rejected because superadmin should still be able to verify and administer the full system.

### Decision: Derive installment eligibility from the linked billing record
The billing record already stores `installment_allowed` as a derived value from the billing type catalog, so the installment service should validate against the billing record rather than re-reading client-supplied assumptions. This keeps installment creation aligned with the billing setup that was already approved.

Alternative considered: letting the client force installment creation regardless of billing state. This was rejected because it would violate PRD business rules.

### Decision: Generate installment items evenly and initialize them as `UNPAID`
For MVP, each installment plan should generate a predictable sequence of installment items with incrementing `installment_no`, item due dates, equal per-item amounts, and initial status `UNPAID`. This gives payments a stable target later without introducing custom split logic yet.

Alternative considered: allowing arbitrary per-item amounts at creation time. This was rejected because it adds complexity before payment behavior exists.

## Risks / Trade-offs

- Equal-amount distribution may not fit every real-world billing case -> Mitigation: keep the first version simple and add custom plan editing later if needed.
- In-memory installment state will not survive restarts -> Mitigation: keep DTOs and service contracts aligned with later persistent storage.
- Future payment logic may need tighter coupling to item status rules -> Mitigation: keep installment items as first-class records now so payment integration has a clean path.
- Due date generation rules can become ambiguous -> Mitigation: require explicit plan start date and deterministic item creation order.

## Migration Plan

- Add backend `installments` module with plan creation and detail APIs.
- Reuse `BillingsService` and auth session identity for validation and access control.
- Add frontend installment planning UI for finance and superadmin.
- Use this capability as the prerequisite for payment allocation and installment overdue handling.

## Open Questions

- None for MVP; the PRD is specific enough to implement installment plan creation and detail viewing directly.
