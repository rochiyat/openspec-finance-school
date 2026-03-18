## 1. Backend: Module Scaffold & API

- [x] 1.1 Create `SuperadminDashboardModule` at `backend/src/modules/superadmin-dashboard/`.
- [x] 1.2 Implement `GET /api/superadmin-dashboard/overview` endpoint in `SuperadminDashboardController` with `BearerAuthGuard` and `RolesGuard(['SUPERADMIN'])`.
- [x] 1.3 Define the `SuperadminDashboardOverviewDto` with user, academic, financial, and notification stats.
- [x] 1.4 Register the `SuperadminDashboardModule` in `AppModule`.

## 2. Backend: Service Logic & Aggregation (Counts and Sums)

- [x] 2.1 Add `findAll()` to `NotificationsRepository` and expose it via `NotificationsService.listAllNotifications()`.
- [x] 2.2 Add `listParents()` method to `ParentsService` and export it from `ParentsModule`.
- [x] 2.3 Implement `SuperadminDashboardService.getOverview()`:
    - Aggregate user totals (Students, Parents, Teachers - filter by role `GURU`).
    - Aggregate academic totals (Active Academic Year, Total Classes).
    - Aggregate financial totals (Sum all billings vs sum all payments).
    - Aggregate notification totals (Grand total vs count of `isRead === true`).
- [x] 2.4 Write unit tests for `SuperadminDashboardService` to verify correct counts and monetary summary across all dependencies.

## 3. Frontend: Superadmin Dashboard Integration

- [x] 3.1 Add `fetchSuperadminDashboardOverview(token)` API helper and DTOs to `frontend/src/lib/auth.ts`.
- [x] 3.2 Create `SuperadminDashboardPage.tsx` at `frontend/src/pages/`:
    - Role gate specifically for `SUPERADMIN`.
    - Fetch overview metrics on mount.
    - Provide a grid-based layout showing system stats, financial health, and notification engagement.
- [x] 3.3 Register the route `/dashboard-superadmin` → `SuperadminDashboardPage` in `AppRouter.tsx`.

## 4. Verification & Testing

- [x] 4.1 Manual verification with a `SUPERADMIN` user — verify all system-wide counts are accurate.
- [x] 4.2 Verify restricted roles (`FINANCE`, `GURU`, `PARENT`) receive `403` on the API and cannot access the page.
- [x] 4.3 Verify the dashboard displays correct billing and payment totals.
- [x] 4.4 Run backend unit tests and ensure all pass.
