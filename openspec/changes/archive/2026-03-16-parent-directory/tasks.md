## 1. Backend parent management

- [x] 1.1 Add `parents` repository and service support for creating, listing, and viewing parent records.
- [x] 1.2 Validate parent records against existing managed `PARENT` users through exported `UsersService` access rather than direct repository access.
- [x] 1.3 Add superadmin-only parent endpoints for `GET /parents`, `POST /parents`, and `GET /parents/:id` with validation and structured errors.

## 2. Frontend parent administration UI

- [x] 2.1 Add a superadmin screen for listing parent records.
- [x] 2.2 Add a create-parent form and detail-view behavior wired to the new backend APIs.
- [x] 2.3 Add non-superadmin unauthorized or unavailable UI handling for the parent management screen.

## 3. Verification

- [x] 3.1 Add backend tests for parent creation, listing, detail lookup, invalid linked parent users, unauthenticated access, and forbidden non-superadmin access.
- [x] 3.2 Add frontend or integration verification for parent management flows.
- [x] 3.3 Document the parent directory endpoints in Swagger and confirm the capability is ready for `student-parent-mapping` and personal notification dependencies.
