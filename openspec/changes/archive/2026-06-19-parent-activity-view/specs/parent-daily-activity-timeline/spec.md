## ADDED Requirements

### Requirement: Parent can list published daily activities for a linked student

The system SHALL provide a `GET /parents/students/:studentId/daily-activities` endpoint that returns a paginated list of published daily class report summaries for the specified student. The endpoint SHALL be accessible only by authenticated users with the `PARENT` role who are linked to the student via `StudentParentMap`.

#### Scenario: Successful listing of daily activities
- **WHEN** a parent requests daily activities for a linked student without date filters
- **THEN** the system returns the most recent published daily reports (newest first) with summary data including: report date, daily notes preview (truncated to 200 characters), list of activity type names performed that day, and count of education focus entries for the student

#### Scenario: Listing with date range filter
- **WHEN** a parent requests daily activities with `startDate` and/or `endDate` query parameters
- **THEN** the system returns only published reports within the specified date range, ordered by report date descending

#### Scenario: Pagination support
- **WHEN** a parent requests daily activities with `limit` and `offset` query parameters
- **THEN** the system returns at most `limit` items starting from `offset`, along with the total count of matching reports

#### Scenario: Only published reports are visible
- **WHEN** a daily class report exists for the student's class on a given date but its status is `DRAFT`
- **THEN** the report SHALL NOT appear in the parent's daily activities listing

#### Scenario: Parent requests activities for an unlinked student
- **WHEN** a parent requests daily activities for a student not linked to them via `StudentParentMap`
- **THEN** the system returns a 403 Forbidden error with errorCode `UNLINKED_STUDENT`

#### Scenario: No reports found
- **WHEN** a parent requests daily activities and no published reports exist for the date range
- **THEN** the system returns an empty list with total count of 0

---

### Requirement: Timeline summary includes student-specific data

Each item in the timeline listing SHALL include student-specific summary data extracted from the student's `StudentDailyRecord` within each published report. This includes the count of focus entries and whether evidence media exists for the student on that day.

#### Scenario: Summary includes focus entry count
- **WHEN** a published report includes a `StudentDailyRecord` for the student with 3 `StudentFocusEntry` records
- **THEN** the timeline item for that date SHALL show `focusEntryCount: 3`

#### Scenario: Summary indicates media presence
- **WHEN** a published report's student record has associated `EvidenceMedia` records
- **THEN** the timeline item for that date SHALL show `hasMedia: true`

#### Scenario: Student has no records in the report
- **WHEN** a published report exists for the student's class but the student has no `StudentDailyRecord` (e.g., student joined after report was created)
- **THEN** the report SHALL NOT appear in the parent's timeline listing
