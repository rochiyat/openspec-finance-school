## ADDED Requirements

### Requirement: Admin can create a checklist item under an education focus
The system SHALL provide `POST /education-focuses/:id/checklists` to create a new checklist item associated with a specific education focus. Only users with the SUPERADMIN role SHALL be permitted.

#### Scenario: Successful creation
- **WHEN** a SUPERADMIN user sends a valid `POST /education-focuses/:focusId/checklists` request with title, description, and display_order
- **THEN** the system creates the checklist item linked to the specified education focus
- **AND** returns the created checklist with its generated UUID and `is_active` defaulting to `true`
- **AND** responds with HTTP 201

#### Scenario: Parent focus not found
- **WHEN** a SUPERADMIN user sends a `POST /education-focuses/:focusId/checklists` request for a non-existent focus
- **THEN** the system returns a not-found error with HTTP 404

#### Scenario: Non-SUPERADMIN is denied
- **WHEN** a user without the SUPERADMIN role sends a `POST /education-focuses/:focusId/checklists` request
- **THEN** the system rejects the request as forbidden

### Requirement: Checklist items are included when listing education focuses
The system SHALL include associated active checklist items when returning education focus records via `GET /education-focuses` and `GET /education-focuses/:id`. Checklist items SHALL be ordered by `display_order ASC, title ASC`.

#### Scenario: Focuses include checklists
- **WHEN** an authenticated user requests education focuses
- **THEN** each focus in the response includes an array of its active checklist items
- **AND** checklist items are ordered by `display_order` ascending, then `title` ascending

#### Scenario: Inactive checklists are excluded by default
- **WHEN** an authenticated user requests education focuses without the `includeInactive` flag
- **THEN** checklist items where `is_active` is `false` are excluded from the response

### Requirement: Admin can update a checklist item
The system SHALL provide `PATCH /education-focuses/:focusId/checklists/:checklistId` to update an existing checklist item. Only SUPERADMIN role SHALL be permitted.

#### Scenario: Successful update
- **WHEN** a SUPERADMIN user sends a valid `PATCH /education-focuses/:focusId/checklists/:checklistId` request with partial fields (title, description, display_order, is_active)
- **THEN** the system updates only the provided fields
- **AND** returns the updated checklist item

#### Scenario: Checklist item not found
- **WHEN** a SUPERADMIN user sends a `PATCH` request for a non-existent checklist item or mismatched focus ID
- **THEN** the system returns a not-found error with HTTP 404

#### Scenario: Non-SUPERADMIN is denied
- **WHEN** a user without the SUPERADMIN role sends a `PATCH` request to update a checklist
- **THEN** the system rejects the request as forbidden

### Requirement: Admin can soft-delete a checklist item
The system SHALL provide `DELETE /education-focuses/:focusId/checklists/:checklistId` to deactivate a checklist item by setting `is_active` to `false`. Only SUPERADMIN role SHALL be permitted. The record SHALL NOT be physically removed.

#### Scenario: Successful soft-delete
- **WHEN** a SUPERADMIN user sends a `DELETE /education-focuses/:focusId/checklists/:checklistId` request
- **THEN** the system sets `is_active` to `false` on the checklist item
- **AND** responds with HTTP 200

#### Scenario: Checklist item not found
- **WHEN** a SUPERADMIN user sends a `DELETE` request for a non-existent checklist item or mismatched focus ID
- **THEN** the system returns a not-found error with HTTP 404

### Requirement: Admin can manage checklist items inline on the education focus admin page
The system SHALL display checklist items inline within each education focus on the admin management page. The admin SHALL be able to add, edit, and deactivate checklist items without navigating away from the focus management page.

#### Scenario: Viewing checklists inline
- **WHEN** a SUPERADMIN user expands an education focus on the admin page
- **THEN** the system displays the associated checklist items with title, description, display_order, and active status

#### Scenario: Adding a checklist item inline
- **WHEN** a SUPERADMIN user adds a checklist item using the inline form within a focus
- **THEN** the system sends a `POST /education-focuses/:id/checklists` request
- **AND** the new checklist item appears in the list without a full page reload

#### Scenario: Display order determines rendering order
- **WHEN** checklist items are displayed on the admin page
- **THEN** items are ordered by `display_order` ascending, then `title` ascending
