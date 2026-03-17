## Why

Billing records now exist, but the system still cannot split eligible billings into tracked installments. The PRD requires installment plans and installment items before payment allocation and overdue installment management can work, so this capability needs to follow billing creation immediately.

## What Changes

- Add installment plan requirements for creating and viewing installment plans tied to a billing.
- Add installment item generation requirements with per-installment due dates, amounts, and statuses.
- Enforce that installment plans can only be created for billings whose billing type allows installments.
- Add a basic frontend management UI for installment plan creation and detail viewing.

## Capabilities

### New Capabilities
- `installment-plan-management`: Manage installment plans and generated installment items for eligible billing records.

### Modified Capabilities

## Impact

- APIs: adds `POST /installments/plans` and `GET /installments/plans/:id`.
- Backend modules: introduces or expands the `installments` module and validates linked billings.
- Frontend: adds a basic installment management screen for authorized staff.
- Delivery dependency: unblocks installment-aware payment posting, reminder flows, and overdue installment tracking.
