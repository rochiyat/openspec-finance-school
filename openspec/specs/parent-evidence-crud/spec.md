# Capability: Parent Evidence CRUD

## Purpose
Allow parents to submit, list, view, and update evidence for their linked students.

## Requirements

### Requirement: Parent can submit evidence for a linked student
The system SHALL provide `POST /parent-evidences` to create a new `ParentEvidence` record. The request body SHALL include `studentId` (UUID, required), `date` (YYYY-MM-DD, required), and `evidenceText` (text, required). Only authenticated users with the `PARENT` role who are linked to the specified student via `StudentParentMap` SHALL be permitted to submit.

#### Scenario: Successful evidence submission
- **WHEN** an authenticated `PARENT` sends a `POST /parent-evidences` request with a valid `studentId` (linked to them), `date`, and `evidenceText`
- **THEN** the system creates a `ParentEvidence` record with `parent_id` set to the authenticated parent's ID, `student_id` set to the specified student, and `date` set to the provided date
- **AND** returns the created record with HTTP 201

#### Scenario: Submission rejected — unlinked student
- **WHEN** an authenticated `PARENT` sends a `POST /parent-evidences` request with a `studentId` not linked to them via `StudentParentMap`
- **THEN** the system rejects the request with HTTP 403
- **AND** returns an error with `errorCode: UNLINKED_STUDENT`

#### Scenario: Submission rejected — missing required fields
- **WHEN** an authenticated `PARENT` sends a `POST /parent-evidences` request without `studentId`, `date`, or `evidenceText`
- **THEN** the system rejects the request with HTTP 400

#### Scenario: Submission rejected — unauthenticated request
- **WHEN** an unauthenticated request is sent to `POST /parent-evidences`
- **THEN** the system rejects the request with HTTP 401

#### Scenario: Submission rejected — non-PARENT role
- **WHEN** an authenticated user with a role other than `PARENT` sends a `POST /parent-evidences` request
- **THEN** the system rejects the request with HTTP 403

---

### Requirement: Parent can list their evidence for a student
The system SHALL provide `GET /parent-evidences` to retrieve a paginated list of `ParentEvidence` records. The `studentId` query parameter SHALL be required. An optional `date` query parameter SHALL filter by exact date. An optional `startDate` and `endDate` query parameter pair SHALL filter by date range. Results SHALL be ordered by `date` descending, then `created_at` descending. Only authenticated users with the `PARENT` role SHALL be permitted, and results SHALL be filtered to only include records belonging to the authenticated parent.

#### Scenario: List evidence for a linked student
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences?studentId={id}` request for a linked student
- **THEN** the system returns a paginated list of `ParentEvidence` records created by the authenticated parent for that student, ordered by `date` descending

#### Scenario: List with date filter
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences?studentId={id}&date=2026-06-19` request
- **THEN** the system returns only `ParentEvidence` records matching the exact date

#### Scenario: List with date range filter
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences?studentId={id}&startDate=2026-06-01&endDate=2026-06-30` request
- **THEN** the system returns only `ParentEvidence` records within the specified date range (inclusive)

#### Scenario: Pagination support
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences?studentId={id}&limit=10&offset=0` request
- **THEN** the system returns at most 10 records starting from offset 0, along with the total count

#### Scenario: Missing studentId
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences` without a `studentId` query parameter
- **THEN** the system rejects the request with HTTP 400 and `errorCode: MISSING_STUDENT_ID`

#### Scenario: Unlinked student
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences?studentId={id}` for a student not linked to them
- **THEN** the system rejects the request with HTTP 403 and `errorCode: UNLINKED_STUDENT`

---

### Requirement: Parent can view a single evidence detail
The system SHALL provide `GET /parent-evidences/:id` to retrieve a single `ParentEvidence` record by its UUID. The response SHALL include the evidence record with its associated `EvidenceMedia` records (if any). Only the parent who created the evidence SHALL be permitted to view it.

#### Scenario: Evidence found with media
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences/:id` request for an evidence record they created that has attached media
- **THEN** the system returns the `ParentEvidence` record including `id`, `studentId`, `parentId`, `date`, `evidenceText`, `createdAt`, `updatedAt`, and an array of associated `EvidenceMedia` records

#### Scenario: Evidence found without media
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences/:id` request for an evidence record with no attached media
- **THEN** the system returns the `ParentEvidence` record with an empty `media` array

