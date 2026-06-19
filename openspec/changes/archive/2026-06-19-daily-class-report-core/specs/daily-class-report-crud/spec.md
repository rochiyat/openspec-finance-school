## ADDED Requirements

### Requirement: Facilitator can create a daily class report
The system SHALL provide `POST /daily-class-reports` to create a new daily class report for the authenticated facilitator's assigned class. The request body SHALL include `reportDate` (date), `notes` (optional text), and `activityTypeIds` (array of UUIDs referencing active activity types). The system SHALL auto-populate `StudentDailyRecord` rows for all active students in the class.

#### Scenario: Successful report creation
- **WHEN** an authenticated `GURU` sends a valid `POST /daily-class-reports` request with `reportDate: "2026-06-19"`, `notes: "Hari yang produktif"`, and `activityTypeIds: ["<uuid-1>", "<uuid-2>"]`
- **THEN** the system creates a `DailyClassReport` record with `classId` set to the teacher's homeroom class, `facilitatorId` set to the authenticated user, `status` set to `DRAFT`
- **AND** creates `DailyActivitySelection` records linking the report to each provided activity type
- **AND** creates `StudentDailyRecord` records for every active student in the class
- **AND** returns the created report with HTTP 201, including the nested activity selections and student records

#### Scenario: Duplicate report for same class and date
- **WHEN** an authenticated `GURU` sends a `POST /daily-class-reports` request with a `reportDate` for which a report already exists for their class
- **THEN** the system rejects the request with HTTP 409
- **AND** returns an error with `errorCode: REPORT_ALREADY_EXISTS`

#### Scenario: Teacher has no assigned class
- **WHEN** an authenticated `GURU` who is not assigned as homeroom teacher to any class sends a `POST /daily-class-reports` request
- **THEN** the system rejects the request with HTTP 422
- **AND** returns an error with `errorCode: NO_CLASS_ASSIGNMENT`

#### Scenario: Invalid activity type ID
- **WHEN** an authenticated `GURU` sends a `POST /daily-class-reports` request with an `activityTypeId` that does not exist or is inactive
- **THEN** the system rejects the request with HTTP 400
- **AND** returns an error with `errorCode: INVALID_ACTIVITY_TYPE`

#### Scenario: Non-GURU user is denied
- **WHEN** a user without the `GURU` role sends a `POST /daily-class-reports` request
- **THEN** the system rejects the request with HTTP 403

---

### Requirement: Facilitator can list daily class reports
The system SHALL provide `GET /daily-class-reports` to list daily class reports for the authenticated facilitator's assigned class. Results SHALL be paginated and ordered by `report_date` descending. Optional query parameters SHALL include `startDate`, `endDate`, and `status`.

#### Scenario: List reports with default parameters
- **WHEN** an authenticated `GURU` sends a `GET /daily-class-reports` request without filters
- **THEN** the system returns paginated reports for the teacher's assigned class, ordered by `report_date` descending
- **AND** each report includes `id`, `classId`, `reportDate`, `status`, `notes`, activity type names, and student count

#### Scenario: Filter by date range
- **WHEN** an authenticated `GURU` sends a `GET /daily-class-reports?startDate=2026-06-01&endDate=2026-06-30` request
- **THEN** the system returns only reports whose `report_date` falls within the specified range (inclusive)

#### Scenario: Filter by status
- **WHEN** an authenticated `GURU` sends a `GET /daily-class-reports?status=DRAFT` request
- **THEN** the system returns only reports with `status = DRAFT`

#### Scenario: SUPERADMIN can list reports for any class
- **WHEN** an authenticated `SUPERADMIN` sends a `GET /daily-class-reports?classId=<uuid>` request
- **THEN** the system returns reports for the specified class regardless of teacher assignment

---

### Requirement: Facilitator can get daily class report detail
The system SHALL provide `GET /daily-class-reports/:id` to retrieve a single daily class report with all nested data: activity selections (with activity type details), student daily records (with student details), and each student's focus entries (with education focus details, checklist results, and evidence media).

#### Scenario: Report found with full detail
- **WHEN** an authenticated `GURU` sends a `GET /daily-class-reports/:id` request for a report belonging to their class
- **THEN** the system returns the report with:
  - Report fields: `id`, `classId`, `facilitatorId`, `reportDate`, `notes`, `status`, `createdAt`, `updatedAt`
  - `activitySelections`: array of `{ id, activityType: { id, name } }`
  - `studentRecords`: array of `{ id, student: { id, fullName, nis }, focusEntries: [...] }`
  - Each `focusEntry`: `{ id, educationFocus: { id, name }, evidenceText, checkResults: [...], media: [...] }`
  - Each `checkResult`: `{ id, focusChecklist: { id, title }, isChecked, notes }`

