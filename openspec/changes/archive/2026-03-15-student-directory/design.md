## Context

The codebase already supports authentication, superadmin user management, and academic master data through academic years and classes. The next core dependency is student master data, because billing, parent mapping, and teacher-facing payment visibility all need stable student records with class placement and academic year linkage.

## Goals / Non-Goals

**Goals:**
- Let superadmin create, list, view, and update student records.
- Validate student references to existing academic years and classes.
- Store student identity and placement data including `nis`, full name, gender, class, academic year, and active status.
- Provide a basic frontend management interface for student master data.

**Non-Goals:**
- Parent mapping or student-parent relationship management.
- Bulk import/export, student promotion, or historical class transfer workflows.
- Teacher self-service editing of student records.

## Decisions

### Decision: Implement a dedicated students module with repository and service ownership
Student data should live in its own module because it becomes the canonical record referenced by billing, payments, parent mapping, and teacher views. This keeps the student lifecycle separate from academic structure while still validating against it through service boundaries.

Alternative considered: storing student records directly inside the classes module. This was rejected because it would tightly couple student identity to class data and make future domain expansion harder.

### Decision: Restrict student management to superadmin-only endpoints for MVP
At this stage, student master data remains administrative configuration data. Reusing the existing superadmin-only guard pattern keeps authorization simple and aligned with the earlier master-data changes.

Alternative considered: allowing teachers to update student records for their class. This was rejected because the PRD does not grant teachers financial or core data edit rights.

### Decision: Validate class and academic year references through exported services
Students must point to valid academic years and classes, but repository boundaries must remain intact. The students service should call `AcademicYearsService` and a future `ClassesService` accessor rather than reading repositories directly.

Alternative considered: trusting raw IDs from the client. This was rejected because it would allow invalid references and break downstream assumptions.

### Decision: Model student updates as partial edits over a stable identity record
The PRD exposes `PATCH /students/:id`, so the backend should support updating fields like class placement, academic year, and active status without requiring full record replacement. This matches admin workflows and keeps the API aligned with the PRD.

Alternative considered: only supporting full replace semantics. This was rejected because it adds friction to simple administrative edits.

## Risks / Trade-offs

- In-memory persistence does not survive restarts -> Mitigation: keep the service API and DTOs database-ready for a later TypeORM migration.
- Student placement can become inconsistent if class and academic year are not cross-checked -> Mitigation: validate both references and reject invalid combinations early.
- The UI could grow into a broad student information system -> Mitigation: keep MVP limited to create/list/detail/update basics only.
- Future parent and billing modules may need additional student fields -> Mitigation: keep DTOs additive and avoid overfitting the first version.

## Migration Plan

- Add backend `students` module with superadmin-only CRUD-lite APIs.
- Reuse auth/session and existing master-data modules for authorization and reference validation.
- Add frontend student administration UI that sits alongside existing superadmin master-data screens.
- Use this capability as the prerequisite for parent mapping and billing assignment.

## Open Questions

- None for MVP; the PRD provides enough structure to implement student create/list/detail/update behavior directly.
