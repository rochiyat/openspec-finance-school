## 1. Database Migration

- [x] 1.1 Create TypeORM migration for `daily_class_reports` table with columns, unique constraint on `(class_id, report_date)`, and FK indexes
- [x] 1.2 Create `daily_activity_selections` table with FK to `daily_class_reports` and `activity_types`, unique constraint on `(daily_class_report_id, activity_type_id)`
- [x] 1.3 Create `student_daily_records` table with FK to `daily_class_reports` and `students`, unique constraint on `(daily_class_report_id, student_id)`
- [x] 1.4 Create `student_focus_entries` table with FK to `student_daily_records` and `education_focuses`
- [x] 1.5 Create `student_focus_check_results` table with FK to `student_focus_entries` and `focus_checklists`, unique constraint on `(student_focus_entry_id, focus_checklist_id)`
- [x] 1.6 Run migration and verify all tables, constraints, and indexes are created

## 2. Backend Entities

- [x] 2.1 Create `DailyClassReportEntity` with columns, enums (`DRAFT`, `PUBLISHED`), and relations to `DailyActivitySelectionEntity` and `StudentDailyRecordEntity`
- [x] 2.2 Create `DailyActivitySelectionEntity` with FK relations to report and `ActivityTypeEntity`
- [x] 2.3 Create `StudentDailyRecordEntity` with FK relations to report and `StudentEntity`, and one-to-many to `StudentFocusEntryEntity`
- [x] 2.4 Create `StudentFocusEntryEntity` with FK relations to `StudentDailyRecordEntity` and `EducationFocusEntity`, and one-to-many to `StudentFocusCheckResultEntity`
- [x] 2.5 Create `StudentFocusCheckResultEntity` with FK relations to `StudentFocusEntryEntity` and `FocusChecklistEntity`

## 3. Backend Module Setup

- [x] 3.1 Create `daily-class-reports` NestJS module with imports for `TypeOrmModule.forFeature([...])`, and import dependent modules (`ClassesModule`, `StudentsModule`, `ActivityTypesModule`, `EducationFocusesModule`)
- [x] 3.2 Create `DailyClassReportsRepository` with custom query methods (find with relations, find by class+date)
- [x] 3.3 Create DTOs: `CreateDailyClassReportDto`, `UpdateDailyClassReportDto`, `CreateFocusEntryDto`, `UpdateFocusEntryDto`, `CheckResultDto`
- [x] 3.4 Register the module in `AppModule`

## 4. Backend Service — Report CRUD

- [x] 4.1 Implement `create()` — validate facilitator class assignment, check unique report per class+date, validate activity type IDs, create report + activity selections + auto-populate student daily records
- [x] 4.2 Implement `findAll()` — list reports for teacher's class with pagination, date range, and status filters; SUPERADMIN can filter by classId
- [x] 4.3 Implement `findOne()` — load full report with nested relations (activity selections, student records, focus entries, check results); enforce class ownership for GURU
- [x] 4.4 Implement `update()` — partial update of notes and activity selections; enforce DRAFT-only for GURU, allow SUPERADMIN to edit PUBLISHED
- [x] 4.5 Implement `publish()` — transition DRAFT → PUBLISHED; reject if already published

## 5. Backend Service — Focus Entry Management

- [x] 5.1 Implement `addFocusEntry()` — validate student record exists in report, validate education focus ID, validate checklist item IDs belong to focus, create entry + check results in transaction; enforce DRAFT status
- [x] 5.2 Implement `updateFocusEntry()` — update evidence text and/or replace check results; enforce DRAFT status for GURU
- [x] 5.3 Implement `deleteFocusEntry()` — remove entry and cascaded check results; enforce DRAFT status

## 6. Backend Controller

- [x] 6.1 Implement `POST /daily-class-reports` endpoint with `@Roles('GURU')` guard and DTO validation
- [x] 6.2 Implement `GET /daily-class-reports` endpoint with query parameter filters
- [x] 6.3 Implement `GET /daily-class-reports/:id` endpoint
- [x] 6.4 Implement `PATCH /daily-class-reports/:id` endpoint
- [x] 6.5 Implement `POST /daily-class-reports/:id/publish` endpoint
- [x] 6.6 Implement `POST /daily-class-reports/:reportId/students/:studentId/focus-entries` endpoint
- [x] 6.7 Implement `PATCH /daily-class-reports/:reportId/students/:studentId/focus-entries/:entryId` endpoint
- [x] 6.8 Implement `DELETE /daily-class-reports/:reportId/students/:studentId/focus-entries/:entryId` endpoint

## 7. Backend Tests

- [x] 7.1 Unit tests for report creation — unique constraint, class assignment validation, auto-populate students
- [x] 7.2 Unit tests for publish workflow — DRAFT→PUBLISHED, reject re-publish
- [x] 7.3 Unit tests for focus entry CRUD — validation of focus/checklist IDs, DRAFT-only enforcement
- [x] 7.4 Unit tests for authorization — GURU can only access own class, SUPERADMIN override

## 8. Frontend API Client

- [x] 8.1 Create `src/lib/daily-class-reports.ts` with typed functions: `createDailyClassReport`, `listDailyClassReports`, `getDailyClassReport`, `updateDailyClassReport`, `publishDailyClassReport`
- [x] 8.2 Add focus entry functions: `addFocusEntry`, `updateFocusEntry`, `deleteFocusEntry`
- [x] 8.3 Define TypeScript interfaces for all request/response types

## 9. Frontend — Daily Report Form Page

- [x] 9.1 Create `/facilitator/daily-report` route and page component
- [x] 9.2 Implement form header: date picker (default today), class name display, notes textarea
- [x] 9.3 Implement activity type selection: load active types, render as touch-friendly toggle checkboxes
- [x] 9.4 Implement student list: collapsible cards for each student, showing name and NIS
- [x] 9.5 Implement per-student focus entry: education focus dropdown, dynamic checklist toggles, evidence text textarea
- [x] 9.6 Implement "Save Draft" button with API call and success notification
- [x] 9.7 Implement "Publish" button with confirmation dialog and status transition
- [x] 9.8 Handle "resume editing" — detect existing DRAFT for today and load it into the form
- [x] 9.9 Handle published report — render form in read-only mode

## 10. Frontend — Report History Page

- [x] 10.1 Create `/facilitator/daily-reports` route and page component
- [x] 10.2 Implement paginated list with date, status badge, activity count, student count columns
- [x] 10.3 Implement date range filter
- [x] 10.4 Implement click-to-navigate to the report form for viewing/editing

## 11. Integration & Verification

- [x] 11.1 Verify migration runs cleanly against existing database
- [x] 11.2 Verify full create → add focus entries → publish flow via API
- [x] 11.3 Verify facilitator ownership enforcement (cannot access other class's reports)
- [x] 11.4 Verify frontend form end-to-end on mobile viewport
- [x] 11.5 Run backend lint and test suite
- [x] 11.6 Run frontend lint and build
