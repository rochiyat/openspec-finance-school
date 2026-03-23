## 1. Backend: Broadcast API Scaffold

- [x] 1.1 Implement `BroadcastNotificationDto` with validation (title, body, recipientGroup).
- [x] 1.2 Add `POST /api/notifications/broadcast` endpoint to `NotificationsController`.
- [x] 1.3 Add `RolesGuard(['SUPERADMIN', 'FINANCE'])` to the new endpoint.

## 2. Backend: Broadcast Service Logic

- [x] 2.1 Implement `NotificationsService.broadcast(payload)`:
    - Inject `UsersService` to list all users.
    - Filter users based on `recipientGroup` (ALL, PARENTS, GURUS).
    - Map filtered users to notifications and call `createNotification()` for each.
- [x] 2.2 Write unit tests for `NotificationsService.broadcast()` to verify correct recipient filtering and notification counts.

## 3. Frontend: Admin Broadcast Panel

- [x] 3.1 Add `sendBroadcastNotification(token, payload)` API helper to `frontend/src/lib/auth.ts`.
- [x] 3.2 Update `SuperadminDashboardPage.tsx` to include a "Compose Broadcast" button and panel:
    - Role gate the "Compose" feature (visible only to `SUPERADMIN` and `FINANCE`).
    - Form matching the `BroadcastNotificationDto`.
    - Handle loading and success/error feedback.
- [x] 3.3 Verify broadcast receipt by different user roles (Parent vs Teacher).

## 4. Verification & Testing

- [x] 4.1 Manual verification: Send a broadcast to "All Parents" and log in as a parent to see it.
- [x] 4.2 Verify "All GURUS" only sends notifications to users with the teacher role.
- [x] 4.3 Verify non-admin roles (`GURU`, `PARENT`) cannot call the broadcast API even with a token.
- [x] 4.4 Run backend unit tests and ensure all pass.
