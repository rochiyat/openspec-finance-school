## ADDED Requirements

### Requirement: Parents can query payment records for linked children
The system SHALL expose an endpoint allowing authenticated `PARENT` users to fetch payment histories for specific students.

#### Scenario: Parent queries valid linked student payments
- **WHEN** an authenticated `PARENT` requests payment histories for a `studentId` they are linked to
- **THEN** the system returns the payment records for that student

#### Scenario: Parent queries unlinked student payments
- **WHEN** an authenticated `PARENT` requests payment histories for a `studentId` they are NOT linked to
- **THEN** the system rejects the request as forbidden
