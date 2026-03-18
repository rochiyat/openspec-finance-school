# Spec: Superadmin Global Dashboard

## Requirement: Access Control (Superadmin only)
The system MUST restrict access to the Superadmin Dashboard to users with the `SUPERADMIN` role.

#### Scenario: Authorized access
- **GIVEN** a user with the `SUPERADMIN` role is logged in.
- **WHEN** they make a GET request to `/api/superadmin-dashboard/overview`.
- **THEN** the system returns a `200 OK` with the global summary.

#### Scenario: Unauthorized access
- **GIVEN** a user with the `FINANCE`, `GURU`, or `PARENT` role is logged in.
- **WHEN** they make a GET request to `/api/superadmin-dashboard/overview`.
- **THEN** the system returns a `403 Forbidden`.

## Requirement: Global Financial Summary
The Superadmin Dashboard MUST show the total school-wide billing and payment summary.

#### Scenario: Aggregate Financials
- **GIVEN** the system contains:
  - Total billings across all students: 100,000,000
  - Total payments across all students: 75,000,000
- **WHEN** the superadmin dashboard overview is requested.
- **THEN** the response includes:
  - `totalBilled`: 100,000,000
  - `totalCollected`: 75,000,000
  - `outstandingReceivable`: 25,000,000

## Requirement: System User Counts
The dashboard MUST show current counts of various user types and configuration items.

#### Scenario: User Counts
- **GIVEN** student and parent records are present.
- **WHEN** the overview is requested.
- **THEN** it correctly reports counts for `totalStudents`, `totalParents`, `totalTeachers`, and `totalClasses`.

## Requirement: Notification Engagement Stats
The system MUST expose the total count and engagement status of all generated notifications.

#### Scenario: Notification Stats
- **GIVEN** 1,000 notifications in the database, with 400 marked as `read`.
- **WHEN** the overview is requested.
- **THEN** the response includes:
  - `totalSent`: 1,000
  - `readCount`: 400
  - `readRate`: 0.4 (40%)

## Requirement: Frontend UI and Redirection
The frontend MUST gate the `/dashboard-superadmin` route and display the global metrics.

#### Scenario: Non-superadmin is redirected
- **WHEN** a user with the `FINANCE` role navigates to `/dashboard-superadmin`.
- **THEN** they are redirected to the portal index or their respective dashboard.
