## Why

Parents need a way to view their children's billing records, installment plans, and payment history without having to contact school staff. This self-service capability improves transparency and reduces administrative overhead for the finance team.

## What Changes

- Add endpoints for authenticated parents to query billing records for their linked children.
- Add endpoints for authenticated parents to query installment plans for their linked children.
- Add endpoints for authenticated parents to query payment history for their linked children.
- Create frontend interfaces for parents to view this data.

## Capabilities

### New Capabilities

- `parent-billing-visibility`: Allows authenticated parents to view billing records, installment plans, and payment history for their linked children.

### Modified Capabilities

- `billing-record-management`: Extend read access to allow parents to view billing records for their linked children.
- `installment-plan-management`: Extend read access to allow parents to view installment plans for their linked children.
- `payment-entry-and-settlement`: Extend read access to allow parents to view payment records for their linked children.

## Impact

- **Backend**: Update authorization layers in billing, installment, and payment modules to allow `PARENT` role access if the target student is linked to the parent. Add new controllers/endpoints tailored for parent queries.
- **Frontend**: Create a parent dashboard or billing view module containing student billing details.
- **Dependencies**: Relies on `student-parent-mapping` to determine which students a parent can query.
