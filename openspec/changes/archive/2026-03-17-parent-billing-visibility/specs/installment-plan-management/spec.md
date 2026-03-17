## ADDED Requirements

### Requirement: Parents can query installment plans for linked children
The system SHALL expose an endpoint allowing authenticated `PARENT` users to fetch installment plans and their items for specific students.

#### Scenario: Parent queries valid linked student installments
- **WHEN** an authenticated `PARENT` requests installment plans for a `studentId` they are linked to
- **THEN** the system returns the installment plans for that student

#### Scenario: Parent queries unlinked student installments
- **WHEN** an authenticated `PARENT` requests installment plans for a `studentId` they are NOT linked to
- **THEN** the system rejects the request as forbidden
