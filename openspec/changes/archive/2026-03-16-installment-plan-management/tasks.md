## 1. Backend installment management

- [x] 1.1 Add `installments` repository and service support for creating installment plans and retrieving plan details with generated installment items.
- [x] 1.2 Validate linked billings through exported `BillingsService` access rather than direct repository access.
- [x] 1.3 Enforce installment-eligibility rules, equal item generation, sequential installment numbers, and initial `UNPAID` item statuses in service logic.
- [x] 1.4 Add `FINANCE` and `SUPERADMIN` guarded endpoints for `POST /installments/plans` and `GET /installments/plans/:id` with structured errors.

## 2. Frontend installment administration UI

- [x] 2.1 Add an authorized installment management screen for listing or viewing installment plans.
- [x] 2.2 Add installment-plan creation controls wired to the new backend APIs.
- [x] 2.3 Add plan-detail UI for generated installment items and unauthorized or unavailable handling for users without `FINANCE` or `SUPERADMIN` role.

## 3. Verification

- [x] 3.1 Add backend tests for installment plan creation, generated items, installment-eligibility rejection, plan detail lookup, unauthenticated access, and forbidden unauthorized-role access.
- [x] 3.2 Add frontend or integration verification for installment management flows.
- [x] 3.3 Document the installment plan endpoints in Swagger and confirm the capability is ready for payment allocation and overdue installment dependencies.
