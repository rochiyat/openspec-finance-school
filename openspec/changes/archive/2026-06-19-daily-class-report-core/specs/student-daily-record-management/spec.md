## ADDED Requirements

### Requirement: Facilitator can add a focus entry for a student
The system SHALL provide `POST /daily-class-reports/:reportId/students/:studentId/focus-entries` to create a new `StudentFocusEntry` for a specific student within a daily class report. The request body SHALL include `educationFocusId` (UUID), optional `evidenceText` (text), and optional `checkResults` (array of `{ focusChecklistId: UUID, isChecked: boolean, notes?: string }`).

#### Scenario: Successful focus entry creation with check results
- **WHEN** an authenticated `GURU` sends a valid `POST /daily-class-reports/:reportId/students/:studentId/focus-entries` request with `educationFocusId`, `evidenceText`, and `checkResults` array
- **THEN** the system creates a `StudentFocusEntry` record linked to the student's `StudentDailyRecord` within the report
- **AND** creates `StudentFocusCheckResult` records for each item in the `checkResults` array
- **AND** returns the created focus entry with nested check results and HTTP 201

#### Scenario: Focus entry without check results
- **WHEN** an authenticated `GURU` sends a `POST` request with only `educationFocusId` and no `checkResults`
- **THEN** the system creates the `StudentFocusEntry` with empty check results
- **AND** returns the created entry with HTTP 201

#### Scenario: Student not part of the report
- **WHEN** an authenticated `GURU` sends a `POST` request with a `studentId` that does not have a `StudentDailyRecord` in the specified report
- **THEN** the system rejects the request with HTTP 404
- **AND** returns an error with `errorCode: STUDENT_RECORD_NOT_FOUND`

#### Scenario: Invalid education focus ID
- **WHEN** an authenticated `GURU` sends a `POST` request with an `educationFocusId` that does not exist or is inactive
- **THEN** the system rejects the request with HTTP 400
- **AND** returns an error with `errorCode: INVALID_EDUCATION_FOCUS`

#### Scenario: Invalid checklist item ID
- **WHEN** an authenticated `GURU` sends a `POST` request with a `focusChecklistId` that does not belong to the specified education focus
- **THEN** the system rejects the request with HTTP 400
- **AND** returns an error with `errorCode: INVALID_CHECKLIST_ITEM`

#### Scenario: Report is published — cannot add entries
- **WHEN** an authenticated `GURU` sends a `POST` request for a report with `status = PUBLISHED`
- **THEN** the system rejects the request with HTTP 403
- **AND** returns an error with `errorCode: REPORT_ALREADY_PUBLISHED`

---

### Requirement: Facilitator can update a focus entry
The system SHALL provide `PATCH /daily-class-reports/:reportId/students/:studentId/focus-entries/:entryId` to update an existing `StudentFocusEntry`. Updatable fields are `evidenceText` and `checkResults`. When `checkResults` is provided, all existing `StudentFocusCheckResult` records for the entry SHALL be replaced.

#### Scenario: Successful update of evidence text
- **WHEN** an authenticated `GURU` sends a `PATCH` request with `{ "evidenceText": "Anak menunjukkan kemampuan..." }`
- **THEN** the system updates the `evidenceText` field on the focus entry
- **AND** returns the updated entry with nested check results

#### Scenario: Successful update of check results
- **WHEN** an authenticated `GURU` sends a `PATCH` request with `{ "checkResults": [{ "focusChecklistId": "<uuid>", "isChecked": true, "notes": "Baik" }] }`
- **THEN** the system deletes all existing `StudentFocusCheckResult` records for this entry
- **AND** creates new `StudentFocusCheckResult` records from the provided array
- **AND** returns the updated entry

#### Scenario: Focus entry not found
- **WHEN** an authenticated `GURU` sends a `PATCH` request for a non-existent `entryId` or mismatched `studentId`/`reportId`
- **THEN** the system returns HTTP 404 with `errorCode: FOCUS_ENTRY_NOT_FOUND`

