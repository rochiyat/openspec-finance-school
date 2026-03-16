## 1. Backend billing management

- [x] 1.1 Add `billings` repository and service support for creating, listing, viewing, and bulk-creating billing records.
- [x] 1.2 Validate student and billing type references through exported `StudentsService` and `BillingTypesService` access rather than direct repository access.
- [x] 1.3 Derive `installment_allowed` from the selected billing type and initialize new billings with `UNPAID` status.
- [x] 1.4 Add `FINANCE` and `SUPERADMIN` guarded endpoints for `GET /billings`, `POST /billings`, `POST /billings/bulk-create`, and `GET /billings/:id` with structured errors.

## 2. Frontend billing administration UI

- [x] 2.1 Add an authorized billing management screen for listing billing records.
- [x] 2.2 Add single-create and bulk-create billing controls wired to the new backend APIs.
- [x] 2.3 Add unauthorized or unavailable UI handling for users without `FINANCE` or `SUPERADMIN` role.

## 3. Verification

- [x] 3.1 Add backend tests for billing creation, listing, detail lookup, bulk-create flow, invalid references, derived installment eligibility, initial status handling, unauthenticated access, and forbidden unauthorized-role access.
- [x] 3.2 Add frontend or integration verification for billing management flows.
- [x] 3.3 Document the billing record management endpoints in Swagger and confirm the capability is ready for installment planning and payment dependencies.
