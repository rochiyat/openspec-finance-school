## Context

The codebase already has the core master-data foundation for users, academic structure, students, parents, and family mapping, but billing still lacks its shared type catalog. Before billings and installments can be implemented cleanly, the system needs a dedicated billing type source that captures code identity, recurrence semantics, and installment eligibility in one place under superadmin control.

## Goals / Non-Goals

**Goals:**
- Let superadmin create, list, view, and update billing types.
- Store stable billing type fields: `code`, `name`, `is_installment_allowed`, and `recurrence_type`.
- Seed or establish the core MVP billing type set: `UANG_MASUK`, `SPP`, and `UANG_TAHUNAN`.
- Provide a basic frontend administration interface for billing type management.

**Non-Goals:**
- Billing record generation or student-specific billing assignment.
- Recurring billing automation or scheduler logic.
- Installment plan creation itself; this change only defines the catalog field used to allow or deny installments.

## Decisions

### Decision: Implement a dedicated billing-types module with its own repository and service
Billing types are shared master data referenced by later billing and installment flows, so they should live in a dedicated module rather than being embedded in billing records. This keeps the catalog authoritative and reusable across downstream financial features.

Alternative considered: storing billing type attributes directly on each billing. This was rejected because it would duplicate configuration and weaken downstream consistency.

### Decision: Restrict billing type administration to superadmin-only endpoints
The PRD assigns billing type management to superadmin, so the capability should reuse the established superadmin-only authorization pattern already used for other master data. This keeps access control simple and aligned with the product rules.

Alternative considered: allowing finance staff to manage billing types. This was rejected because the PRD reserves that configuration responsibility for superadmin.

### Decision: Use a constrained recurrence type enum aligned with PRD examples
For MVP, recurrence should map cleanly to the three catalog examples already present in the PRD: one-time (`UANG_MASUK`), monthly (`SPP`), and yearly (`UANG_TAHUNAN`). A simple enum such as `ONE_TIME`, `MONTHLY`, and `YEARLY` keeps the data model explicit without introducing scheduling behavior yet.

Alternative considered: storing free-text recurrence values. This was rejected because it would make downstream billing logic harder to validate and standardize.

### Decision: Enforce unique billing type codes and seed the core types early
The billing type `code` is the durable identifier used by future features and should therefore be unique. The three PRD examples should exist as the starting catalog so downstream billing work can begin without additional setup friction.

Alternative considered: leaving all type creation manual and unseeded. This was rejected because every environment would then require repeated bootstrap before billings could be tested.

## Risks / Trade-offs

- In-memory catalog state will not survive restarts -> Mitigation: keep DTOs and service contracts database-ready for later persistence.
- Seeded billing types can diverge from future production setup -> Mitigation: keep the seed minimal and let superadmin update non-code fields if needed.
- Recurrence enum choices may need expansion later -> Mitigation: keep the enum additive and scoped to current PRD examples.
- Future billing logic may depend heavily on code semantics -> Mitigation: treat `code` as a unique stable identifier from the beginning.

## Migration Plan

- Add backend `billing-types` module with superadmin-only CRUD-lite APIs.
- Seed the core MVP billing types during module initialization or repository bootstrap.
- Add frontend billing type management UI alongside the existing superadmin master-data screens.
- Use this catalog as the prerequisite for billing creation and installment eligibility enforcement.

## Open Questions

- None for MVP; the PRD gives enough structure to implement the billing type catalog directly.
