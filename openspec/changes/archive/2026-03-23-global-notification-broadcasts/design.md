# Design: Global Notification Broadcasts

## Overview
The "Broadcasts" feature enables administrators to communicate with the entire school or targeted user groups (e.g., all Parents, all Teachers) simultaneously. This is the first manual, many-to-one communication feature in the system.

---

## Backend Architecture

### Module: `NotificationsModule` (Extension)
The broadcast logic will be added to the existing `NotificationsModule`.

#### Controller: `NotificationsController`
- **New Endpoint**: `POST /api/notifications/broadcast`
- **Guards**: `BearerAuthGuard`, `RolesGuard`
- **Allowed Roles**: `SUPERADMIN`, `FINANCE`
- **Payload**: `BroadcastNotificationDto`

#### Service: `NotificationsService`
- **New Method**: `broadcast(payload: BroadcastNotificationDto): Promise<{ count: number }>`

**Broadcasting Logic**:
1. **Identify Recipients**: Fetch all users from `UsersService.listUsers()`.
2. **Filter by Role**:
   - `ALL`: No filter.
   - `PARENTS`: Keep only users with role `PARENT`.
   - `TEACHERS`: Keep only users with role `GURU`.
3. **Batch Creation**: Map the recipient list and call `createNotification()` for each.
   - *Performance Consideration*: For the MVP with a small memory-store, `Promise.all` is sufficient. For 1000+ users, this would ideally be a background queue job.
4. **Return Results**: Return total count of notifications generated.

#### DTOs
```typescript
// broadcast-notification.dto.ts
export interface BroadcastNotificationDto {
  title: string;
  body: string;
  recipientGroup: 'ALL' | 'PARENTS' | 'GURUS';
}
```

---

## Frontend Architecture

### New UI: `BroadcastPanel`
A new section or modal to be added to the existing notification center.

#### Components
- **Broadcast Trigger**: A floating action button (FAB) or "Compose Broadcast" button visible only to admins/finance.
- **Form Fields**:
  - `Recipient Group` (Select: All Users, All Parents, All Teachers).
  - `Broadcast Title` (Text input).
  - `Message Body` (Textarea).
- **Submission**: Calls `sendBroadcastNotification(token, payload)` with a loading state.

#### API Helper (in `lib/auth.ts`)
```typescript
export async function sendBroadcastNotification(token: string, payload: BroadcastNotificationDto) {
  const resp = await fetch(`${API_BASE}/notifications/broadcast`, {
    method: 'POST',
    headers: { 
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}` 
    },
    body: JSON.stringify(payload)
  });
  return handleJsonResponse(resp);
}
```

---

## Security Considerations
- **Authorization**: Only `SUPERADMIN` and `FINANCE` are allowed to access the broadcast endpoint.
- **Role Validation**: If an administrator tries to broadcast to `GURUS` but isn't authorized for that group specifically (if we add such narrow permissions later), the request should fail. For MVP, any admin can message any group.

---

## Risks / Trade-offs
- **Performance**: Broadcasting to 10k users synchronously would block the event loop in the memory-store implementation. We limit this to system-wide messages for a school (expected < 1000 total users).
- **Notification Overload**: Easy ability to broadcast could lead to "notification fatigue" for parents. We may consider adding "Critical" vs "Info" flags in the future.
