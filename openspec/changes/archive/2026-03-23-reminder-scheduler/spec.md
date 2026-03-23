# Spec: Automated Payment Reminder Scheduler

## Requirement: Core Engine & Schedule

The system MUST include a background scheduling system to evaluate billing states daily.

#### Scenario: Upcoming Payment (3 days prior)
- **GIVEN** an unpaid installment item with a `dueDate` of `2026-05-10`.
- **AND** the system date is `2026-05-07` (3 days before).
- **WHEN** the daily reminder job runs.
- **THEN** a notification is generated for the student's linked parent(s).
- **AND** the body contains "Upcoming Payment Reminder".

#### Scenario: Overdue Payment (1 day post)
- **GIVEN** an unpaid installment item with a `dueDate` of `2026-05-10`.
- **AND** the system date is `2026-05-11` (1 day after).
- **WHEN** the daily reminder job runs.
- **THEN** a notification is generated for the student's linked parent(s).
- **AND** the body contains "Overdue Payment Notice".

#### Scenario: No Trigger Needed
- **GIVEN** an unpaid item due on `2026-05-15`.
- **WHEN** the job runs on `2026-05-01`.
- **THEN** zero notifications are generated for this item.

## Requirement: Manual Trigger API

The system MUST expose an endpoint to fire the scheduling logic on-demand.

#### Scenario: Finance Triggers Scheduler
- **GIVEN** a user is logged in as `FINANCE`.
- **WHEN** they POST to `/api/reminders/trigger-daily`.
- **THEN** the system evaluates all items as if the daily cron executed.
- **AND** responds with `200 OK` and a summary of sent notifications.

#### Scenario: Unauthorized Execution Attempt
- **GIVEN** a user is logged in as `PARENT`.
- **WHEN** they POST to `/api/reminders/trigger-daily`.
- **THEN** they receive a `403 Forbidden` response.

## Requirement: Accurate Parent Matching

The notifications MUST go to the correct parent in a multi-user environment.

#### Scenario: Multi-Student Parent Maps
- **GIVEN** Student A maps to Parent X, and Student B maps to Parent Y.
- **AND** Student A has an overdue item, but Student B is fully paid.
- **WHEN** the daily reminder job runs.
- **THEN** a notification is generated for Parent X.
- **AND** NO notification is generated for Parent Y.
