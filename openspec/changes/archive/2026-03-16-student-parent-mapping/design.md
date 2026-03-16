## Context

The codebase now has real student records and parent records, but there is still no relationship layer that answers which parents belong to which students. The PRD explicitly models `StudentParentMap` with `is_primary`, so the next MVP dependency is a dedicated mapping capability that links existing student and parent entities without breaking module ownership boundaries.

## Goals / Non-Goals

**Goals:**
- Let superadmin create student-parent mappings.
- Support listing parents for a student and students for a parent.
- Enforce PRD rules that one parent can have many students and each student must have at least one primary parent.
- Provide a basic frontend administration interface for linking students and parents.

**Non-Goals:**
- Parent self-service relationship management.
- Automatic mapping from imported family data.
- Advanced custody or guardian relationship types beyond `is_primary`.

## Decisions

### Decision: Implement a dedicated student-parent-maps module with its own repository and service
The relationship itself is its own domain record in the PRD, so it should not be embedded directly inside students or parents. A dedicated module keeps mapping lifecycle concerns separate while allowing both student and parent modules to remain authoritative for their own records.

Alternative considered: storing arrays of parent ids on students or student ids on parents. This was rejected because it would make primary-parent rules harder to enforce and would blur ownership boundaries.

### Decision: Validate student and parent references through exported services
Each mapping references an existing student and parent, and backend module boundaries require repositories to stay private to their owning services. The mapping service should therefore validate via `StudentsService` and `ParentsService` rather than accessing repositories directly.

Alternative considered: trusting raw ids from the client without validation. This was rejected because it would allow invalid links and break parent-facing access assumptions.

### Decision: Enforce one primary parent per student at the mapping layer
The PRD states that one student must have at least one primary parent. For MVP, the simplest stable rule is to ensure a student can have multiple mappings but only one mapping flagged `is_primary` at a time, and the first mapping created for a student should normally be primary.

Alternative considered: allowing multiple primary parents. This was rejected because it weakens the meaning of `is_primary` and complicates notification targeting.

### Decision: Start with create and query flows only
The PRD only lists create and read endpoints for this capability, so the first version should focus on creating mappings and reading them in both directions. This keeps the change small and aligned with downstream notification and billing use cases.

Alternative considered: adding delete or reassign endpoints immediately. This was rejected because it is not required by the current PRD endpoints.

## Risks / Trade-offs

- In-memory mapping state will not survive restarts -> Mitigation: keep DTOs and service logic straightforward to migrate to persistent storage later.
- Primary-parent enforcement could block some admin corrections -> Mitigation: keep validation explicit and add a later adjustment capability if the workflow proves too rigid.
- Duplicate mapping attempts may happen as data grows -> Mitigation: reject repeated student-parent pairs in service logic.
- Future relationship types may need richer metadata -> Mitigation: keep the mapping record additive so new fields can be introduced later.

## Migration Plan

- Add backend `student-parent-maps` module with superadmin-only create/list APIs.
- Reuse `StudentsService` and `ParentsService` for linked-record validation.
- Add frontend linking UI alongside the existing superadmin master-data screens.
- Use this capability as the prerequisite for parent billing visibility and personal notifications.

## Open Questions

- None for MVP; the PRD is specific enough to implement create and read mapping flows directly.