#### Scenario: Cannot update entry in published report
- **WHEN** an authenticated `GURU` sends a `PATCH` request for an entry in a report with `status = PUBLISHED`
- **THEN** the system rejects the request with HTTP 403
- **AND** returns an error with `errorCode: REPORT_ALREADY_PUBLISHED`

---

### Requirement: Facilitator can delete a focus entry
The system SHALL provide `DELETE /daily-class-reports/:reportId/students/:studentId/focus-entries/:entryId` to remove a `StudentFocusEntry` and all its associated `StudentFocusCheckResult` records. Only entries in DRAFT reports SHALL be deletable by the facilitator.

#### Scenario: Successful deletion
- **WHEN** an authenticated `GURU` sends a `DELETE` request for a valid focus entry in a DRAFT report
- **THEN** the system removes the `StudentFocusEntry` and all associated `StudentFocusCheckResult` records
- **AND** returns HTTP 200 with a success message

#### Scenario: Cannot delete entry in published report
- **WHEN** an authenticated `GURU` sends a `DELETE` request for an entry in a PUBLISHED report
- **THEN** the system rejects the request with HTTP 403

#### Scenario: Entry not found
- **WHEN** an authenticated `GURU` sends a `DELETE` request for a non-existent entry
- **THEN** the system returns HTTP 404 with `errorCode: FOCUS_ENTRY_NOT_FOUND`

---

### Requirement: Database schema for student daily records and focus entries
The system SHALL persist student records, focus entries, and check results in the following tables:

**`student_daily_records`**:
- `id` (UUID, primary key, auto-generated)
- `daily_class_report_id` (UUID, FK → `daily_class_reports.id` ON DELETE CASCADE, NOT NULL)
- `student_id` (VARCHAR, FK → `students.id`, NOT NULL)
- `created_at` (TIMESTAMP, NOT NULL)
- `updated_at` (TIMESTAMP, NOT NULL)

UNIQUE constraint on `(daily_class_report_id, student_id)`.

**`student_focus_entries`**:
- `id` (UUID, primary key, auto-generated)
- `student_daily_record_id` (UUID, FK → `student_daily_records.id` ON DELETE CASCADE, NOT NULL)
- `education_focus_id` (UUID, FK → `education_focuses.id`, NOT NULL)
- `evidence_text` (TEXT, nullable)
- `created_at` (TIMESTAMP, NOT NULL)
- `updated_at` (TIMESTAMP, NOT NULL)

**`student_focus_check_results`**:
- `id` (UUID, primary key, auto-generated)
- `student_focus_entry_id` (UUID, FK → `student_focus_entries.id` ON DELETE CASCADE, NOT NULL)
- `focus_checklist_id` (UUID, FK → `focus_checklists.id`, NOT NULL)
- `is_checked` (BOOLEAN, NOT NULL, default `false`)
- `notes` (TEXT, nullable)

UNIQUE constraint on `(student_focus_entry_id, focus_checklist_id)`.

#### Scenario: Migration creates the tables
- **WHEN** the database migration for this capability runs
- **THEN** the `student_daily_records` table is created with all columns and constraints
- **AND** the `student_focus_entries` table is created with all columns and constraints
- **AND** the `student_focus_check_results` table is created with all columns and constraints
- **AND** foreign key indexes are created on all FK columns
- **AND** the unique index on `(daily_class_report_id, student_id)` is created
- **AND** the unique index on `(student_focus_entry_id, focus_checklist_id)` is created

#### Scenario: Cascade delete removes nested records
- **WHEN** a `DailyClassReport` is deleted
- **THEN** all associated `StudentDailyRecord` records are deleted via CASCADE
- **AND** all associated `StudentFocusEntry` records are deleted via CASCADE
- **AND** all associated `StudentFocusCheckResult` records are deleted via CASCADE
