## Why

After authentication is in place, the MVP still needs a controlled way for superadmin to create and manage internal users and assign the correct operational roles. The PRD explicitly gives superadmin responsibility for managing user and role access, and downstream capabilities depend on those assignments being administrable rather than hard-coded.

## What Changes

- Add user administration requirements for creating and listing internal users.
- Add role assignment and role update requirements for `SUPERADMIN`, `FINANCE`, `GURU`, and `PARENT` users.
- Define authorization rules so only superadmin can manage users and roles.
- Establish a basic admin UI for viewing users, creating accounts, and updating role assignments.

## Capabilities

### New Capabilities
- `user-role-administration`: Let superadmin manage internal users and assign system roles needed for MVP operations.

### Modified Capabilities

## Impact

- APIs: adds user and role administration endpoints on top of the existing auth foundation.
- Backend modules: expands `users` and `roles`, and integrates with `auth` authorization rules.
- Frontend: adds basic superadmin user management screens and role assignment flows.
- Delivery dependency: unblocks real seeded-user replacement for later master data, finance, and dashboard capabilities.