#### Scenario: Evidence not found
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences/:id` request for a non-existent UUID
- **THEN** the system returns HTTP 404 with `errorCode: PARENT_EVIDENCE_NOT_FOUND`

#### Scenario: Evidence belongs to another parent
- **WHEN** an authenticated `PARENT` sends a `GET /parent-evidences/:id` request for an evidence record created by a different parent
- **THEN** the system returns HTTP 403 with `errorCode: ACCESS_DENIED`

---

### Requirement: Parent can update their evidence text
The system SHALL provide `PATCH /parent-evidences/:id` to update the `evidenceText` field of an existing `ParentEvidence` record. Only the parent who created the evidence SHALL be permitted to update it.

#### Scenario: Successful update
- **WHEN** an authenticated `PARENT` sends a `PATCH /parent-evidences/:id` request with `{ "evidenceText": "Updated observation text" }` for an evidence record they created
- **THEN** the system updates the `evidenceText` field and `updated_at` timestamp
- **AND** returns the updated `ParentEvidence` record

#### Scenario: Evidence not found
- **WHEN** an authenticated `PARENT` sends a `PATCH /parent-evidences/:id` request for a non-existent UUID
- **THEN** the system returns HTTP 404 with `errorCode: PARENT_EVIDENCE_NOT_FOUND`

#### Scenario: Evidence belongs to another parent
- **WHEN** an authenticated `PARENT` sends a `PATCH /parent-evidences/:id` request for an evidence record created by a different parent
- **THEN** the system returns HTTP 403 with `errorCode: ACCESS_DENIED`

#### Scenario: Empty evidenceText
- **WHEN** an authenticated `PARENT` sends a `PATCH /parent-evidences/:id` request with an empty `evidenceText`
- **THEN** the system rejects the request with HTTP 400

---

### Requirement: ParentEvidence entity and database schema
The system SHALL persist `ParentEvidence` records in the `parent_evidences` database table with the following schema:
- `id` (UUID, primary key, auto-generated)
- `student_id` (VARCHAR, FK → `students.id`, NOT NULL)
- `parent_id` (UUID, FK → `parents.id`, NOT NULL)
- `date` (DATE, NOT NULL)
- `evidence_text` (TEXT, NOT NULL)
- `created_at` (TIMESTAMP, NOT NULL)
- `updated_at` (TIMESTAMP, NOT NULL)

The migration SHALL also add a foreign key constraint from `evidence_media.parent_evidence_id` → `parent_evidences.id` with `ON DELETE SET NULL`.

#### Scenario: Migration creates the parent_evidences table
- **WHEN** the database migration for this capability runs
- **THEN** the `parent_evidences` table is created with all columns and constraints as specified
- **AND** indexes are created on `student_id`, `parent_id`, and `date`
- **AND** a foreign key constraint is added from `evidence_media.parent_evidence_id` to `parent_evidences.id`

#### Scenario: Multiple evidence entries per student per date allowed
- **WHEN** a parent submits two evidence entries for the same student on the same date
- **THEN** both records are persisted successfully (no unique constraint on student_id + date)

#### Scenario: Cascade behavior on parent delete
- **WHEN** a `Parent` record is deleted
- **THEN** all associated `ParentEvidence` records are deleted via CASCADE
- **AND** the `parent_evidence_id` on any associated `evidence_media` records is set to NULL

---

### Requirement: Frontend API client for parent evidence operations
The system SHALL provide a frontend API client module at `src/lib/parent-evidence.ts` with functions for creating, listing, fetching, and updating parent evidence.

#### Scenario: Frontend submits evidence
- **WHEN** the frontend calls `createParentEvidence(token, payload)` with `studentId`, `date`, and `evidenceText`
- **THEN** the function sends a `POST /parent-evidences` request
- **AND** returns the created `ParentEvidence` record from the response

#### Scenario: Frontend lists evidence
- **WHEN** the frontend calls `listParentEvidence(token, filter)` with a `studentId` and optional date filters
- **THEN** the function sends a `GET /parent-evidences` request with query parameters
- **AND** returns the paginated list of `ParentEvidence` records

#### Scenario: Frontend fetches evidence detail
- **WHEN** the frontend calls `getParentEvidence(token, id)` with an evidence UUID
- **THEN** the function sends a `GET /parent-evidences/:id` request
- **AND** returns the `ParentEvidence` record with associated media

#### Scenario: Frontend updates evidence
- **WHEN** the frontend calls `updateParentEvidence(token, id, payload)` with updated `evidenceText`
- **THEN** the function sends a `PATCH /parent-evidences/:id` request
- **AND** returns the updated `ParentEvidence` record

---

### Requirement: Frontend parent evidence submission page
The system SHALL provide a `ParentSubmitEvidencePage` at route `/parent/evidence/submit` that allows parents to submit text evidence and upload media for a selected child and date.

#### Scenario: Parent submits evidence with text and photos
- **WHEN** a parent selects a child, picks a date, writes evidence text, and uploads 2 photos
- **THEN** the page submits the `ParentEvidence` via `POST /parent-evidences`, then uploads each photo via `POST /evidence-media/upload` with the returned `parentEvidenceId`
- **AND** shows a success confirmation with a link to view the submitted evidence

#### Scenario: Parent with multiple children sees a child selector
- **WHEN** a parent with multiple linked children navigates to `/parent/evidence/submit`
- **THEN** the page displays a child selector dropdown populated with the parent's linked students

#### Scenario: Validation prevents empty submission
- **WHEN** a parent tries to submit without entering evidence text
- **THEN** the form shows a validation error on the evidence text field

#### Scenario: Date defaults to today
- **WHEN** a parent navigates to `/parent/evidence/submit`
- **THEN** the date field is pre-filled with today's date

---

### Requirement: Frontend parent evidence list page
The system SHALL provide a `ParentEvidenceListPage` at route `/parent/evidence` that displays the parent's submitted evidence for a selected child, with date filtering.

#### Scenario: Parent views evidence list
- **WHEN** a parent navigates to `/parent/evidence`
- **THEN** the page displays a list of evidence entries for the default (first) linked child, ordered by most recent date first

#### Scenario: Parent selects a different child
- **WHEN** a parent with multiple children selects a different child from the selector
- **THEN** the list refreshes to show evidence for the selected child

#### Scenario: Parent taps an evidence entry
- **WHEN** a parent taps an evidence entry in the list
- **THEN** the page navigates to a detail view showing the full evidence text and any attached media in a gallery

#### Scenario: Empty state
- **WHEN** a parent has not submitted any evidence for the selected child
- **THEN** the page shows a friendly empty state message with a call-to-action button linking to `/parent/evidence/submit`
