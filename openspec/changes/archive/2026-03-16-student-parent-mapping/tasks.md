## 1. Backend mapping management

- [x] 1.1 Add `student-parent-maps` repository and service support for creating mappings and querying them by student or parent.
- [x] 1.2 Validate linked students and parents through exported `StudentsService` and `ParentsService` access rather than direct repository access.
- [x] 1.3 Enforce duplicate-mapping prevention and primary-parent rules in service logic.
- [x] 1.4 Add superadmin-only endpoints for `POST /student-parent-maps`, `GET /students/:id/parents`, and `GET /parents/:id/students` with structured errors.

## 2. Frontend mapping administration UI

- [x] 2.1 Add a superadmin screen for listing student-parent mappings.
- [x] 2.2 Add a create-mapping form with student, parent, and primary-parent controls wired to the new backend APIs.
- [x] 2.3 Add UI views for parents by student and students by parent, plus non-superadmin unavailable handling.

## 3. Verification

- [x] 3.1 Add backend tests for mapping creation, parent lookup by student, student lookup by parent, invalid linked records, duplicate mapping rejection, primary-parent rule enforcement, unauthenticated access, and forbidden non-superadmin access.
- [x] 3.2 Add frontend or integration verification for student-parent mapping flows.
- [x] 3.3 Document the student-parent mapping endpoints in Swagger and confirm the capability is ready for parent-facing billing visibility and personal notification dependencies.