#### Scenario: Report not found
- **WHEN** an authenticated user sends a `GET /daily-class-reports/:id` request for a non-existent UUID
- **THEN** the system returns HTTP 404 with `errorCode: REPORT_NOT_FOUND`

#### Scenario: Teacher cannot access another class's report
- **WHEN** an authenticated `GURU` sends a `GET /daily-class-reports/:id` request for a report belonging to a different class
- **THEN** the system returns HTTP 403

---

### Requirement: Facilitator can update a draft daily class report
The system SHALL provide `PATCH /daily-class-reports/:id` to update a daily class report. Only reports with `status = DRAFT` SHALL be editable by the facilitator. Updatable fields are `notes` and `activityTypeIds`.

#### Scenario: Successful update of notes
- **WHEN** an authenticated `GURU` sends a `PATCH /daily-class-reports/:id` request with `{ "notes": "Updated notes" }` for a DRAFT report in their class
- **THEN** the system updates the `notes` field and returns the updated report

#### Scenario: Successful update of activity selections
- **WHEN** an authenticated `GURU` sends a `PATCH /daily-class-reports/:id` request with `{ "activityTypeIds": ["<uuid-a>", "<uuid-b>"] }`
- **THEN** the system replaces all existing `DailyActivitySelection` records with new ones matching the provided IDs
- **AND** returns the updated report with the new activity selections

#### Scenario: Cannot update a published report
- **WHEN** an authenticated `GURU` sends a `PATCH /daily-class-reports/:id` request for a report with `status = PUBLISHED`
- **THEN** the system rejects the request with HTTP 403
- **AND** returns an error with `errorCode: REPORT_ALREADY_PUBLISHED`

#### Scenario: SUPERADMIN can update a published report
- **WHEN** an authenticated `SUPERADMIN` sends a `PATCH /daily-class-reports/:id` request for a PUBLISHED report
- **THEN** the system allows the update and returns the updated report

---

### Requirement: Facilitator can publish a draft report
The system SHALL provide `POST /daily-class-reports/:id/publish` to transition a report's status from `DRAFT` to `PUBLISHED`. Only reports with `status = DRAFT` SHALL be publishable.

#### Scenario: Successful publish
- **WHEN** an authenticated `GURU` sends a `POST /daily-class-reports/:id/publish` request for a DRAFT report in their class
- **THEN** the system sets the report's `status` to `PUBLISHED`
- **AND** returns the updated report with the new status

#### Scenario: Report already published
- **WHEN** an authenticated `GURU` sends a `POST /daily-class-reports/:id/publish` request for a report that is already `PUBLISHED`
- **THEN** the system rejects the request with HTTP 409
- **AND** returns an error with `errorCode: REPORT_ALREADY_PUBLISHED`

#### Scenario: Report not found on publish
- **WHEN** an authenticated user sends a `POST /daily-class-reports/:id/publish` request for a non-existent UUID
- **THEN** the system returns HTTP 404 with `errorCode: REPORT_NOT_FOUND`

---

### Requirement: Database schema for daily class reports
The system SHALL persist daily class reports and activity selections in the following tables:

**`daily_class_reports`**:
- `id` (UUID, primary key, auto-generated)
- `class_id` (VARCHAR, FK → `classes.id`, NOT NULL)
- `facilitator_id` (VARCHAR, FK → `users.id`, NOT NULL)
- `report_date` (DATE, NOT NULL)
- `notes` (TEXT, nullable)
- `status` (VARCHAR, NOT NULL, default `'DRAFT'`, values: `DRAFT`, `PUBLISHED`)
- `created_at` (TIMESTAMP, NOT NULL)
- `updated_at` (TIMESTAMP, NOT NULL)

UNIQUE constraint on `(class_id, report_date)`.

**`daily_activity_selections`**:
- `id` (UUID, primary key, auto-generated)
- `daily_class_report_id` (UUID, FK → `daily_class_reports.id` ON DELETE CASCADE, NOT NULL)
- `activity_type_id` (UUID, FK → `activity_types.id`, NOT NULL)

UNIQUE constraint on `(daily_class_report_id, activity_type_id)`.

#### Scenario: Migration creates the tables
- **WHEN** the database migration for this capability runs
- **THEN** the `daily_class_reports` table is created with all columns and constraints
- **AND** the `daily_activity_selections` table is created with all columns and constraints
- **AND** the unique index on `(class_id, report_date)` is created
- **AND** the unique index on `(daily_class_report_id, activity_type_id)` is created
- **AND** foreign key indexes are created on `class_id`, `facilitator_id`, `daily_class_report_id`, and `activity_type_id`

#### Scenario: Unique constraint prevents duplicate reports
- **WHEN** an attempt is made to insert a `daily_class_reports` record with a `class_id` and `report_date` combination that already exists
- **THEN** the database rejects the insert with a constraint violation
