## ADDED Requirements

### Requirement: Superadmin can manage academic years
The system SHALL allow an authenticated superadmin to create and list academic years with their name, start date, end date, and active status.

#### Scenario: Superadmin creates an academic year
- **WHEN** an authenticated superadmin submits valid academic year data
- **THEN** the system creates the academic year record
- **AND** the response includes `name`, `start_date`, `end_date`, and `is_active`

#### Scenario: Superadmin lists academic years
- **WHEN** an authenticated superadmin requests academic year data
- **THEN** the system returns the managed academic years with their active status

### Requirement: Only one academic year is active at a time
The system MUST maintain a single active academic year for the current operating context.

#### Scenario: New active year replaces previous active year
- **WHEN** an authenticated superadmin creates or updates an academic year with `is_active` set to true
- **THEN** the system marks that academic year as active
- **AND** any previously active academic year becomes inactive

### Requirement: Superadmin can manage classes
The system SHALL allow an authenticated superadmin to create and list classes with their academic year and homeroom teacher assignment.

#### Scenario: Superadmin creates a class
- **WHEN** an authenticated superadmin submits valid class data with an academic year and homeroom teacher
- **THEN** the system creates the class record
- **AND** the response includes `name`, `academic_year_id`, and `homeroom_teacher_id`

#### Scenario: Superadmin lists classes
- **WHEN** an authenticated superadmin requests class data
- **THEN** the system returns classes with their academic year and homeroom teacher linkage

### Requirement: Homeroom teacher assignment must reference a teacher user
The system MUST validate that a class homeroom assignment references an existing managed user with the `GURU` role.

#### Scenario: Valid teacher assignment
- **WHEN** an authenticated superadmin assigns a managed user with the `GURU` role as homeroom teacher
- **THEN** the system accepts the class record

#### Scenario: Invalid teacher assignment is rejected
- **WHEN** an authenticated superadmin assigns a user who does not exist or does not have the `GURU` role
- **THEN** the system rejects the request with validation or business-rule errors

### Requirement: Academic year and class administration is superadmin-only
The system MUST protect academic year and class administration endpoints so only authenticated superadmin users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets academic year or class administration endpoints
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Non-superadmin request is rejected
- **WHEN** an authenticated non-superadmin request targets academic year or class administration endpoints
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic academic year and class administration interface
The system SHALL provide a basic frontend administration interface for superadmin to view and create academic years and classes.

#### Scenario: Superadmin manages master data in the UI
- **WHEN** a superadmin opens the academic year and class administration screen
- **THEN** the interface shows academic years and classes
- **AND** the interface provides controls to create academic years and classes

#### Scenario: Non-superadmin cannot use the master data UI
- **WHEN** a non-superadmin session reaches the academic year and class administration screen
- **THEN** the interface shows an unauthorized or unavailable state
