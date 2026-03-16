## ADDED Requirements

### Requirement: Superadmin can list managed users
The system SHALL allow an authenticated superadmin to retrieve a list of managed users and their assigned roles.

#### Scenario: Superadmin views users
- **WHEN** an authenticated superadmin requests the user administration list
- **THEN** the system returns managed users with identity and assigned role information

#### Scenario: Non-superadmin cannot view users
- **WHEN** an authenticated non-superadmin requests the user administration list
- **THEN** the system rejects the request as forbidden

### Requirement: Superadmin can create internal users
The system SHALL allow an authenticated superadmin to create internal users for operational roles required by the MVP.

#### Scenario: Superadmin creates a finance user
- **WHEN** an authenticated superadmin submits valid user creation data with the `FINANCE` role
- **THEN** the system creates the user account
- **AND** the stored credential is protected with password hashing

#### Scenario: User creation payload is invalid
- **WHEN** an authenticated superadmin submits invalid user creation data
- **THEN** the system rejects the request with validation errors

### Requirement: Superadmin can assign and update roles
The system SHALL allow an authenticated superadmin to assign or update a managed user's role among `SUPERADMIN`, `FINANCE`, `GURU`, and `PARENT`.

#### Scenario: Superadmin updates a user role
- **WHEN** an authenticated superadmin submits a valid role assignment change
- **THEN** the system updates the managed user's role

#### Scenario: Unsupported role is rejected
- **WHEN** an authenticated superadmin submits a role outside the supported role set
- **THEN** the system rejects the request with validation errors

### Requirement: User and role administration is superadmin-only
The system MUST protect all user and role administration endpoints so only authenticated superadmin users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets a user administration endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Finance user attempts administration
- **WHEN** an authenticated `FINANCE` user targets a user administration endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic user-role administration interface
The system SHALL provide a basic frontend administration interface for superadmin to view users, create accounts, and update role assignments.

#### Scenario: Superadmin manages users in the UI
- **WHEN** a superadmin opens the user administration screen
- **THEN** the interface shows the current users and assigned roles
- **AND** the interface provides controls to create a user and update a role

#### Scenario: Non-superadmin cannot use the admin UI
- **WHEN** a non-superadmin session reaches the user administration screen
- **THEN** the interface shows an unauthorized or unavailable state
