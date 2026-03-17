## Context

The codebase now supports billings and installment plans, but money cannot yet be posted against those obligations. The next transactional step in the PRD is payment entry, which must update billing settlement state, optionally settle installment items, and preserve an auditable payment history for finance operations.

## Goals / Non-Goals

**Goals:**
- Let `FINANCE` and `SUPERADMIN` users create, list, and view payment records.
- Support payments against either a billing directly or a specific installment item.
- Enforce `amount_paid <= remaining_amount` before recording a payment.
- Update billing status to `UNPAID`, `PARTIALLY_PAID`, or `PAID` based on cumulative settlement.
- Mark installment items paid when installment-targeted payments fully settle them.
- Provide a basic frontend payment entry and payment-history interface.

**Non-Goals:**
- Online payment gateway integration.
- Refunds, voids, or chargebacks.
- Notification dispatch after payment confirmation.
- Advanced reconciliation or accounting journal generation.

## Decisions

### Decision: Implement a dedicated payments module with settlement logic in the service layer
Payments are the authoritative settlement transactions for billings and installment items, so they should live in their own module with explicit service-layer rules. This keeps payment-side validation and status transitions centralized rather than scattering them across billings or installments.

Alternative considered: embedding payment entry inside the billings module. This was rejected because payments have their own entity shape, listing requirements, and later notification side effects.

### Decision: Allow payments to target either a billing or an installment item
The PRD includes both `billing_id` and `installment_item_id` on the payment entity, so the API should accept either form while validating that the target belongs to the same student context. This keeps the MVP aligned with both lump-sum billing settlement and installment-based settlement.

Alternative considered: forcing every payment through installment items only. This was rejected because some billings are not installment-based and still need direct payment entry.

### Decision: Compute remaining amount from existing payments at write time
The system should calculate remaining balance from the billing total and previously recorded payments, rather than trusting a client-supplied remaining amount. This ensures the `amount_paid <= remaining_amount` business rule is enforced server-side.

Alternative considered: sending remaining balance from the client for validation. This was rejected because client state can be stale or tampered with.

### Decision: Update billing and installment statuses immediately after payment creation
Payment entry should be the point where settlement state changes. After each payment, the service should recompute billing progress and mark related installment items as `PAID` when their outstanding amount reaches zero.

Alternative considered: deferring status updates to a background job. This was rejected because later UI and reporting features need immediate consistency after payment entry.

### Decision: Keep payment methods and reference numbers flexible strings for MVP
The PRD requires `payment_method` and `reference_no` but does not constrain them to a fixed enum. For MVP, keeping them as validated strings avoids premature coupling while still recording essential payment metadata.

Alternative considered: defining a strict payment-method enum immediately. This was rejected because the PRD does not require a fixed method list yet.

## Risks / Trade-offs

- In-memory payment state will not survive restarts -> Mitigation: keep DTOs and service contracts ready for later persistence migration.
- Settlement logic spans payments, billings, and installments -> Mitigation: centralize it in `PaymentsService` and use exported services for reads.
- Direct billing payments and installment payments can overlap in edge cases -> Mitigation: validate targets carefully and reject impossible combinations.
- Without refunds, incorrect entries must be corrected manually -> Mitigation: keep payment records explicit and defer reversal workflows to a later change.

## Migration Plan

- Add backend `payments` module with create, list, and detail APIs.
- Reuse `BillingsService` and `InstallmentsService` for target validation and settlement updates.
- Add frontend payment entry UI for finance and superadmin.
- Use this capability as the prerequisite for payment notifications, parent payment history, and settlement dashboards.

## Open Questions

- None for MVP; the PRD provides enough structure to implement payment entry and settlement behavior directly.
