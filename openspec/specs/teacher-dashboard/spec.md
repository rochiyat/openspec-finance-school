## Requirement: Homeroom Teacher Access to Class Payment Overview
The system SHALL provide an authenticated user with the `GURU` role access to a dashboard summarizing the payment status of all students in the class where they are assigned as the homeroom teacher.

#### Scenario: Teacher views class dashboard overview
- **WHEN** an authenticated `GURU` makes a GET request to `/api/teacher-dashboard/overview`
- **THEN** the system identifies the class assigned to the teacher
- **AND** returns a summary including:
  - The name of the class
  - Total number of students
  - Count of students with overdue billings
  - Count of students with unpaid/partial billings
- **AND** returns a list of students with their identified cumulative payment status.

## Requirement: Prevention of Cross-Class Data Exposure
A teacher MUST NOT be able to view payment data for students outside of their assigned homeroom class.

#### Scenario: Teacher without an assigned class
- **WHEN** an authenticated `GURU` who is not assigned to any class as a homeroom teacher requests the overview
- **THEN** the system returns an empty state or a 404/422 error indicating no class assignment found.

#### Scenario: Teacher attempts to access data for another class
- **WHEN** an authenticated `GURU` attempts to query data (if classId were parameterized) for a class they do not manage
- **THEN** the system rejects the request or only returns data for their managed class.

## Requirement: Consistent Payment Status Indicators
The dashboard MUST use the same status definitions (`PAID`, `PARTIALLY_PAID`, `UNPAID`, `OVERDUE`) as the finance and parent views to ensure data consistency across the application.
