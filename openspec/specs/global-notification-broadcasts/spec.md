# Spec: Global Notification Broadcasts

## Requirement: Access Control (Superadmin/Finance only)
The system MUST restrict access to the Broadcast feature to users with `SUPERADMIN` or `FINANCE` roles.

#### Scenario: Authorized Broadcast
- **GIVEN** a user with the `SUPERADMIN` or `FINANCE` role is logged in.
- **WHEN** they submit a POST request to `/api/notifications/broadcast`.
- **THEN** the system generates notifications for the specified group and returns `201 Created`.

#### Scenario: Unauthorized Broadcast
- **GIVEN** a user with the `GURU` or `PARENT` role is logged in.
- **WHEN** they submit a POST request to `/api/notifications/broadcast`.
- **THEN** the system returns `403 Forbidden`.

## Requirement: Targeting by User Role
The system MUST allow targeting specific group roles for a broadcast.

#### Scenario: Broadcast to Parents only
- **GIVEN** 10 Superadmins, 5 Teachers, and 50 Parents are in the system.
- **WHEN** a broadcast is sent with `recipientGroup: 'PARENTS'`.
- **THEN** 50 notifications are created in total.
- **AND** all 50 belong to users with the `PARENT` role.
- **AND** zero notifications are created for Superadmins or Teachers.

#### Scenario: Broadcast to All Users
- **GIVEN** 65 total users in the system.
- **WHEN** a broadcast is sent with `recipientGroup: 'ALL'`.
- **THEN** exactly 65 notifications are created.

## Requirement: Message Content
The system MUST ensure that the broadcast message contains a valid title and body.

#### Scenario: Missing Content
- **WHEN** a broadcast is submitted with an empty title or body.
- **THEN** the system returns `400 Bad Request`.

## Requirement: Frontend UI and Role-Gate
The frontend MUST show the "Compose Broadcast" feature only to authorized users.

#### Scenario: Visibility
- **WHEN** a `FINANCE` user views the notifications page.
- **THEN** they see the "Create Broadcast" button.
- **WHEN** a `PARENT` user views the notifications page.
- **THEN** they do NOT see the "Create Broadcast" button.
