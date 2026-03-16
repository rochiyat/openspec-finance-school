## 1. Backend student management

- [x] 1.1 Add `students` repository and service support for creating, listing, viewing, and updating student records.
- [x] 1.2 Validate student references to existing academic years and classes through exported services rather than direct repository access.
- [x] 1.3 Add superadmin-only student endpoints for `GET /students`, `POST /students`, `GET /students/:id`, and `PATCH /students/:id` with validation and structured errors.

## 2. Frontend student administration UI

- [x] 2.1 Add a superadmin screen for listing student records.
- [x] 2.2 Add create and update student forms wired to the new backend APIs.
- [x] 2.3 Add non-superadmin unauthorized or unavailable UI handling for the student management screen.

## 3. Verification

- [x] 3.1 Add backend tests for student creation, listing, detail lookup, update flow, invalid academic structure references, unauthenticated access, and forbidden non-superadmin access.
- [x] 3.2 Add frontend or integration verification for student management flows.
- [x] 3.3 Document the student directory endpoints in Swagger and confirm the capability is ready for parent mapping and billing assignment dependencies.
