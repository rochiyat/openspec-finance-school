## ADDED Requirements

### Requirement: User can authenticate with valid credentials
The system SHALL provide `POST /auth/login` to authenticate a user with valid credentials and establish an authenticated session contract for subsequent requests.

#### Scenario: Successful login
- **WHEN** a user submits valid credentials to `POST /auth/login`
- **THEN** the system returns a successful authentication response
- **AND** the response includes the authenticated user's identity context needed by the client

#### Scenario: Invalid login is rejected
- **WHEN** a user submits invalid credentials to `POST /auth/login`
- **THEN** the system rejects the request with a structured authentication error
- **AND** the system does not disclose whether the username or password was incorrect

### Requirement: Passwords are stored securely
The system MUST hash user passwords before persistence and MUST never store or return raw credentials.

#### Scenario: Password persistence
- **WHEN** a user credential is stored or updated
- **THEN** the system persists only a password hash
- **AND** the raw password is not stored in the database or returned by the API

### Requirement: Authenticated users can retrieve current session identity
The system SHALL provide `GET /auth/me` so an authenticated client can retrieve the current user's identity and role.

#### Scenario: Session identity lookup succeeds
- **WHEN** an authenticated user calls `GET /auth/me`
- **THEN** the system returns the current user's identity
- **AND** the response includes the role assigned to that user

#### Scenario: Anonymous session identity lookup is rejected
- **WHEN** a request without valid authentication calls `GET /auth/me`
- **THEN** the system rejects the request as unauthenticated

### Requirement: Protected routes enforce role-based access
The system MUST enforce role-based access on protected endpoints using the defined roles `SUPERADMIN`, `FINANCE`, `GURU`, and `PARENT`.

#### Scenario: Authorized role is allowed
- **WHEN** an authenticated user with a permitted role accesses a protected endpoint
- **THEN** the system allows the request to proceed

#### Scenario: Unauthorized role is denied
- **WHEN** an authenticated user without a permitted role accesses a protected endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: Authentication requests are validated and fail safely
The system MUST validate authentication inputs and return structured errors for invalid or impossible auth states.

#### Scenario: Missing required login fields
- **WHEN** a login request omits required credential fields
- **THEN** the system rejects the request with validation errors

#### Scenario: Malformed authentication token
- **WHEN** a protected endpoint receives a malformed or expired authentication token
- **THEN** the system rejects the request as unauthenticated
- **AND** the response remains structured and safe for clients to handle

### Requirement: MVP auth includes a basic login interface
The system SHALL provide a basic login UI so users can submit credentials and enter the application according to their role.

#### Scenario: Login UI submits credentials
- **WHEN** a user enters credentials in the login interface and submits the form
- **THEN** the client sends the authentication request to `POST /auth/login`
- **AND** the client handles success and failure states for the user
