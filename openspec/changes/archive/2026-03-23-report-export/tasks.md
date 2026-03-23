## 1. Backend: Scaffold Reports Module
- [x] 1.1 Create `ReportsModule` at `backend/src/modules/reports/`.
- [x] 1.2 Implement `ReportsController` with `GET /api/reports/export`.
- [x] 1.3 Apply `BearerAuthGuard` and `RolesGuard(['FINANCE', 'SUPERADMIN'])` to the endpoint.
- [x] 1.4 Register `ReportsModule` in `AppModule`.

## 2. Backend: Service and CSV Generation Logic
- [x] 2.1 Implement `ExportQueryDto` with `type` (Enum: PAYMENTS, BILLINGS), `startDate` (Optional ISO string), `endDate` (Optional ISO string).
- [x] 2.2 Implement `ReportsService.exportData(query)`:
  - Depending on `type`, fetch data from `PaymentsService` or `BillingsService` (filtering by date if provided).
  - Map the internal entities to flat dictionaries suitable for CSV.
- [x] 2.3 Implement CSV formatting logic: Convert the flat array of objects to a CSV string. Standard headers should be matched with the data fields.
- [x] 2.4 Set appropriate response headers in Controller (`Content-Type: text/csv`, `Content-Disposition: attachment; filename="export.csv"`).
- [x] 2.5 Write unit tests for `ReportsService` covering date mapping and date filtering.

## 3. Frontend: Export UI
- [x] 3.1 Create an `exportReport(token, type, startDate, endDate)` helper in `frontend/src/lib/auth.ts` or a new API file. The fetch must handle the response as a blob.
- [x] 3.2 Update `FinanceDashboardPage.tsx` and `SuperadminDashboardPage.tsx` (or build a dedicated component to inject):
  - Add a "Report Export" section.
  - Implement dropdown for Report Type.
  - Implement Start Date and End Date pickers (standard HTML5 dates work).
  - Implement an Export action that calls the helper and uses `URL.createObjectURL(blob)` and an `<a>` element to download the file to the browser.

## 4. Testing & Verification
- [x] 4.1 Log in as `FINANCE`, generate a Payments report without dates, verify CSV.
- [x] 4.2 Log in as `FINANCE`, generate a Billings report with specific dates, verify CSV.
- [x] 4.3 Log in as `PARENT`, attempt to access `/api/reports/export`, verify `403`.
