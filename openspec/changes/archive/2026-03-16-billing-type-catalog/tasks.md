## 1. Backend billing type management

- [x] 1.1 Add `billing-types` repository and service support for creating, listing, viewing, and updating billing types.
- [x] 1.2 Enforce unique billing type codes, recurrence type validation, and installment-eligibility fields in service logic.
- [x] 1.3 Seed the standard MVP billing types `UANG_MASUK`, `SPP`, and `UANG_TAHUNAN` during catalog initialization.
- [x] 1.4 Add superadmin-only billing type endpoints with validation and structured errors.

## 2. Frontend billing type administration UI

- [x] 2.1 Add a superadmin screen for listing billing type records.
- [x] 2.2 Add create and update billing type controls wired to the new backend APIs.
- [x] 2.3 Add non-superadmin unauthorized or unavailable UI handling for the billing type management screen.

## 3. Verification

- [x] 3.1 Add backend tests for billing type seeding, creation, listing, detail lookup, update flow, duplicate-code rejection, unauthenticated access, and forbidden non-superadmin access.
- [x] 3.2 Add frontend or integration verification for billing type management flows.
- [x] 3.3 Document the billing type catalog endpoints in Swagger and confirm the capability is ready for billing creation and installment eligibility dependencies.
