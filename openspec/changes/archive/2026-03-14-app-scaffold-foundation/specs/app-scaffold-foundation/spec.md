## ADDED Requirements

### Requirement: Frontend scaffold is independently runnable
The system SHALL provide a standalone frontend application in `frontend/` with its own package manifest, TypeScript setup, environment example, and scripts to run, build, lint, and test the app.

#### Scenario: Frontend developer setup
- **WHEN** a developer installs dependencies and runs the frontend scripts from `frontend/`
- **THEN** the application can start in development mode
- **AND** the app exposes build, lint, and test commands from that folder

### Requirement: Backend scaffold is independently runnable
The system SHALL provide a standalone backend application in `backend/` with its own package manifest, TypeScript setup, environment example, and scripts to run, build, lint, and test the app.

#### Scenario: Backend developer setup
- **WHEN** a developer installs dependencies and runs the backend scripts from `backend/`
- **THEN** the application can start in development mode
- **AND** the app exposes build, lint, and test commands from that folder

### Requirement: Backend exposes baseline API foundation
The backend scaffold MUST include global input validation, environment-based configuration, and Swagger setup so later API changes can build on a consistent base.

#### Scenario: Backend boots with baseline platform concerns
- **WHEN** the backend application starts
- **THEN** global validation is enabled for incoming requests
- **AND** Swagger is available for API documentation
- **AND** application configuration can be supplied through environment variables

### Requirement: Frontend and backend remain loosely coupled
The scaffold MUST preserve a clean separation between `frontend/` and `backend/` so the two applications can be split into separate repositories later.

#### Scenario: Frontend consumes backend through API boundary
- **WHEN** frontend code needs backend data or behavior
- **THEN** it integrates through HTTP APIs and environment-configured endpoints
- **AND** it does not import runtime code from `backend/`

### Requirement: Backend modules enforce service-oriented boundaries
The backend scaffold MUST establish module boundaries where repositories are only used inside their owning module service and other modules integrate through services.

#### Scenario: Cross-module data access
- **WHEN** one backend module needs behavior or data owned by another module
- **THEN** it calls the owning module's exported service
- **AND** it does not access the other module's repository directly

### Requirement: Scaffold provides local environment templates
The scaffold SHALL include example environment files for both applications so developers know the required configuration keys before feature work begins.

#### Scenario: New developer inspects configuration
- **WHEN** a developer opens the repository after the scaffold is added
- **THEN** `frontend/` and `backend/` each provide an environment example file
- **AND** the example files identify the minimum local configuration required to run each app
