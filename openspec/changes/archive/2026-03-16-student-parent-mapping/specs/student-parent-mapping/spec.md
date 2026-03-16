## ADDED Requirements

### Requirement: Superadmin can create student-parent mappings
The system SHALL allow an authenticated superadmin to create mappings between existing students and existing parents.

#### Scenario: Superadmin creates a valid mapping
- **WHEN** an authenticated superadmin submits a valid student-parent pair
- **THEN** the system creates the mapping record
- **AND** the response includes `student_id`, `parent_id`, and `is_primary`

#### Scenario: Invalid linked records are rejected
- **WHEN** an authenticated superadmin submits a mapping with a missing student or missing parent
- **THEN** the system rejects the request with validation or business-rule errors

### Requirement: Student-parent mappings must enforce primary-parent rules
The system MUST enforce that a student has one primary parent designation within the mapping set.

#### Scenario: First mapping can be primary
- **WHEN** an authenticated superadmin creates the first mapping for a student with `is_primary` set to true
- **THEN** the system accepts the mapping

#### Scenario: Duplicate primary parent is rejected
- **WHEN** an authenticated superadmin creates another mapping for the same student with `is_primary` set to true while a primary parent already exists
- **THEN** the system rejects the request with business-rule errors

### Requirement: Superadmin can list parents for a student
The system SHALL allow an authenticated superadmin to retrieve parent mappings for a given student.

#### Scenario: Student parents are returned
- **WHEN** an authenticated superadmin requests `GET /students/:id/parents`
- **THEN** the system returns the mapped parent records for that student

### Requirement: Superadmin can list students for a parent
The system SHALL allow an authenticated superadmin to retrieve student mappings for a given parent.

#### Scenario: Parent students are returned
- **WHEN** an authenticated superadmin requests `GET /parents/:id/students`
- **THEN** the system returns the mapped student records for that parent

### Requirement: Student-parent mapping administration is superadmin-only
The system MUST protect student-parent mapping endpoints so only authenticated superadmin users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets a student-parent mapping endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Non-superadmin request is rejected
- **WHEN** an authenticated non-superadmin request targets a student-parent mapping endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic student-parent mapping interface
The system SHALL provide a basic frontend administration interface for superadmin to link students and parents and review the relationship lists.

#### Scenario: Superadmin manages mappings in the UI
- **WHEN** a superadmin opens the student-parent mapping screen
- **THEN** the interface shows mapping records
- **AND** the interface provides controls to create mappings and review parents by student or students by parent

#### Scenario: Non-superadmin cannot use the mapping UI
- **WHEN** a non-superadmin session reaches the student-parent mapping screen
- **THEN** the interface shows an unauthorized or unavailable state
