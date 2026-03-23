# Proposal: Global Notification Broadcasts

## Purpose
Allow `SUPERADMIN` and `FINANCE` users to send manual, system-wide or targeted notification broadcasts to groups of users (e.g., all parents, all teachers).

## Motivation
Currently, all notifications are either event-driven (e.g., payment success) or manually triggered for a single user. Administrators need a way to announce school-wide updates, deadline reminders, or maintenance notices to everyone at once.

## Target Persona
- **Superadmin / Finance**: To communicate important financial or academic updates to the school community.

## Scope of Change
- **Backend**:
  - New `POST /api/notifications/broadcast` endpoint.
  - Logic to filter recipients by role (e.g., `role: 'PARENT'`).
  - Batch creation of notification records for all matching users.
- **Frontend**:
  - A "Broadcast" form/modal on the Notifications or Superadmin page.
  - Fields: Title, Body, Recipient Group (Dropdown: All, Parents, Teachers).
- **Security**:
  - Restrict broadcasting to `SUPERADMIN` and `FINANCE` roles.

## Affected Components
- `backend/src/modules/notifications/notifications.controller.ts`
- `backend/src/modules/notifications/notifications.service.ts`
- `frontend/src/pages/NotificationsPage.tsx` (or a dedicated Broadcast page)
- `frontend/src/lib/auth.ts` (helper for broadcast API)

## Dependencies
- `UsersModule`: To browse and filter users by role.
- `NotificationsModule`: To persist the broadcast for each user.

## Success Criteria
- [ ] An administrator can send a message to all 500+ parents in a single action.
- [ ] Users receive the broadcast in their notification center immediately.
- [ ] Non-admin roles cannot access the broadcast functionality.
