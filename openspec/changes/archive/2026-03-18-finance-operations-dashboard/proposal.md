# Proposal: Finance Operations Dashboard

## Purpose
Build a dedicated dashboard for Finance Staff (`FINANCE` role) that provides a real-time operational summary of the school's financial state. The dashboard allows finance staff to quickly assess collection health, identify delinquent students, and monitor installment activity without running manual queries or spreadsheet reports.

## Motivation
Finance staff currently have no aggregated view of the financial system. All data exists in the billing, payment, and installment modules, but there is no single screen that summarizes:
- How much revenue has been collected vs. how much is outstanding
- Which students are overdue or have not paid at all
- How many active installment items are in progress

Providing this view reduces manual effort, speeds up follow-up, and aligns with the PRD Finance Dashboard requirements (`GET /dashboard/finance`).

## Scope
- **Backend**:
  - Implement `GET /api/finance-dashboard/overview` in a new `FinanceDashboardModule`.
  - Aggregate across billings and payments to produce: `totalBilled`, `totalCollected`, `outstandingReceivable`, `overdueCount`, `unpaidCount`, `activeInstallmentCount`.
  - Include a `delinquentStudents` list (students with at least one `OVERDUE` billing).
  - Restrict access to users with the `FINANCE` or `SUPERADMIN` role.
- **Frontend**:
  - Implement the Finance Dashboard page at route `/dashboard-keuangan`.
  - Display summary stat cards and a delinquent student list table.
  - Gate navigation to this page by role.

## Affected Components
- `backend/src/modules/finance-dashboard/` (new)
- `backend/src/app.module.ts`
- `frontend/src/pages/FinanceDashboardPage.tsx` (new)
- `frontend/src/routes/AppRouter.tsx`
- `frontend/src/lib/auth.ts` (new API helper)

## Dependencies
- `billings` module — source of billing totals and statuses
- `payments` module — source of collected amounts
- `installments` module — source of active installment item count
- `students` module — for resolving student names in delinquent list

## Success Criteria
- [x] Finance staff can log in and see a summary dashboard in under 3 seconds.
- [x] Summary shows total billed, total collected, outstanding receivable, overdue count, unpaid count, and active installment count.
- [x] Delinquent student list shows each overdue student's NIS, name, and count of overdue billings.
- [x] Users without `FINANCE` or `SUPERADMIN` role cannot access the endpoint or the page.
- [x] Unit tests cover the aggregation logic in the service.
