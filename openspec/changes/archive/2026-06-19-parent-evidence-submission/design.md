## Context

The system already has a complete chain for teacher-side daily reporting: `DailyClassReport` → `StudentDailyRecord` → `StudentFocusEntry` → `EvidenceMedia`. Parents can view published daily activities via the `student-daily-activities` module (`GET /parents/students/:studentId/daily-activities`).

The `evidence_media` table already includes a `parent_evidence_id` FK column (nullable), created during the `evidence-media-upload` change. However, the `parent_evidences` table it should reference does not yet exist. This change creates that table and the surrounding CRUD module.

Existing modules relevant to this change:
- `parents/` — Parent entity CRUD, `ParentsService`
- `student-parent-maps/` — `IsParentOfStudentGuard` enforces parent-student linkage
- `evidence-media/` — Upload/list/delete media with `parentEvidenceId` context reference
- `student-daily-activities/` — Pattern for parent-scoped student endpoints

## Goals / Non-Goals

**Goals:**
- Create the `parent_evidences` table and `ParentEvidenceEntity` with correct FKs
- Add a FK constraint from `evidence_media.parent_evidence_id` → `parent_evidences.id`
- Provide CRUD endpoints for parents to submit, list, view, and update their evidence
- Enforce ownership: parents only access evidence for their linked students
- Provide frontend API client and pages for evidence submission and browsing
- Emit a domain event placeholder for `parent_evidence.submitted`

**Non-Goals:**
- Teacher-side review workflow for parent evidence (Phase 2/3 concern)
- Notification delivery when evidence is submitted (separate `daily-report-notification` capability)
- DELETE endpoint for parent evidence — parents can update but not delete (keeps audit trail)
- AI consumption of parent evidence data (Phase 2 `ai-report-narration`)

## Decisions

### 1. Module placement: new `parent-evidences/` module

**Decision**: Create a standalone `parent-evidences/` module under `src/modules/`.

**Rationale**: Follows the existing module-per-domain pattern (similar to `daily-class-reports/`, `evidence-media/`). The module encapsulates its own entity, service, controller, and DTOs. It imports `StudentParentMapsModule` for the ownership guard and uses `EvidenceMediaModule` services for listing attached media.

**Alternatives considered**:
- Extending the `parents/` module: Rejected because it would bloat the parent CRUD module with unrelated domain logic.
- Adding to `student-daily-activities/`: Rejected because parent evidence is independent of the daily report timeline — parents submit evidence on any date, not necessarily tied to a specific `DailyClassReport`.

### 2. Ownership enforcement: reuse `IsParentOfStudentGuard`

**Decision**: Reuse the existing `IsParentOfStudentGuard` from `student-parent-maps/guards/` for routes that take `studentId` as a param. For routes that operate on a specific `ParentEvidence` record (GET/:id, PATCH/:id), add a service-level ownership check comparing `parentEvidence.parentId` with the authenticated user's parent record.

**Rationale**: This mirrors the pattern in `student-daily-activities/` controller and keeps authorization consistent across parent-facing endpoints.

### 3. API route design: `/parent-evidences`

**Decision**: Mount CRUD endpoints at `/parent-evidences` with query-based filtering by `studentId` and `date`.

```
POST   /parent-evidences                    # Create evidence
GET    /parent-evidences?studentId=&date=    # List evidence (filtered)
GET    /parent-evidences/:id                 # Get single evidence detail
PATCH  /parent-evidences/:id                 # Update evidence text
```

**Rationale**: Follows the PRD endpoint design (`/parent-evidences`). Filtering by `studentId` is required since a parent may have multiple children. Query-based filtering is simpler than nesting under `/parents/students/:studentId/evidences` and aligns with the PRD.

### 4. FK migration strategy: add FK constraint in same migration

**Decision**: The migration creates `parent_evidences` table AND adds a FK constraint from `evidence_media.parent_evidence_id` → `parent_evidences.id`. This is safe because the existing `parent_evidence_id` column in `evidence_media` is nullable and currently always NULL (no `ParentEvidence` records exist yet).

**Rationale**: Adding the FK ensures referential integrity from the start. Since no data references `parent_evidence_id` today, the constraint will apply cleanly.

### 5. No delete endpoint

**Decision**: Omit `DELETE /parent-evidences/:id` from this change.

**Rationale**: The PRD lists only `GET`, `POST`, `GET/:id`, and `PATCH/:id` for parent evidences. Keeping submitted evidence (even updated) maintains an audit trail and is important for Phase 2 AI report generation which consumes accumulated parent evidence data.

### 6. Parent ID resolution

**Decision**: Resolve the authenticated user's `parentId` by querying the `parents` table via `user_id`. This is done in the service layer, not via a new guard.

**Rationale**: The `IsParentOfStudentGuard` verifies the student linkage, but we also need the `parentId` to stamp on the `ParentEvidence` record. A simple service call `parentsService.getParentByUserId(userId)` (already exists) handles this.

## Risks / Trade-offs

- **Risk**: Migration adds FK to existing `evidence_media` table → could fail if orphaned `parent_evidence_id` values exist.
  → **Mitigation**: The column is always NULL today (verified via code search). Migration is safe.

- **Risk**: No delete endpoint means parents cannot remove accidentally submitted evidence.
  → **Mitigation**: PATCH allows clearing `evidenceText`. Media attached can be individually deleted via the existing `DELETE /evidence-media/:id` endpoint.

- **Trade-off**: Query-based filtering (`?studentId=`) over nested routes means the guard setup is slightly different from `student-daily-activities` (which uses `/:studentId/` in the path).
  → **Mitigation**: Use a custom guard or service-level check to validate `studentId` from query params on the list endpoint.

## Open Questions

None — the PRD is specific enough about the domain model and endpoints for this capability.
