# Proposal: Automated Payment Reminder Scheduler

## Purpose
Implement an automated background scheduler that periodically checks for upcoming or overdue payments and dispatches notifications to the responsible parents.

## Motivation
Currently, finance staff must manually monitor unpaid bills and contact parents. By automating this process, the system can improve cash flow collection rates, reduce administrative overhead for the finance department, and provide parents with helpful, timely nudges before and after due dates.

## Target Persona
- **Finance Staff**: Benefits from automated "chasing" of payments without manual effort.
- **Parents**: Receives timely notifications (e.g., "3 days until due" or "Overdue Notice") to avoid missing payments.

## Scope of Change
- **Backend Architecture**:
  - Integrate `@nestjs/schedule` to support cron jobs.
  - Create a new `RemindersModule` dedicated to background jobs.
  - Implement daily cron jobs to identify:
    - **Upcoming payments**: Due in exactly 3 days.
    - **Overdue payments**: Overdue by 1 day, 7 days, etc.
  - Generate notifications using the existing `NotificationsService`.
- **API Extension**:
  - Add a manual `POST /api/reminders/trigger-daily` endpoint to allow `SUPERADMIN` or `FINANCE` to force-run the reminder job on demand (useful for testing and manual overrides).
- **Frontend Architecture**:
  - Add a "Trigger Daily Reminders" button in the Finance Dashboard or Superadmin Panel.

## Affected Components
- `backend/src/app.module.ts` (Add `ScheduleModule.forRoot()`)
- `backend/src/modules/reminders/` (New module)
- `backend/src/modules/installments/` (To query due items)
- `backend/src/modules/notifications/` (To dispatch alerts)

## Dependencies
- `InstallmentsModule` / `BillingsModule`: To find outstanding balances and due dates.
- `NotificationsModule`: To send the actual messages to parents.
- `StudentParentMapsModule`: To find the parents linked to the owing student.

## Success Criteria
- [ ] Background job runs successfully and identifies the correct unpaid items.
- [ ] Appropriate notifications are routed to the linked parent.
- [ ] Manual trigger endpoint successfully executes the job synchronously for testing.
