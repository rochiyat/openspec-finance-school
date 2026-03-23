## 1. Environment & Setup

- [x] 1.1 Install dependencies: `npm install @nestjs/schedule` and `npm install --save-dev @types/cron` inside the `backend` directory (if not already present).
- [x] 1.2 Import `ScheduleModule.forRoot()` into `backend/src/app.module.ts`.

## 2. Backend: Logic & API

- [x] 2.1 Create `RemindersModule` at `backend/src/modules/reminders/`.
- [x] 2.2 Inject `InstallmentsModule`, `StudentParentMapsModule`, and `NotificationsModule`.
- [x] 2.3 Implement `RemindersService`:
    - Method `processDailyReminders()`: Loops over active installments, performs date math against `dueDate`.
    - Handles "3 days before" logic to trigger upcoming alerts via `NotificationsService`.
    - Handles "1 day after" and "7 days after" logic to trigger overdue alerts.
- [x] 2.4 Implement `RemindersController`:
    - Expose `POST /api/reminders/trigger-daily`.
    - Role gate for `SUPERADMIN` and `FINANCE`.
- [x] 2.5 Write unit tests for `RemindersService` date math and notification output counting.

## 3. Frontend: Integration

- [x] 3.1 Update `frontend/src/lib/auth.ts` with `triggerDailyReminders(token)` helper.
- [x] 3.2 Update `FinanceDashboardPage.tsx`:
    - Add a "Trigger Engine" or "Run Daily Checks" button.
    - Handle loading state and display the summary result alert when triggered successfully.

## 4. Verification

- [x] 4.1 Log in as Finance, trigger the daily job.
- [x] 4.2 Verify backend unit tests for date simulation accurately catch overdue and upcoming thresholds.
