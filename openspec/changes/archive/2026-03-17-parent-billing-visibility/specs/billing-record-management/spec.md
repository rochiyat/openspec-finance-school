## ADDED Requirements

### Requirement: Parents can query billing records for linked children
The system SHALL expose an endpoint allowing authenticated `PARENT` users to fetch billing records for specific students.

#### Scenario: Parent queries valid linked student
- **WHEN** an authenticated `PARENT` requests billing records for a `studentId` they are linked to
- **THEN** the system returns the billing records for that student

#### Scenario: Parent queries unlinked student
- **WHEN** an authenticated `PARENT` requests billing records for a `studentId` they are NOT linked to
- **THEN** the system rejects the request as forbidden
