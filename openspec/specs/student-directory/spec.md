## ADDED Requirements

### Requirement: Superadmin can manage student records
The system SHALL allow an authenticated superadmin to create, list, view, and update student records.

#### Scenario: Superadmin creates a student
- **WHEN** an authenticated superadmin submits valid student data
- **THEN** the system creates the student record
- **AND** the response includes `nis`, `full_name`, `gender`, `class_id`, `academic_year_id`, and `status_active`

#### Scenario: Superadmin lists students
- **WHEN** an authenticated superadmin requests student data
- **THEN** the system returns the managed student records

#### Scenario: Superadmin views a student detail
- **WHEN** an authenticated superadmin requests a specific student by id
- **THEN** the system returns the student record details

#### Scenario: Superadmin updates a student
- **WHEN** an authenticated superadmin submits a valid partial update for a student
- **THEN** the system updates the student record

### Requirement: Student records must reference valid academic structure
The system MUST validate that student records reference existing academic years and classes.

#### Scenario: Valid class and academic year assignment
- **WHEN** an authenticated superadmin submits a student linked to an existing class and academic year
- **THEN** the system accepts the student record

#### Scenario: Invalid class or academic year assignment is rejected
- **WHEN** an authenticated superadmin submits a student linked to a missing class or academic year
- **THEN** the system rejects the request with validation or business-rule errors

### Requirement: Student directory administration is superadmin-only
The system MUST protect student management endpoints so only authenticated superadmin users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets a student administration endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Non-superadmin request is rejected
- **WHEN** an authenticated non-superadmin request targets a student administration endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic student management interface
The system SHALL provide a basic frontend administration interface for superadmin to view and manage student records.

#### Scenario: Superadmin manages students in the UI
- **WHEN** a superadmin opens the student management screen
- **THEN** the interface shows student records
- **AND** the interface provides controls to create and update students

#### Scenario: Non-superadmin cannot use the student UI
- **WHEN** a non-superadmin session reaches the student management screen
- **THEN** the interface shows an unauthorized or unavailable state
