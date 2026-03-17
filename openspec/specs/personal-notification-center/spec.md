## ADDED Requirements

### Requirement: Personal Notification Listing
The system should allow an authenticated user to request their personal notifications in chronological order (newest first). A notification has a `title`, `body`, `isRead` flag, and `createdAt` timestamp.

#### Scenario: User checks their inbox
- **WHEN** a user makes a GET request to `/api/notifications`
- **THEN** the system returns a list of notifications associated with the user's `id`, sorted with the most recent notifications at the top.

### Requirement: Notification Unread Count
The system should provide a way (either via a property on the listing endpoint or a separate endpoint) to return the total number of unread notifications for a given user. For simplicity, counting `isRead === false` from the listing response is sufficient.

#### Scenario: User sees unread badge
- **WHEN** a user loads the dashboard and calls `/api/notifications`
- **THEN** they can identify the number of notifications that have `isRead: false`.

### Requirement: Notification Read Status
The system should allow a user to mark individual notifications or all notifications as read. A notification once marked as read stays read.

#### Scenario: User marks a notification as read
- **WHEN** a user makes a PATCH request to `/api/notifications/:id/read`
- **THEN** the specified notification is updated to have `isRead: true`.

#### Scenario: User marks all notifications as read
- **WHEN** a user makes a PATCH request to `/api/notifications/read-all`
- **THEN** all unread notifications associated with the user's `id` are updated to have `isRead: true`.

### Requirement: Unauthorized Notification Access Prevention
A user should only be able to view and manage their own notifications.

#### Scenario: User tries to mark someone else's notification as read
- **WHEN** a user makes a PATCH request to `/api/notifications/:id/read` for a notification belonging to another user
- **THEN** the system returns a 404/403 (Not Found or Forbidden) to prevent unauthorized access.

### Requirement: Event Dispatch Upon Important Domain Actions
The system SHALL emit semantic domain events when state-changing financial operations occur. All such events must carry enough contextual information (e.g., entity IDs, monetary amounts, descriptive titles).

#### Scenario: Payment successfully processed emits an event
- **WHEN** a payment is successfully processed via `POST /payments`
- **THEN** the system fires a `payment.created` event containing the resulting `Payment` object and related identifiers (`billingId`, `studentId`).

### Requirement: Triggering Personal Notifications from Domain Events
The system SHALL intercept specified domain events and reliably create a personal notification for the relevant parent(s) mapping to the student involved. The message content MUST be dynamically generated based on the event payload.

#### Scenario: `payment.created` event maps to a parent notification
- **WHEN** a `payment.created` event is emitted by the system
- **THEN** the notification trigger service determines the primary parent(s) mapping to the student who made the payment
- **AND** the system calls the notifications service to generate a new personal message containing the payment details (e.g. payment code and amount).
