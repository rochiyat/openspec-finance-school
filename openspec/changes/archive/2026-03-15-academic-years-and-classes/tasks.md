## 1. Backend academic year management

- [x] 1.1 Add `academic-years` service and repository support for creating and listing academic years.
- [x] 1.2 Enforce the single-active-academic-year rule in service logic and responses.
- [x] 1.3 Add superadmin-only academic year endpoints with validation and structured errors.

## 2. Backend class management

- [x] 2.1 Add `classes` service and repository support for creating and listing classes linked to academic years.
- [x] 2.2 Validate homeroom teacher assignments through exported `UsersService` access and reject non-`GURU` users.
- [x] 2.3 Add superadmin-only class endpoints with validation and structured errors.

## 3. Frontend administration UI

- [x] 3.1 Add a superadmin screen for listing academic years and classes.
- [x] 3.2 Add create forms for academic years and classes wired to the new backend APIs.
- [x] 3.3 Add non-superadmin unauthorized or unavailable UI handling for this master data screen.

## 4. Verification

- [x] 4.1 Add backend tests for academic year creation/listing, active-year switching, class creation/listing, invalid teacher assignment, unauthenticated access, and forbidden non-superadmin access.
- [x] 4.2 Add frontend or integration verification for academic year and class administration flows.
- [x] 4.3 Document the academic year and class administration endpoints in Swagger and confirm the capability is ready for `student-directory` implementation.
