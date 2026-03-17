## Why

The repository now has students, parents, family mappings, and a billing type catalog, but it still cannot generate actual student billing records. The PRD requires billing as a core MVP capability, and downstream installment plans, payments, parent visibility, and finance operations all depend on billings existing as first-class records.

## What Changes

- Add billing record requirements for creating, listing, viewing, and bulk-creating billings.
- Define superadmin or finance-authorized administration flows for student billing records.
- Validate billing references to existing students and billing types, including installment eligibility derived from the billing type catalog.
- Establish billing status handling for `UNPAID`, `PARTIALLY_PAID`, `PAID`, and `OVERDUE`.
- Add a basic frontend management UI for billing record administration.

## Capabilities

### New Capabilities
- `billing-record-management`: Manage student billing records, including type linkage, due dates, totals, and initial status behavior.

### Modified Capabilities

## Impact

- APIs: adds `GET /billings`, `POST /billings`, `POST /billings/bulk-create`, and `GET /billings/:id`.
- Backend modules: introduces or expands the `billings` module and integrates with `students` and `billing-types`.
- Frontend: adds a billing management screen for authorized administration.
- Delivery dependency: unblocks installment plans, payment recording, parent billing visibility, and finance dashboards.
