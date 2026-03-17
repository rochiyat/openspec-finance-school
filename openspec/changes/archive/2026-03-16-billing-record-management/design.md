## Context

The codebase now has authenticated users, academic structure, students, parents, family mappings, and a seeded billing type catalog, but there are still no actual billing records tied to students. Billing is the first transactional financial data in the PRD, so this change needs to introduce billings as durable records that reference students and billing types while staying compatible with later installment, payment, notification, and dashboard flows.

## Goals / Non-Goals

**Goals:**
- Let authorized staff create, list, view, and bulk-create billing records.
- Validate billings against existing students and billing types.
- Persist core billing fields: `student_id`, `billing_type_id`, `title`, `total_amount`, `due_date`, `installment_allowed`, `status`, `created_by`, and `created_at`.
- Initialize billing status using PRD values `UNPAID`, `PARTIALLY_PAID`, `PAID`, and `OVERDUE`.
- Provide a basic frontend administration interface for billing management.

**Non-Goals:**
- Installment plan creation or payment posting.
- Automatic overdue scheduling or reminder delivery.
- Reports, exports, or dashboard aggregation.

## Decisions

### Decision: Implement a dedicated billings module with repository and service ownership
Billing records are the authoritative transactional layer between master data and later payments or installments, so they should live in their own module. This keeps billing lifecycle rules isolated from billing types, students, and payments while allowing those modules to remain authoritative for their own data.

Alternative considered: embedding billing arrays under students. This was rejected because it would tightly couple transaction history to student records and complicate later payment/installment flows.

### Decision: Allow finance and superadmin to manage billing records
The PRD explicitly gives finance responsibility to create billings, while superadmin manages overall system configuration. For MVP, both roles should be allowed to create and view billing records so seeded superadmin sessions can still test the full flow while finance remains the intended operator.

Alternative considered: superadmin-only billing management. This was rejected because it conflicts with the PRD role definition for finance.

### Decision: Derive installment eligibility from the selected billing type by default
The billing record has its own `installment_allowed` field, but the billing type catalog already defines whether installments are allowed. The service should set billing installment eligibility from the linked billing type to keep configuration consistent and avoid client-side drift.

Alternative considered: accepting arbitrary installment flags from the client. This was rejected because it would let billing records violate catalog rules.

### Decision: Support bulk-create as repeated single-create semantics with shared validation
`POST /billings/bulk-create` should reuse the same service validation used for single billing creation so status, references, and derived fields stay consistent. This gives finance a practical way to generate many billings without introducing a separate rule set.

Alternative considered: leaving bulk-create for a later phase. This was rejected because the PRD explicitly lists the endpoint in MVP APIs.

### Decision: Initialize new billings as `UNPAID` and reserve other status transitions for later flows
Until payments and overdue automation are implemented, newly created billings should start as `UNPAID`. `PARTIALLY_PAID`, `PAID`, and `OVERDUE` remain valid persisted statuses, but this change should not attempt to infer them beyond creation-time defaults.

Alternative considered: calculating overdue at creation time from due date. This was rejected because overdue handling is better centralized when payment and scheduling logic exist.

## Risks / Trade-offs

- In-memory billing state will not survive restarts -> Mitigation: keep DTOs and service contracts database-ready for later persistence.
- Bulk-create can amplify bad input -> Mitigation: reuse single-create validation and reject invalid items explicitly.
- Finance and superadmin dual access broadens authorization surface -> Mitigation: keep endpoints guarded by explicit role checks and consistent response contracts.
- Later payment logic may require more billing fields -> Mitigation: keep the current model additive and aligned with the PRD entity shape.

## Migration Plan

- Add backend `billings` module with single-create, bulk-create, list, and detail APIs.
- Reuse `StudentsService`, `BillingTypesService`, and auth session identity for validation and `created_by` attribution.
- Add frontend billing management UI for finance and superadmin.
- Use this capability as the prerequisite for installment planning and payment recording.

## Open Questions

- None for MVP; the PRD gives enough structure to implement billing creation and read flows directly.
