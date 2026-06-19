## Why

Teachers (facilitators) need to record daily class activities, per-student education focus observations, checklist results, and evidence — all in one place. Today, this is done manually. The `education-focus-management`, `activity-type-management`, and `evidence-media-upload` capabilities are already implemented and provide the master data and media infrastructure. This change introduces the core transactional entities and APIs that tie them together: creating a daily class report, selecting the activities performed, recording per-student focus entries with checklist results, and attaching evidence. It is the highest-priority Phase 1 capability that all downstream features (parent-activity-view, parent-evidence-submission, reports) depend on.

## What Changes

- Introduce `DailyClassReport` entity — one report per class per day with status `DRAFT` / `PUBLISHED`.
- Introduce `DailyActivitySelection` join entity — links a report to the activity types performed that day.
- Introduce `StudentDailyRecord` entity — per-student participation record within a daily report.
- Introduce `StudentFocusEntry` entity — records which education focus was observed for a student, with narrative evidence text.
- Introduce `StudentFocusCheckResult` entity — stores individual checklist check states per focus entry.
- Provide REST API endpoints for creating, listing, updating, publishing daily class reports and managing nested student records.
- Auto-populate student records from the class roster when creating a report.
- Enforce unique constraint: one report per `class_id + report_date`.
- Enforce facilitator ownership: only the homeroom teacher of a class can create/edit its reports.
- Provide a mobile-first frontend form for daily report input targeting < 5 minutes total input time.

## Capabilities

### New Capabilities
- `daily-class-report-crud`: DailyClassReport and DailyActivitySelection CRUD, including create, list (with date/class filters), get detail, update, and publish workflow (DRAFT → PUBLISHED). Enforces unique-per-class-per-day and facilitator-ownership rules.
- `student-daily-record-management`: StudentDailyRecord, StudentFocusEntry, and StudentFocusCheckResult management — creating per-student entries, selecting education focuses, checking off checklist items, and adding evidence text. Nested under a daily class report.
- `daily-report-form-ui`: Mobile-first frontend form for the facilitator daily input flow — select activities, expand per-student cards, pick focuses, check checklists, write evidence, and publish.

### Modified Capabilities
_(none — all new entities; existing specs unchanged)_

## Impact

- **Database**: 5 new tables (`daily_class_reports`, `daily_activity_selections`, `student_daily_records`, `student_focus_entries`, `student_focus_check_results`) with foreign keys to existing `classes`, `users`, `students`, `activity_types`, `education_focuses`, and `focus_checklists` tables.
- **Backend**: New `daily-class-reports` NestJS module with controller, service, repository, entities, and DTOs. Depends on `classes`, `students`, `activity-types`, `education-focuses`, and `evidence-media` modules.
- **Frontend**: New facilitator daily form page and associated API client. Adds route under the teacher/facilitator portal.
- **Auth**: Requires `GURU` role for report creation/editing; `SUPERADMIN` can force-edit published reports.
- **Downstream**: This is the foundation for `parent-activity-view`, `parent-evidence-submission`, `student-report-generation`, and `daily-report-notification`.
