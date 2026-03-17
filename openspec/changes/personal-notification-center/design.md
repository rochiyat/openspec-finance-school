# Design: Personal Notification Center

## Context
Parents and students currently do not have a dedicated place to view notifications sent by the system (such as billing reminders, payment confirmations, and system alerts). Instead of relying strictly on external channels (e.g., email or SMS) which may be lost or ignored, an in-app notification center provides a reliable history of important events.

## Goals / Non-Goals

**Goals:**
- Provide a persistent in-app inbox for notifications.
- Track read/unread status for each notification.
- Provide APIs to list notifications for the authenticated user and mark them as read.
- Provide a simple UI component in the frontend to display notifications.

**Non-Goals:**
- Complex notification routing (e.g., opting in/out of specific channels).
- Real-time push notifications (e.g., WebSockets/SSE) — a simple polling or on-load fetch is sufficient for this v1.
- Replying to notifications.

## Decisions

### 1. Data Model
Create an in-memory `Notification` entity (since the current backend uses in-memory repositories).
Fields:
- `id`: string
- `userId`: string (the recipient of the notification)
- `title`: string
- `body`: string
- `isRead`: boolean (default `false`)
- `createdAt`: string (ISO datetime)

### 2. API Endpoints
- `GET /api/notifications`: Fetch all notifications for the authenticated user (`@CurrentUser`). Support basic chronological sorting (newest first).
- `PATCH /api/notifications/:id/read`: Mark a specific notification as `isRead: true`.
- `PATCH /api/notifications/read-all`: Mark all unread notifications for the user as read.

*(Note: Creating a notification will be done internally via a service method when events occur, e.g., when a payment is verified, but an internal `POST` or specialized controller could be built if needed for testing).*

### 3. Backend Architecture
- **Module**: `NotificationsModule`
- **Controller**: `NotificationsController`
- **Service**: `NotificationsService`
- **Repository**: `NotificationsRepository`

### 4. Frontend Integration
- **State/Client**: Add functions in `auth.ts` (`fetchNotifications`, `markNotificationRead`, `markAllNotificationsRead`).
- **UI Component**: In the parent dashboard (and optionally other roles), add a "Notification Bell" icon that displays an unread count. Clicking it opens a dropdown or modal displaying recent notifications.

## Risks / Trade-offs
- **In-Memory Storage**: Using an in-memory repository means notifications will be lost on server restart. This is consistent with the rest of the application's current design but means the feature's persistence is ephemeral.
- **Performance**: Fetching all notifications might become slow if a user has hundreds, but pagination may be omitted for this initial version to keep it simple.
