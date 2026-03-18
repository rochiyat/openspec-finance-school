## Requirement: Finance Staff Access to Operations Overview
The system SHALL provide an authenticated user with the `FINANCE` or `SUPERADMIN` role access to a dashboard summarizing school-wide financial activity.

#### Scenario: Finance staff views the operations overview
- **WHEN** an authenticated `FINANCE` user makes a GET request to `/api/finance-dashboard/overview`
- **THEN** the system returns a summary including:
  - `totalBilled`: Total monetary value of all billings in the system
  - `totalCollected`: Total monetary value of all recorded payments
  - `outstandingReceivable`: Difference between totalBilled and totalCollected
  - `overdueCount`: Number of billings with status `OVERDUE`
  - `unpaidCount`: Number of billings with status `UNPAID`
  - `activeInstallmentCount`: Number of installment items with status other than `PAID`
- **AND** returns a `delinquentStudents` array, each entry containing:
  - `studentId`, `nis`, `fullName`, `overdueCount` (number of OVERDUE billings for that student)

#### Scenario: Superadmin views the operations overview
- **WHEN** an authenticated `SUPERADMIN` user makes a GET request to `/api/finance-dashboard/overview`
- **THEN** the system returns the same response as for the `FINANCE` role.

## Requirement: Access Restriction for Non-Finance Roles
Users without the `FINANCE` or `SUPERADMIN` role MUST NOT access the finance dashboard endpoint.

#### Scenario: Unauthorised role attempts access
- **WHEN** an authenticated user with role `GURU` or `PARENT` makes a GET request to `/api/finance-dashboard/overview`
- **THEN** the system returns a `403 Forbidden` response.

#### Scenario: Unauthenticated request
- **WHEN** a request is made to `/api/finance-dashboard/overview` without a valid Bearer token
- **THEN** the system returns a `401 Unauthorized` response.

## Requirement: Accurate Financial Aggregation
The financial summary values MUST be computed from live data in the billings and payments collections.

#### Scenario: Outstanding receivable computation
- **GIVEN** the system has billings totalling 10,000,000 and payments totalling 4,500,000
- **WHEN** the finance dashboard is requested
- **THEN** `outstandingReceivable` equals 5,500,000.

#### Scenario: Delinquent student list correctness
- **GIVEN** student A has 2 OVERDUE billings and student B has 1 OVERDUE billing
- **WHEN** the finance dashboard is requested
- **THEN** `delinquentStudents` contains entries for both students with correct `overdueCount` values.

## Requirement: Finance Dashboard UI
The frontend SHALL provide a page at `/dashboard-keuangan` accessible only to `FINANCE` and `SUPERADMIN` users.

#### Scenario: Finance user sees dashboard
- **WHEN** a logged-in `FINANCE` user navigates to `/dashboard-keuangan`
- **THEN** summary stat cards are displayed for all six metrics.
- **AND** the delinquent students list is rendered below the stats.

#### Scenario: Non-finance user is redirected
- **WHEN** a logged-in `GURU` or `PARENT` user navigates to `/dashboard-keuangan`
- **THEN** they are redirected to the home page or login.
