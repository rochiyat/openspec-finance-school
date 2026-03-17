## Why

The repository now supports billings and installment plans, but there is still no way to record money actually paid against those obligations. Payment entry is the first settlement workflow in the PRD, and it must exist before billing statuses, installment completion, parent billing visibility, and finance reporting can reflect real financial outcomes.

## What Changes

- Add payment entry requirements for creating, listing, and viewing payment records.
- Enforce payment settlement rules including `amount_paid <= remaining_amount`.
- Support payments against either a full billing or a specific installment item.
- Update billing status based on cumulative payment progress.
- Mark installment items paid when installment-targeted payments settle them.
- Add a basic frontend payment entry and settlement UI for authorized staff.

## Capabilities

### New Capabilities
- `payment-entry-and-settlement`: Record payment transactions, settle billing and installment balances, and expose payment history for authorized staff.

### Modified Capabilities

## Impact

- APIs: adds `GET /payments`, `POST /payments`, and `GET /payments/:id`.
- Backend modules: introduces or expands the `payments` module and integrates with `billings` and `installments`.
- Frontend: adds a payment entry screen for finance and superadmin.
- Delivery dependency: unblocks parent payment history visibility, confirmation notifications, and finance dashboard settlement metrics.
