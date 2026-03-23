# Spec: Report Export

## Requirement: Access Control
The system MUST restrict access to the report export functionality to users with `FINANCE` or `SUPERADMIN` roles.

#### Scenario: Authorized Export
- **GIVEN** a user with the `FINANCE` role is logged in.
- **WHEN** they make a GET request to `/api/reports/export?type=PAYMENTS`.
- **THEN** the system returns a `200 OK` with a `text/csv` content type.

#### Scenario: Unauthorized Export
- **GIVEN** a user with the `PARENT` or `GURU` role is logged in.
- **WHEN** they make a GET request to `/api/reports/export?type=PAYMENTS`.
- **THEN** the system returns a `403 Forbidden`.

## Requirement: Filtering and Data Types
The system MUST allow filtering records by type (`PAYMENTS` or `BILLINGS`) and optionally by date range (`startDate`, `endDate`).

#### Scenario: Export Payments by Date Range
- **GIVEN** 10 payments exist in May 2026, and 5 payments exist in June 2026.
- **WHEN** a request is made to `/api/reports/export?type=PAYMENTS&startDate=2026-05-01&endDate=2026-05-31`.
- **THEN** the resulting CSV contains exactly 10 payment records (plus the header row).

#### Scenario: Missing Required Parameters
- **WHEN** a request is made to `/api/reports/export` without the `type` parameter.
- **THEN** the system returns a `400 Bad Request`.

## Requirement: CSV Format
The exported file MUST be in a valid CSV format with a descriptive header row.

#### Scenario: File Content
- **WHEN** a valid export request for `PAYMENTS` is made.
- **THEN** the first row of the response is `Payment ID,Date,Amount,Payment Method,Reference,Student NIS,Student Name,Billing Type`.
- **AND** the content type is `text/csv`.
- **AND** the `Content-Disposition` header indicates an attachment with a descriptive filename (e.g., `payments-export.csv`).
