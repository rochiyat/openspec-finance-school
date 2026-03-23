# Design: Report Export

## Architecture
We will introduce a new `ReportsModule` in the backend dedicated to generating exportable data formats. This keeps the core transactional modules (`Payments`, `Billings`) focused on their primary domain logic, while the reporting module orchestrates data retrieval and formatting.

## API Endpoints

### `GET /api/reports/export`
- **Query Parameters**:
  - `type` (string): `PAYMENTS` or `BILLINGS` (Required)
  - `startDate` (ISO string): Start of the reporting period (Optional)
  - `endDate` (ISO string): End of the reporting period (Optional)
- **Response**:
  - Header: `Content-Type: text/csv`
  - Header: `Content-Disposition: attachment; filename="..."`
  - Body: CSV formatted string.

## Data Mapping

### Payments CSV Output Fields
- `Payment ID`, `Date`, `Amount`, `Payment Method`, `Reference`, `Student NIS`, `Student Name`, `Billing Type`

### Billings CSV Output Fields
- `Billing ID`, `Date`, `Amount`, `Status`, `Student NIS`, `Student Name`, `Billing Type`, `Due Date`

## Frontend Design
- Integrate a "Report Export" section into the existing `FinanceDashboardPage.tsx` and `SuperadminDashboardPage.tsx`.
- Include a form with:
  - Report Type (Dropdown: Payments, Billings)
  - Start Date (Date picker)
  - End Date (Date picker)
  - "Export to CSV" button.
- The button will make a request to the backend with the authentication token, receive the blob wrapper, and trigger a file download using `URL.createObjectURL(blob)` and an invisible `<a>` element.

## Security
- The endpoint will use `BearerAuthGuard` and `RolesGuard(['FINANCE', 'SUPERADMIN'])`.
- Input validation via `ExportQueryDto` will ensure that string dates are valid boundaries and the report type is supported.
