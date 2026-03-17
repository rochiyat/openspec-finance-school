## 1. Backend payment management

- [x] 1.1 Add `payments` repository and service support for creating, listing, and viewing payment records.
- [x] 1.2 Validate billing and installment targets through exported `BillingsService` and `InstallmentsService` access rather than direct repository access.
- [x] 1.3 Enforce remaining-balance rules, payment targeting rules, and settlement status updates for billings and installment items.
- [x] 1.4 Add `FINANCE` and `SUPERADMIN` guarded endpoints for `GET /payments`, `POST /payments`, and `GET /payments/:id` with structured errors.

## 2. Frontend payment administration UI

- [x] 2.1 Add an authorized payment management screen for listing payment records.
- [x] 2.2 Add payment entry controls for billing and installment-targeted payments wired to the new backend APIs.
- [x] 2.3 Add payment-detail UI and unauthorized or unavailable handling for users without `FINANCE` or `SUPERADMIN` role.

## 3. Verification

- [x] 3.1 Add backend tests for payment creation, listing, detail lookup, overpayment rejection, billing status updates, installment settlement updates, unauthenticated access, and forbidden unauthorized-role access.
- [x] 3.2 Add frontend or integration verification for payment management flows.
- [x] 3.3 Document the payment entry endpoints in Swagger and confirm the capability is ready for parent payment history, notifications, and dashboard dependencies.
