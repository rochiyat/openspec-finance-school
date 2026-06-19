# Activity Type CRUD

## Purpose

Manage master data for daily activity types used in facilitator class reports.

## Requirements

### Requirement: List activity types
The system SHALL provide a paginated list of activity types ordered by `display_order` ascending. By default only active activity types are returned. An optional `includeInactive` query parameter SHALL include soft-deleted items when set to `true`.

#### Scenario: List active activity types
- **WHEN** a GET request is made to `/activity-types` without query parameters
- **THEN** the system returns all activity types where `is_active = true`, ordered by `display_order` ascending

#### Scenario: List all activity types including inactive
- **WHEN** a GET request is made to `/activity-types?includeInactive=true`
- **THEN** the system returns all activity types regardless of `is_active` status, ordered by `display_order` ascending

#### Scenario: Empty list
- **WHEN** no activity types exist in the database
- **THEN** the system returns an empty array with status `ok`

---

### Requirement: Get activity type by ID
The system SHALL return a single activity type when requested by its UUID, regardless of active status.

#### Scenario: Activity type found
- **WHEN** a GET request is made to `/activity-types/:id` with a valid UUID
- **THEN** the system returns the activity type with all fields including `id`, `name`, `description`, `displayOrder`, `isActive`, `createdAt`, `updatedAt`

#### Scenario: Activity type not found
- **WHEN** a GET request is made to `/activity-types/:id` with a UUID that does not exist
- **THEN** the system returns a 404 error with `errorCode: ACTIVITY_TYPE_NOT_FOUND`

---

### Requirement: Create activity type
The system SHALL allow SUPERADMIN users to create a new activity type with a unique name. The `name` field is required, `description` and `displayOrder` are optional.

#### Scenario: Successful creation
- **WHEN** a POST request is made to `/activity-types` with `{ "name": "Circle Time", "description": "Dialog dan doa", "displayOrder": 3 }`
- **THEN** the system creates the activity type with `isActive = true` and returns the created entity with a generated UUID

#### Scenario: Duplicate name
- **WHEN** a POST request is made to `/activity-types` with a `name` that already exists (case-sensitive, trimmed)
- **THEN** the system returns a 409 error with `errorCode: ACTIVITY_TYPE_NAME_EXISTS`

#### Scenario: Non-SUPERADMIN user attempts creation
- **WHEN** a POST request is made by a user without SUPERADMIN role
- **THEN** the system returns a 403 Forbidden error

---

### Requirement: Update activity type
The system SHALL allow SUPERADMIN users to partially update an activity type. Only provided fields are updated; omitted fields retain their current values.

#### Scenario: Successful update
- **WHEN** a PATCH request is made to `/activity-types/:id` with `{ "name": "New Name" }`
- **THEN** the system updates only the `name` field and returns the full updated entity

#### Scenario: Update to duplicate name
- **WHEN** a PATCH request is made with a `name` that belongs to another activity type
- **THEN** the system returns a 409 error with `errorCode: ACTIVITY_TYPE_NAME_EXISTS`

#### Scenario: Update non-existent activity type
- **WHEN** a PATCH request is made to `/activity-types/:id` with a UUID that does not exist
- **THEN** the system returns a 404 error with `errorCode: ACTIVITY_TYPE_NOT_FOUND`

---

### Requirement: Soft-delete activity type
The system SHALL allow SUPERADMIN users to soft-delete an activity type by setting `is_active = false`. The record is not physically removed from the database.

#### Scenario: Successful soft-delete
- **WHEN** a DELETE request is made to `/activity-types/:id` with a valid UUID
- **THEN** the system sets `is_active = false` on the activity type and returns a success message

#### Scenario: Delete non-existent activity type
- **WHEN** a DELETE request is made to `/activity-types/:id` with a UUID that does not exist
- **THEN** the system returns a 404 error with `errorCode: ACTIVITY_TYPE_NOT_FOUND`

---

### Requirement: Seed default activity types
The system SHALL seed 8 default activity types on initial deployment, matching the PRD specification.

#### Scenario: Seed data on fresh database
- **WHEN** the seed migration runs on a database with no activity types
- **THEN** the following activity types are created in order:
  1. Pembukaan
  2. Main Bebas
  3. Circle Time (Berdoa dan Dialog Iman)
  4. Multi Sensory
  5. Kudapan Pagi
  6. Read Aloud & Pembelajaran Al Quran
  7. Tematic
  8. Penutup

#### Scenario: Seed data is idempotent
- **WHEN** the seed migration runs on a database that already has the default activity types
- **THEN** no duplicate records are created

---

### Requirement: Admin UI for activity type management
The system SHALL provide an admin page for managing activity types with list view, create, edit, and delete actions.

#### Scenario: Admin views activity type list
- **WHEN** SUPERADMIN navigates to the activity types admin page
- **THEN** a table displays all activity types with columns: name, description, order, status, and action buttons

#### Scenario: Admin creates activity type via modal
- **WHEN** SUPERADMIN clicks the "Add" button and fills in the form
- **THEN** a modal appears with name (required), description (optional), and display order (optional) fields; on submit, the new activity type appears in the list

#### Scenario: Admin edits activity type via modal
- **WHEN** SUPERADMIN clicks the "Edit" button on an activity type row
- **THEN** a modal appears pre-filled with the current values; on submit, the list refreshes with updated data

#### Scenario: Admin deletes activity type with confirmation
- **WHEN** SUPERADMIN clicks the "Delete" button on an activity type row
- **THEN** a confirmation dialog appears; on confirm, the activity type is soft-deleted and visually marked as inactive or removed from the default list
