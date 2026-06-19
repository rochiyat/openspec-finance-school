## Why

Parents currently cannot submit their own evidence or observations about their child's development from home. The PRD (Phase 1, capability #6) requires a `parent-evidence-submission` feature that lets parents add supplementary text evidence and media (photos/videos/documents) for their child, complementing the teacher's daily observations. This closes the home-school loop so parent perspectives are captured alongside teacher data — a prerequisite for accurate AI-generated achievement reports in Phase 2.

## What Changes

- Introduce the `ParentEvidence` entity (`parent_evidences` table) to store parent-submitted text evidence per student per date.
- Create a new `parent-evidences` NestJS module with CRUD endpoints (`POST`, `GET`, `GET/:id`, `PATCH/:id`) accessible to the `PARENT` role.
- Enforce ownership: parents can only create/view/update evidence for students linked via `StudentParentMap`.
- Integrate with the existing `evidence-media` module — parents attach media files to their `ParentEvidence` records via the `parentEvidenceId` FK already present in the `evidence_media` table.
- Add a frontend API client (`src/lib/parent-evidence.ts`) for all CRUD operations.
- Add a `ParentSubmitEvidencePage` frontend page at `/parent/evidence/submit` with form for text + media upload.
- Add a `ParentEvidenceListPage` frontend page at `/parent/evidence` to view/manage submitted evidence.
- Emit a `parent_evidence.submitted` domain event (placeholder for future notification to teachers).

## Capabilities

### New Capabilities
- `parent-evidence-crud`: Backend CRUD for `ParentEvidence` entity including database schema, service, controller, DTOs, and ownership guards. Frontend API client and submission/list pages.

### Modified Capabilities
- `evidence-media-upload`: The existing evidence-media upload flow already supports `parentEvidenceId` in its schema and API. No spec-level requirement change is needed — the FK reference is already specified and implemented.

## Impact

- **Backend**: New module `parent-evidences/` with entity, service, controller, DTOs, and migration. References existing `students`, `parents`, `student-parent-maps`, and `evidence-media` modules.
- **Database**: New `parent_evidences` table with FK to `students` and `parents`. No changes to existing `evidence_media` table (the `parent_evidence_id` FK column already exists).
- **Frontend**: New API client module, two new pages under `/parent/evidence/*`, updates to parent route configuration.
- **Dependencies**: Depends on `auth-session-access`, `student-parent-mapping`, `evidence-media-upload` (all already implemented).
