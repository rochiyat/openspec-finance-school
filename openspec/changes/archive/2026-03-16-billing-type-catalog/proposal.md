## Why

Billing creation cannot be standardized until the system has a controlled catalog of billing types. The PRD explicitly requires superadmin to manage `BillingType`, and downstream billing and installment behavior depends on fields like `code`, `recurrence_type`, and `is_installment_allowed` being defined consistently.

## What Changes

- Add billing type catalog requirements for creating, listing, viewing, and updating billing types.
- Define superadmin-only administration flows for the `BillingType` master data.
- Enforce standard billing type fields: `code`, `name`, `is_installment_allowed`, and `recurrence_type`.
- Establish the core billing type set for MVP, including `UANG_MASUK`, `SPP`, and `UANG_TAHUNAN`.
- Add a basic frontend management UI for billing type administration.

## Capabilities

### New Capabilities
- `billing-type-catalog`: Manage billing type master data used by billings and installment eligibility rules.

### Modified Capabilities

## Impact

- APIs: adds billing type administration endpoints for master data setup.
- Backend modules: introduces or expands the `billing-types` module.
- Frontend: adds a basic billing type management screen for superadmin.
- Delivery dependency: unblocks billing creation, recurrence semantics, and installment eligibility checks.
