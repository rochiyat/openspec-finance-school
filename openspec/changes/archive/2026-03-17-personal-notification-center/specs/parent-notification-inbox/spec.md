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
