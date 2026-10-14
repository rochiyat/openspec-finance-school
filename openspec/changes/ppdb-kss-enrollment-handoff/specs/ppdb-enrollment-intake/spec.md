## Purpose
Defines the KSS endpoint that turns an accepted PPDB applicant into a KSS student with a linked parent account, safely and only once.

## ADDED Requirements

### Requirement: Intake requires the integration key
The KSS system SHALL accept PPDB enrollments only on `POST /integrations/ppdb/enrollments` with a valid integration key header, and MUST reject every request when no integration key is configured.

#### Scenario: Missing or wrong key is rejected
- **WHEN** a request has no integration key or a wrong one
- **THEN** the system responds 401 and creates nothing

#### Scenario: Unconfigured key fails closed
- **WHEN** the server has no integration key configured
- **THEN** every intake request is rejected and creates nothing

#### Scenario: User sessions cannot use the endpoint
- **WHEN** a logged-in KSS user calls the endpoint with a user session token but no integration key
- **THEN** the system responds 401

### Requirement: Intake creates the student, parent and primary mapping
For a new source identifier, the KSS system SHALL create or reuse the parent user, create or reuse the parent record, create the student in the mapped class and academic year with a generated NIS, link them with the parent as primary, and record the enrollment with its source identifier.

#### Scenario: New family
- **WHEN** a valid enrollment arrives for an email that has no KSS user
- **THEN** a user with the `PARENT` role, a parent record, a student and a primary mapping are created
- **AND** the response returns the KSS student id, parent id and NIS

#### Scenario: Sibling of an existing KSS family
- **WHEN** a valid enrollment arrives for an email that already belongs to a KSS parent
- **THEN** the existing user and parent record are reused and only a new student and mapping are created

#### Scenario: Existing staff user enrolls a child
- **WHEN** a valid enrollment arrives for an email that belongs to a KSS user without the `PARENT` role
- **THEN** the `PARENT` role is added to that user and their other roles are kept

### Requirement: Intake is idempotent per source identifier
The KSS system MUST NOT create a second student, parent or mapping for a source identifier it has already completed.

#### Scenario: Same enrollment sent twice
- **WHEN** an enrollment with an already completed source identifier arrives
- **THEN** the system responds with the existing KSS ids and creates nothing new

#### Scenario: Interrupted intake is resumed
- **WHEN** a previous attempt for a source identifier stopped after some records were created and the enrollment is sent again
- **THEN** the system reuses the records already created and completes the remaining steps

### Requirement: Intake rejects enrollments it cannot place
The KSS system SHALL reject an enrollment with a business-rule error and an error code when the academic year name is unknown, when no class mapping exists for the level in that year, or when required fields are missing or invalid.

#### Scenario: Missing class mapping
- **WHEN** an enrollment names a level with no class mapping for its academic year
- **THEN** the system responds 422 with error code `PPDB_CLASS_MAPPING_MISSING` naming the year and level
- **AND** creates nothing

#### Scenario: Unknown academic year
- **WHEN** an enrollment names an academic year that does not exist in KSS
- **THEN** the system responds 422 with error code `PPDB_ACADEMIC_YEAR_NOT_FOUND`

### Requirement: New parents set their own password
The KSS system MUST NOT generate, return or send a password for a parent user created by intake. It SHALL send the parent an account setup link valid for at least 72 hours by email, and by WhatsApp when a phone number is present.

#### Scenario: Setup link for a new parent
- **WHEN** intake creates a new parent user
- **THEN** the parent receives a link to set their own password
- **AND** the intake response contains no password or token

#### Scenario: Existing parents get no setup link
- **WHEN** intake reuses an existing parent user
- **THEN** no setup link is sent and the user's password is unchanged

### Requirement: Intake is auditable
The KSS system SHALL record each completed intake with its source identifier, the created or reused KSS ids and the time it completed.

#### Scenario: Enrollment trace
- **WHEN** an administrator looks up a KSS student created by intake
- **THEN** the PPDB source identifier for that student can be found
