## Why

Parent records are required before student-parent mapping and personal notification delivery can work correctly. The PRD defines `Parent` as a first-class domain entity with contact data and a linked user account, so this master data capability needs to exist before relationship mapping and parent-facing billing visibility can be completed.

## What Changes

- Add parent directory requirements for creating, listing, and viewing parent records.
- Define superadmin administration flows for parent master data linked to existing parent user accounts.
- Validate parent contact information and referenced `PARENT` user identities.
- Add a basic frontend management UI for viewing and managing parent records.

## Capabilities

### New Capabilities
- `parent-directory`: Manage parent master data, including linked parent user identity and contact information.

### Modified Capabilities

## Impact

- APIs: adds `GET /parents`, `POST /parents`, and `GET /parents/:id`.
- Backend modules: introduces or expands the `parents` module and validates references to managed `PARENT` users.
- Frontend: adds a basic parent management screen for superadmin administration.
- Delivery dependency: unblocks `student-parent-mapping`, personal notifications, and parent-facing billing visibility using real parent records.
