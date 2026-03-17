## 1. Backend — Data Model & Repository

- [x] 1.1 Create `Notification` interface/entity with fields: `id`, `userId`, `title`, `body`, `isRead`, `createdAt`.
- [x] 1.2 Implement `NotificationsRepository` with in-memory map storing notifications.
- [x] 1.3 Add repository methods: `findAllByUserId`, `findById`, `save`.
- [x] 1.4 Write unit tests for `NotificationsRepository`.

## 2. Backend — DTOs & Service

- [x] 2.1 Create `NotificationResponseDto` and `NotificationListResponseDto`.
- [x] 2.2 Implement `NotificationsService` with methods: `listPersonalNotifications(userId)`, `markAsRead(userId, notificationId)`, `markAllAsRead(userId)`.
- [x] 2.3 Implement unauthorized boundary explicitly (ensure a user can only read/update their own notifications).
- [x] 2.4 Write unit tests for `NotificationsService`.

## 3. Backend — Controller & Module

- [x] 3.1 Implement `NotificationsController` with endpoints: `GET /notifications`, `PATCH /notifications/:id/read`, `PATCH /notifications/read-all`.
- [x] 3.2 Add `BearerAuthGuard` and standard Swagger documentation to the controller.
- [x] 3.3 Create `NotificationsModule` and register in `AppModule`.
- [x] 3.4 Create E2E tests for the new endpoints verifying chronological sorting, unread count implications, and authorization barriers.

## 4. Frontend — Integration & State

- [x] 4.1 Update `auth.ts` to include `Notification` interface and API client functions (`fetchNotifications`, `markNotificationRead`, `markAllNotificationsRead`).
- [x] 4.2 Add React state variables in `ParentDashboardPage.tsx` or a dedicated component for `notifications` and `unreadCount`.

## 5. Frontend — User Interface

- [x] 5.1 Add a notification bell icon (with unread badge) to the user's view (primarily Parent dashboard).
- [x] 5.2 Build a list/dropdown/modal view that displays notifications chronologically.
- [x] 5.3 Wire the "mark as read" functions to individual notification clicks and a global "Mark all as read" button.
