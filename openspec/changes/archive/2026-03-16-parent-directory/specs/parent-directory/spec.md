## ADDED Requirements

### Requirement: Superadmin can manage parent records
The system SHALL allow an authenticated superadmin to create, list, and view parent records.

#### Scenario: Superadmin creates a parent
- **WHEN** an authenticated superadmin submits valid parent data
- **THEN** the system creates the parent record
- **AND** the response includes `user_id`, `full_name`, `phone`, `email`, and `address`

#### Scenario: Superadmin lists parents
- **WHEN** an authenticated superadmin requests parent data
- **THEN** the system returns the managed parent records

#### Scenario: Superadmin views a parent detail
- **WHEN** an authenticated superadmin requests a specific parent by id
- **THEN** the system returns the parent record details

### Requirement: Parent records must reference valid parent users
The system MUST validate that each parent record references an existing managed user with the `PARENT` role.

#### Scenario: Valid linked parent user
- **WHEN** an authenticated superadmin submits a parent linked to an existing `PARENT` user
- **THEN** the system accepts the parent record

#### Scenario: Invalid linked user is rejected
- **WHEN** an authenticated superadmin submits a parent linked to a missing user or a user without the `PARENT` role
- **THEN** the system rejects the request with validation or business-rule errors

### Requirement: Parent directory administration is superadmin-only
The system MUST protect parent management endpoints so only authenticated superadmin users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets a parent administration endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Non-superadmin request is rejected
- **WHEN** an authenticated non-superadmin request targets a parent administration endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic parent management interface
The system SHALL provide a basic frontend administration interface for superadmin to view and manage parent records.

#### Scenario: Superadmin manages parents in the UI
- **WHEN** a superadmin opens the parent management screen
- **THEN** the interface shows parent records
- **AND** the interface provides controls to create and view parent records

#### Scenario: Non-superadmin cannot use the parent UI
- **WHEN** a non-superadmin session reaches the parent management screen
- **THEN** the interface shows an unauthorized or unavailable state
