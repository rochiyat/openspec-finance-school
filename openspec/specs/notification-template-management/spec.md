## ADDED Requirements

### Requirement: Authorized admin can manage notification templates
The system SHALL allow authenticated `SUPERADMIN` users to create, list, view, and update notification templates.

#### Scenario: Superadmin creates a notification template
- **WHEN** an authenticated `SUPERADMIN` submits valid template data (name, channelType, body)
- **THEN** the system creates the notification template
- **AND** the response includes `id`, `name`, `channelType`, `subject`, `body`, `variables`, `isActive`, `createdBy`, and `createdAt`

#### Scenario: Superadmin lists notification templates
- **WHEN** an authenticated `SUPERADMIN` requests `GET /notification-templates`
- **THEN** the system returns all notification templates

#### Scenario: Superadmin views a notification template detail
- **WHEN** an authenticated `SUPERADMIN` requests a specific template by id
- **THEN** the system returns the full template detail

#### Scenario: Superadmin updates a notification template
- **WHEN** an authenticated `SUPERADMIN` submits a PATCH with updated fields
- **THEN** the system applies the changes and returns the updated template

### Requirement: Notification templates must have a unique name
The system MUST reject template creation when the name already exists.

#### Scenario: Duplicate template name is rejected
- **WHEN** an authenticated `SUPERADMIN` creates a template with a name that already exists
- **THEN** the system rejects the request with a conflict error

### Requirement: Notification templates support channel types and body placeholders
The system SHALL enforce that `channelType` is one of `EMAIL`, `WHATSAPP`, or `SMS`, and SHALL store a declared list of placeholder variable names.

#### Scenario: Valid channel type is accepted
- **WHEN** an authenticated `SUPERADMIN` creates a template with a valid `channelType`
- **THEN** the system stores the template with that channel type

#### Scenario: Invalid channel type is rejected
- **WHEN** an authenticated `SUPERADMIN` creates a template with an unrecognised `channelType`
- **THEN** the system rejects the request with a validation error

### Requirement: Notification template management access is limited by role
The system MUST protect notification template endpoints so only authenticated `SUPERADMIN` users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets a notification template endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Non-superadmin role is rejected
- **WHEN** an authenticated user without `SUPERADMIN` role targets a notification template endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: Templates can be deactivated
The system SHALL allow `SUPERADMIN` users to set `isActive` to `false` on an existing template via PATCH, effectively deactivating it without deletion.

#### Scenario: Superadmin deactivates a template
- **WHEN** an authenticated `SUPERADMIN` sends `PATCH /notification-templates/:id` with `{ isActive: false }`
- **THEN** the system stores the template as inactive and returns the updated record

### Requirement: MVP includes a basic notification template management interface
The system SHALL provide a basic frontend administration interface for `SUPERADMIN` to view and create notification templates.

#### Scenario: Superadmin manages templates in the UI
- **WHEN** a `SUPERADMIN` user opens the notification template management section
- **THEN** the interface shows existing templates
- **AND** the interface provides a form to create a new template

#### Scenario: Non-superadmin cannot access the template UI
- **WHEN** a user without `SUPERADMIN` role reaches the notification template management section
- **THEN** the interface does not render the section
