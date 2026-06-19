## Why

Parents currently have no visibility into their child's daily class activities — the existing parent portal only covers financial data (billings, installments, payments). With the `daily-class-report-core` now producing published daily reports, parents need a read-only portal to view what their child did each day, including education focus entries, checklist achievements, and evidence media from teachers. This is Phase 1 priority #5 in the Class Activity PRD, required before POG UAT.

## What Changes

- Add two new backend endpoints scoped to the parent role:
  - `GET /parents/students/:studentId/daily-activities` — list published daily activities for a student, filterable by date range
  - `GET /parents/students/:studentId/daily-activities/:date` — detail view for a specific date, including focus entries, checklist results, evidence text, and media
- Add a new `student-daily-activities` module in the backend to encapsulate parent-facing read-only queries against existing `DailyClassReport` and related entities
- Add two new frontend pages under the parent portal:
  - **ChildActivityTimelinePage** — a timeline/list view of recent daily activities, date-filterable
  - **ChildActivityDetailPage** — detailed view of one day's report: activities performed, per-student focus entries with checklist results, evidence text, and media gallery
- Add navigation links in the parent sidebar/layout to access the activity view
- Enforce `StudentParentMap` ownership: parents only see data for their linked children
- Only `PUBLISHED` reports are visible — `DRAFT` reports are hidden from parents

## Capabilities

### New Capabilities
- `parent-daily-activity-timeline`: Read-only listing of published daily activities for a parent's linked student, with date filtering, pagination, and summary cards
- `parent-daily-activity-detail`: Detailed view of a single day's activity — activities performed, focus entries per student, checklist results, evidence text, and photo/video gallery

### Modified Capabilities
_(none — this change only reads existing data produced by `daily-class-report-core`; no spec-level behavior changes to existing capabilities)_

## Impact

- **Backend**: New `student-daily-activities` module with read-only service and controller. Depends on `DailyClassReportsRepository` queries (may extend with parent-optimized queries), `StudentParentMapsService` for ownership checks, and reuses `IsParentOfStudentGuard`.
- **Frontend**: Two new pages under `/parent/activities` and `/parent/activities/:date`. New API hooks. Updates to `AppRouter.tsx` and parent sidebar navigation.
- **APIs**: Two new `GET` endpoints under `/parents/students/:studentId/daily-activities`. No breaking changes.
- **Dependencies**: `daily-class-report-core` (entities and repository), `student-parent-mapping` (ownership guard), `evidence-media` (media URLs in responses).
