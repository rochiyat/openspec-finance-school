# Proposal: Report Export

## Purpose
Build a reporting and export feature that allows Finance Staff (`FINANCE`) and Superadmins (`SUPERADMIN`) to generate and download financial transaction reports. This feature provides stakeholders with the ability to export payments and billings data (e.g., in CSV format) for offline analysis, reconciliation, and integration with external accounting tools.

## Motivation
While the system provides on-screen dashboards and summaries, finance operations often require downloading raw data for specific periods to perform detailed reconciliation or to share with external auditors. Currently, there is no way to export financial data from the system.

## Scope
- **Backend**:
  - Implement a new `ReportsModule` with an endpoint `GET /api/reports/export`.
  - Accept query parameters for filtering: `startDate`, `endDate`, and `type` (e.g., `PAYMENTS`, `BILLINGS`).
  - Generate a CSV format response containing the relevant records.
  - Restrict access to `FINANCE` and `SUPERADMIN` roles.
- **Frontend**:
  - Add a "Download Report" button/form on the Finance Dashboard and Superadmin Dashboard.
  - Implement date range pickers and report type selectors.
  - Handle the file download functionality on the client side.

## Affected Components
- `backend/src/modules/reports/` (new)
- `backend/src/app.module.ts`
- `frontend/src/pages/FinanceDashboardPage.tsx`
- `frontend/src/pages/SuperadminDashboardPage.tsx`
- `frontend/src/lib/auth.ts` (new API helper)

## Dependencies
- `payments` module - source of payment records.
- `billings` module - source of billing records.

## Success Criteria
- [ ] Users can select a date range and report type on the frontend.
- [ ] Clicking export triggers a download of a correctly formatted CSV file.
- [ ] The CSV file includes proper headers and accurate data based on the selected filters.
- [ ] Secure access: only `FINANCE` and `SUPERADMIN` can access the export endpoint.
- [ ] Unauthorized users cannot export reports.
