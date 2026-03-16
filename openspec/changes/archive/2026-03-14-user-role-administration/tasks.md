## 1. Backend user-role administration APIs

- [x] 1.1 Extend `users` and `roles` services to support listing users, creating users, and updating assigned roles without exposing repositories across module boundaries.
- [x] 1.2 Add superadmin-only endpoints for listing users, creating accounts, and updating role assignments.
- [x] 1.3 Add validation and business rules for supported roles, duplicate identities, password hashing, and safe role updates.

## 2. Authorization and response contracts

- [x] 2.1 Protect all user-role administration endpoints with the existing bearer auth and superadmin role enforcement.
- [x] 2.2 Define consistent success, validation-error, unauthenticated, and forbidden response shapes for user administration APIs.

## 3. Frontend administration UI

- [x] 3.1 Add a basic superadmin administration screen to view managed users and their assigned roles.
- [x] 3.2 Add a create-user form and role update controls wired to the new backend endpoints.
- [x] 3.3 Add frontend state handling so non-superadmin sessions see an unavailable or unauthorized state.

## 4. Verification

- [x] 4.1 Add backend tests for listing users, creating users, role updates, unauthenticated access, and forbidden non-superadmin access.
- [x] 4.2 Add frontend or integration verification for user listing, create-user submission, and unauthorized UI behavior.
- [x] 4.3 Document the user-role administration endpoints in Swagger and confirm the capability is ready for downstream MVP setup work.
