## Context

The Iqrolife school system already has:
- **Classes** (with `homeroomTeacherId`) and **Students** (with `classId`) from the financial module.
- **EducationFocus** + **FocusChecklist** master data, fully CRUD-enabled.
- **ActivityType** master data with 8 seeded types.
- **EvidenceMedia** with Cloudinary upload, polymorphic FK columns (`student_daily_record_id`, `student_focus_entry_id`, `parent_evidence_id`).

This change introduces the transactional core: a `DailyClassReport` record per class per day that ties all these together, with nested student records, focus entries, and checklist results.

The existing `ClassEntity` uses `homeroomTeacherId` (FK → `users.id`) to identify the facilitator. The `StudentEntity` uses `classId` to link students to a class and `statusActive` to filter currently enrolled students.

## Goals / Non-Goals

**Goals:**
- Provide a `daily-class-reports` NestJS module with full CRUD + publish workflow.
- Model 5 new entities: `DailyClassReport`, `DailyActivitySelection`, `StudentDailyRecord`, `StudentFocusEntry`, `StudentFocusCheckResult`.
- Enforce one-report-per-class-per-day via unique constraint on `(class_id, report_date)`.
- Enforce facilitator ownership — only the homeroom teacher of a class can create/edit its reports.
- Auto-populate `StudentDailyRecord` rows from the class roster on report creation.
- Provide a mobile-first facilitator form in the frontend.
- Keep all queries scoped to the authenticated user's assigned class.

**Non-Goals:**
- Offline mode or service worker caching.
- Multi-facilitator co-editing on a single report.
- Real-time collaborative editing.
- Push notifications on publish (handled by `daily-report-notification` change).
- Parent-facing views (handled by `parent-activity-view` change).

## Decisions

### Decision 1: Single backend module `daily-class-reports`

**Choice**: All 5 entities live in one NestJS module (`daily-class-reports`).

**Rationale**: These entities are tightly coupled — a `DailyClassReport` is always created with its `DailyActivitySelection`s, `StudentDailyRecord`s, `StudentFocusEntry`s, and `StudentFocusCheckResult`s. Splitting into multiple modules would create excessive cross-module dependencies and complicate transaction management.

**Alternative considered**: Separate `student-focus-entries` module. Rejected because focus entries only make sense in the context of a daily report and share the same transaction boundary.

### Decision 2: Flat REST endpoints, not deeply nested

**Choice**: Follow PRD endpoints structure:
- `POST /daily-class-reports` — create report (with activity selections in body)
- `GET /daily-class-reports` — list with filters
- `GET /daily-class-reports/:id` — full detail with nested student records
- `PATCH /daily-class-reports/:id` — update notes/activities
- `POST /daily-class-reports/:id/publish` — status transition
- `POST /daily-class-reports/:reportId/students/:studentId/focus-entries` — add focus entry
- `PATCH /daily-class-reports/:reportId/students/:studentId/focus-entries/:entryId` — update entry

**Rationale**: The PRD explicitly defines these routes. The nested `/students/:studentId/focus-entries` path naturally scopes entries to a specific student within a report without requiring separate authorization checks.

### Decision 3: Report creation auto-populates student records

**Choice**: When a `POST /daily-class-reports` is made, the service queries all active students in the class and bulk-inserts `StudentDailyRecord` rows.

**Rationale**: The facilitator should not manually add students — the class roster defines who's present. This keeps the form flow fast (< 5 minutes target). If attendance tracking is needed later, a boolean flag can be added to `StudentDailyRecord`.

### Decision 4: Cascading focus entry creation with check results

**Choice**: `POST .../focus-entries` accepts an `educationFocusId`, optional `evidenceText`, and an array of `checkResults` (each with `focusChecklistId` and `isChecked`). The service creates the `StudentFocusEntry` and its `StudentFocusCheckResult` rows in a single transaction.

**Rationale**: Focus entry + check results are conceptually atomic — a teacher selects a focus and immediately checks items. Splitting into multiple API calls would degrade the mobile form experience and risk partial data.

### Decision 5: TypeORM migration for 5 new tables

**Choice**: Single migration file creating all 5 tables with proper FK constraints, unique index on `(class_id, report_date)`, and indexes on all FK columns.

**Rationale**: These tables are interdependent and should be deployed atomically. Using TypeORM's `Table` and `TableForeignKey` APIs matches the existing migration pattern.

### Decision 6: Frontend uses a single-page form with collapsible student cards

**Choice**: The daily report form is a single page:
1. Top: date picker (defaults to today), notes textarea, activity type checkboxes.
2. Below: collapsible cards for each student, each expanding to show focus selection, checklist toggles, and evidence text.
3. Actions: "Save Draft" and "Publish" buttons.

**Rationale**: Mobile-first, minimal navigation. The teacher should be able to fill everything without page transitions. Auto-save or explicit save keeps data safe.

## Risks / Trade-offs

- **Large class roster**: A class with 30+ students means 30+ `StudentDailyRecord` inserts on creation. → Mitigation: bulk insert via TypeORM's `save([...])` in a single transaction. Acceptable for expected class sizes (15–30 students).

- **Form complexity on mobile**: Many students × multiple focuses × checklist items can create a long scrollable form. → Mitigation: Collapsible student cards (only expand the student being worked on), sticky header with save button.

- **Published report immutability**: Once published, the report should be locked for the teacher. → Mitigation: `PATCH` endpoint checks status — if `PUBLISHED`, only `SUPERADMIN` can edit. Teacher must create a new report or contact admin.

- **Concurrent report creation**: Two teachers could attempt to create a report for the same class on the same day. → Mitigation: DB unique constraint on `(class_id, report_date)` prevents duplicates; service returns 409 Conflict.

- **FK references to Iqrolife-synced tables**: `classes`, `students` are synced from Iqrolife and use varchar PKs. → Mitigation: Use `varchar` FK type in migration, matching existing entity definitions.
