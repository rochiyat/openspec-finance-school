## ADDED Requirements

### Requirement: Admin can create an education focus
The system SHALL provide `POST /education-focuses` to create a new education focus record with name, description, and display order. Only users with the SUPERADMIN role SHALL be permitted to create focuses.

#### Scenario: Successful creation
- **WHEN** a SUPERADMIN user sends a valid `POST /education-focuses` request with name, description, and display_order
- **THEN** the system creates the education focus record
- **AND** returns the created focus with its generated UUID and `is_active` defaulting to `true`
- **AND** responds with HTTP 201

#### Scenario: Creation with duplicate name
- **WHEN** a SUPERADMIN user sends a `POST /education-focuses` request with a name that already exists (case-insensitive)
- **THEN** the system rejects the request with a conflict error
- **AND** responds with HTTP 409

#### Scenario: Non-SUPERADMIN is denied
- **WHEN** a user without the SUPERADMIN role sends a `POST /education-focuses` request
- **THEN** the system rejects the request as forbidden
- **AND** responds with HTTP 403

### Requirement: Authenticated users can list education focuses
The system SHALL provide `GET /education-focuses` to list all active education focuses ordered by `display_order ASC, name ASC`. All authenticated users SHALL be permitted to read the focus list.

#### Scenario: List active focuses
- **WHEN** an authenticated user sends a `GET /education-focuses` request
- **THEN** the system returns all education focuses where `is_active` is `true`
- **AND** results are ordered by `display_order` ascending, then `name` ascending
- **AND** each focus includes its associated active checklist items

#### Scenario: List with includeInactive flag
- **WHEN** a SUPERADMIN user sends a `GET /education-focuses?includeInactive=true` request
- **THEN** the system returns all education focuses including those where `is_active` is `false`

#### Scenario: Unauthenticated request is rejected
- **WHEN** a request without valid authentication calls `GET /education-focuses`
- **THEN** the system rejects the request as unauthenticated

### Requirement: Authenticated users can get a single education focus
The system SHALL provide `GET /education-focuses/:id` to retrieve a single education focus by its UUID, including its associated checklist items. All authenticated users SHALL be permitted.

#### Scenario: Focus found
- **WHEN** an authenticated user sends a `GET /education-focuses/:id` request for an existing, active focus
- **THEN** the system returns the education focus with its associated active checklist items

#### Scenario: Focus not found
- **WHEN** an authenticated user sends a `GET /education-focuses/:id` request for a non-existent or inactive focus
- **THEN** the system returns a not-found error with HTTP 404

### Requirement: Admin can update an education focus
The system SHALL provide `PATCH /education-focuses/:id` to update an existing education focus. Only SUPERADMIN role SHALL be permitted.

#### Scenario: Successful update
- **WHEN** a SUPERADMIN user sends a valid `PATCH /education-focuses/:id` request with partial fields (name, description, display_order, is_active)
- **THEN** the system updates only the provided fields
- **AND** returns the updated education focus

#### Scenario: Update with duplicate name
- **WHEN** a SUPERADMIN user sends a `PATCH /education-focuses/:id` request with a name that belongs to a different existing focus
- **THEN** the system rejects the request with a conflict error

#### Scenario: Focus not found
- **WHEN** a SUPERADMIN user sends a `PATCH /education-focuses/:id` request for a non-existent focus
- **THEN** the system returns a not-found error with HTTP 404

### Requirement: Admin can soft-delete an education focus
The system SHALL provide `DELETE /education-focuses/:id` to deactivate an education focus by setting `is_active` to `false`. Only SUPERADMIN role SHALL be permitted. The record SHALL NOT be physically removed from the database.

#### Scenario: Successful soft-delete
- **WHEN** a SUPERADMIN user sends a `DELETE /education-focuses/:id` request for an active focus
- **THEN** the system sets `is_active` to `false` on the focus
- **AND** sets `is_active` to `false` on all associated checklist items
- **AND** responds with HTTP 200

#### Scenario: Focus not found
- **WHEN** a SUPERADMIN user sends a `DELETE /education-focuses/:id` for a non-existent focus
- **THEN** the system returns a not-found error with HTTP 404

### Requirement: Seed data provides 4 default education focuses
The system SHALL include seed data for the 4 default education focuses defined by the Iqrolife education framework. The seed data SHALL be applied via a database migration that is idempotent.

#### Scenario: Fresh deployment includes seed data
- **WHEN** the database migrations run on a fresh deployment
- **THEN** the system creates 4 education focus records: Pendidikan Iman (order 1), Pendidikan Ego & Individualitas (order 2), Pendidikan Bahasa (order 3), Psikomotor (order 4)
- **AND** all seeded records have `is_active` set to `true`

#### Scenario: Re-run does not duplicate seed data
- **WHEN** the seed migration runs on a database that already contains the default focuses
- **THEN** the system does not create duplicate records

### Requirement: Admin can manage education focuses via a dedicated admin UI page
The system SHALL provide an admin page at the `/admin/education-focuses` route for managing education focuses. The page SHALL allow SUPERADMIN users to create, view, edit, and deactivate focuses.

#### Scenario: Admin views the education focus management page
- **WHEN** a SUPERADMIN user navigates to `/admin/education-focuses`
- **THEN** the system displays a list of all education focuses ordered by display_order
- **AND** each focus shows its name, description, display_order, and active status

#### Scenario: Admin creates a new focus via UI
- **WHEN** a SUPERADMIN user fills in the create form and submits
- **THEN** the system sends a `POST /education-focuses` request
- **AND** the new focus appears in the list without a full page reload

#### Scenario: Non-SUPERADMIN cannot access the page
- **WHEN** a non-SUPERADMIN user navigates to `/admin/education-focuses`
- **THEN** the system redirects or denies access
