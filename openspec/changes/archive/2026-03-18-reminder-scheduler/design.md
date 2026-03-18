# Design: Automated Payment Reminder Scheduler

## Overview
The Reminder Scheduler is a background task orchestrator that evaluates the financial state of student accounts and dispatches automated notices to parents regarding upcoming deadlines and overdue balances.

---

## Backend Architecture

### 1. Library Dependencies
- Ensure `@nestjs/schedule` is installed and registered in `AppModule`.

### 2. Module: `RemindersModule`
A new module located at `backend/src/modules/reminders/`.

#### Service: `RemindersService`
The core engine executing the background tasks.
- **Dependencies injected**: 
  - `InstallmentsService` (to fetch unpaid items)
  - `StudentParentMapsService` (to get parent bindings)
  - `NotificationsService` (to dispatch messages)

**Cron Jobs**:
- `@Cron(CronExpression.EVERY_DAY_AT_9AM)`
- `processDailyReminders()`:
  - Iterates over all active installment items (or billings).
  - Filters items where `status !== 'PAID'`.
  - Checks the difference between the current date and the `dueDate`.
  - **Upcoming Check**: If `dueDate` is exactly 3 days away, generate an "Upcoming Payment" notification.
  - **Overdue Check**: If `dueDate` is exactly 1 day past, or 7 days past, generate an "Overdue Payment" notification.

#### Controller: `RemindersController`
To allow manual invocation, especially useful for E2E testing and admin overrides.
- **Endpoint**: `POST /api/reminders/trigger-daily`
- **Guards**: `BearerAuthGuard`, `RolesGuard(['SUPERADMIN', 'FINANCE'])`
- **Action**: Calls `this.remindersService.processDailyReminders()` and returns a summary of actions taken (e.g., `{ upcomingSent: 5, overdueSent: 2 }`).

---

## Logic Deep Dive: Identification & Dispatch

1. **Find Unpaid Targets**:
   - `InstallmentsService.listAllInstallmentItems()` gives us all items. We filter down where `amountRemaining > 0`.
2. **Date Math**:
   - Compare `dueDate` string (e.g., "2026-04-15") against today's date ("2026-04-12").
   - Calculate the delta in days. If delta === 3, it's upcoming. If delta === -1 or -7, it's overdue.
3. **Parent Resolution**:
   - Given the item's `studentId`, query `StudentParentMapsService.findByStudentId(studentId)`.
   - Dispatch to all linked parents (or just the primary parent). For simplicity, broadcast to all linked parents.
4. **Notification Construction**:
   - **Upcoming**:
     - Title: "Upcoming Payment Reminder"
     - Body: "Reminder: Payment for [Title] is due in 3 days ([DueDate]). Remaining balance: RpX00,000."
   - **Overdue**:
     - Title: "Overdue Payment Notice"
     - Body: "Notice: Payment for [Title] was due on [DueDate] and is currently overdue. Remaining balance: RpX00,000."

---

## Frontend Integration
Since this is primarily a background service, the frontend impact is minimal.
- We will add a "Trigger Manual Reminders" action button to the `FinanceDashboardPage` inside the admin-panel header for the operations team to manually run the daily check.

---

## Security & Constraints
- The automated job runs as a system process without a user token.
- The manual trigger endpoint strictly requires `FINANCE` or `SUPERADMIN` roles.
- **Idempotency/Spam protection**: For the MVP, it checks "exact" day offsets (e.g. exactly 3 days before). This inherently limits it to sending one message per defined offset.
