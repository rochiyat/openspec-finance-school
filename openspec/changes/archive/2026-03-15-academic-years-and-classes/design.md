## Context

The codebase already has auth, superadmin user management, and the first pieces of master data scaffolding. The next prerequisite for student records and teacher-facing views is to establish `AcademicYear` and `Class` management as first-class data owned by dedicated backend modules and exposed to superadmin through basic administration screens.

## Goals / Non-Goals

**Goals:**
- Let superadmin create and list academic years with one active year at a time.
- Let superadmin create and list classes that belong to an academic year.
- Allow class records to store a homeroom teacher assignment using existing user-role identities.
- Provide a basic frontend management UI for academic years and classes.

**Non-Goals:**
- Student enrollment, class assignment bulk import, or class promotion workflows.
- Teacher self-service profile management.
- Academic calendar automation or year rollover logic.

## Decisions

### Decision: Implement academic years and classes as separate but coordinated modules
The PRD models `AcademicYear` and `Class` as distinct entities, so each should have its own backend service and repository while exposing APIs that let the UI manage them together. This keeps domain ownership clear and makes later student and dashboard features easier to build.

Alternative considered: a single combined master-data module for both entities. This was rejected because it would blur ownership and make future capability boundaries less clear.

### Decision: Restrict administration to superadmin-only endpoints
Academic years and classes are system configuration data rather than operational end-user data. Superadmin should control these endpoints, matching the earlier access management pattern already in place.

Alternative considered: allowing finance or teacher roles to edit class data. This was rejected because the PRD only assigns system-wide configuration authority to superadmin.

### Decision: Enforce a single active academic year in service logic
The domain model includes `is_active`, and downstream features will depend on exactly one active year to resolve the current operating context. The academic year service should therefore deactivate any existing active year when a new one is marked active.

Alternative considered: allowing multiple active years and leaving interpretation to consuming modules. This was rejected because it would introduce ambiguity into student, billing, and dashboard flows.

### Decision: Resolve homeroom teachers through exported user services
Class records need `homeroom_teacher_id`, but repository ownership must remain inside each module. The classes service should validate referenced teacher users through `UsersService` rather than importing user repositories directly.

Alternative considered: storing a raw teacher identifier without validation. This was rejected because it would allow invalid references and weaken module boundaries.

## Risks / Trade-offs

- In-memory persistence keeps scope small but does not survive restarts -> Mitigate by keeping service contracts compatible with later database-backed repositories.
- Enforcing one active academic year may surprise admins during updates -> Mitigate by making the toggle explicit in service behavior and response messaging.
- Homeroom teacher validation depends on user-role correctness -> Mitigate by rejecting assignments to users without the `GURU` role.
- UI scope could expand into full master data dashboards -> Mitigate by keeping the screen focused on create/list/basic management only.

## Migration Plan

- Add backend `academic-years` and `classes` modules with superadmin-only APIs.
- Reuse auth/session and user-role foundations for authorization and teacher validation.
- Add frontend administration views for academic years and classes.
- Use this capability as the dependency base for `student-directory` and teacher-scoped features.

## Open Questions

- None for MVP; the PRD is specific enough to implement create/list/active-year/class-teacher management directly.
