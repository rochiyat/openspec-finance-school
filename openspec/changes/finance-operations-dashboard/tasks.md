## 1. Backend: Module Scaffold & Endpoint

- [x] 1.1 Create `FinanceDashboardModule` at `backend/src/modules/finance-dashboard/` with controller, service, and module files.
- [x] 1.2 Implement `GET /api/finance-dashboard/overview` endpoint in `FinanceDashboardController` with `BearerAuthGuard` and `RolesGuard(['FINANCE', 'SUPERADMIN'])`.
- [x] 1.3 Define DTOs: `FinanceDashboardOverviewDto` and `DelinquentStudentDto`.
- [x] 1.4 Register `FinanceDashboardModule` in `AppModule`.

## 2. Backend: Aggregation Logic

- [x] 2.1 Implement `FinanceDashboardService.getOverview()`:
  - Fetch all billings and compute `totalBilled`, `overdueCount`, `unpaidCount`.
  - Fetch all payments and compute `totalCollected`.
  - Derive `outstandingReceivable = totalBilled - totalCollected`.
  - Fetch all installment items and compute `activeInstallmentCount` (status !== `PAID`).
- [x] 2.2 Build the `delinquentStudents` list by grouping OVERDUE billings by `studentId`, resolving student details via `StudentsService`.
- [x] 2.3 Write unit tests for `FinanceDashboardService` covering:
  - Correct calculation of all financial aggregates.
  - Delinquent student list contains correct students with correct overdue counts.
  - Returns empty `delinquentStudents` when no billings are overdue.

## 3. Frontend: Finance Dashboard Page

- [x] 3.1 Add `fetchFinanceDashboardOverview(token)` API helper to `frontend/src/lib/auth.ts`.
- [x] 3.2 Create `FinanceDashboardPage` component at `frontend/src/pages/FinanceDashboardPage.tsx`:
  - On mount, verify user role is `FINANCE` or `SUPERADMIN`; redirect to `/` otherwise.
  - Call `fetchFinanceDashboardOverview` and store result in state.
  - Render 6 stat cards: Total Billed, Total Collected, Outstanding, Overdue Count, Unpaid Count, Active Installments.
  - Render a delinquent students table with columns: NIS, Name, Overdue Bills.
- [x] 3.3 Register the route `/dashboard-keuangan` → `FinanceDashboardPage` in `AppRouter.tsx`.

## 4. Verification & Testing

- [x] 4.1 Manual test with a seeded `FINANCE` user — verify all stats and delinquent list are accurate.
- [x] 4.2 Verify that a `GURU` user calling `GET /api/finance-dashboard/overview` receives `403`.
- [x] 4.3 Verify that navigating to `/dashboard-keuangan` as a `PARENT` user redirects to the login page.
- [x] 4.4 Run the backend unit test suite and confirm passing.
