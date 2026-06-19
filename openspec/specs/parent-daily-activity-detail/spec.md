# parent-daily-activity-detail Specification

## Purpose
TBD - created by archiving change parent-activity-view. Update Purpose after archive.
## Requirements
### Requirement: Parent can view detailed daily activity for a specific date

The system SHALL provide a `GET /parents/students/:studentId/daily-activities/:date` endpoint that returns the full detail of a published daily class report for the specified student on the given date. The `:date` parameter SHALL use `YYYY-MM-DD` format. The endpoint SHALL be accessible only by authenticated users with the `PARENT` role who are linked to the student via `StudentParentMap`.

#### Scenario: Successful detail retrieval
- **WHEN** a parent requests the daily activity detail for a linked student on a date with a published report
- **THEN** the system returns the full report detail including: report date, daily notes, list of activity types performed, and the student's focus entries with all nested data

#### Scenario: Report exists but is DRAFT
- **WHEN** a parent requests daily activity detail for a date where the report status is `DRAFT`
- **THEN** the system returns a 404 Not Found error with errorCode `REPORT_NOT_FOUND`

#### Scenario: No report exists for the date
- **WHEN** a parent requests daily activity detail for a date with no report for the student's class
- **THEN** the system returns a 404 Not Found error with errorCode `REPORT_NOT_FOUND`

#### Scenario: Parent requests detail for an unlinked student
- **WHEN** a parent requests daily activity detail for a student not linked to them
- **THEN** the system returns a 403 Forbidden error with errorCode `UNLINKED_STUDENT`

---

### Requirement: Detail response includes student focus entries with checklist results

The detail response SHALL include all `StudentFocusEntry` records for the parent's linked student within the report. Each focus entry SHALL include the education focus name, evidence text, and all `StudentFocusCheckResult` records with their checklist item titles and checked status.

#### Scenario: Focus entry with checked items
- **WHEN** a student has a focus entry for "Pendidikan Iman" with 3 checklist items (2 checked, 1 unchecked)
- **THEN** the detail response includes the focus entry with educationFocusName "Pendidikan Iman", all 3 check results with their `title`, `isChecked` status, and optional `notes`

#### Scenario: Focus entry with evidence text
- **WHEN** a student's focus entry has evidence text "Anak menunjukkan kemandirian saat makan"
- **THEN** the detail response includes `evidenceText: "Anak menunjukkan kemandirian saat makan"` in the focus entry

#### Scenario: Multiple focus entries for one student
- **WHEN** a student has focus entries for both "Pendidikan Iman" and "Psikomotor" on the same day
- **THEN** the detail response includes both focus entries with their respective checklist results

---

### Requirement: Detail response includes evidence media

The detail response SHALL include all `EvidenceMedia` records associated with the student's daily record and focus entries. Each media item SHALL include `cloudinaryUrl`, `thumbnailUrl`, `fileType`, `caption`, and `originalFilename`.

#### Scenario: Student record has attached photos
- **WHEN** a student's daily record has 2 evidence media files (1 image, 1 video)
- **THEN** the detail response includes both media items with their URLs, types, and captions

#### Scenario: Focus entry has attached media
- **WHEN** a student's focus entry has an attached evidence photo
- **THEN** the detail response includes the media item nested under the corresponding focus entry

#### Scenario: No media attached
- **WHEN** a student's daily record and focus entries have no evidence media
- **THEN** the detail response includes empty media arrays

---

### Requirement: Frontend timeline page displays activity cards

The frontend SHALL provide a `ChildActivityTimelinePage` at route `/parent/activities` that displays a scrollable list of daily activity summary cards. Each card SHALL show the report date, activity types, focus count, and a media indicator icon. The page SHALL support date range filtering and student selection for multi-child parents.

#### Scenario: Parent views timeline with activities
- **WHEN** a parent navigates to `/parent/activities`
- **THEN** the page displays a list of activity cards for the default (first) linked student, ordered by most recent date first

#### Scenario: Parent selects a different child
- **WHEN** a parent with multiple linked children selects a different child from the student selector
- **THEN** the timeline refreshes to show activities for the selected child

#### Scenario: Parent filters by date range
- **WHEN** a parent selects a start date and end date in the date filter
- **THEN** only activities within that date range are displayed

#### Scenario: Parent taps an activity card
- **WHEN** a parent taps/clicks an activity card for a specific date
- **THEN** the app navigates to `/parent/activities/:date` showing the full detail

---

### Requirement: Frontend detail page displays full activity information

The frontend SHALL provide a `ChildActivityDetailPage` at route `/parent/activities/:date` that displays the complete activity detail for the selected date. The page SHALL show activity types, daily notes, each focus entry with its checklist and evidence, and a media gallery.

#### Scenario: Parent views activity detail
- **WHEN** a parent navigates to `/parent/activities/2026-06-19`
- **THEN** the page displays the full activity detail: list of activity types performed, teacher's daily notes, and per-focus sections with checklist results and evidence

#### Scenario: Media gallery display
- **WHEN** the activity detail includes photo and video evidence
- **THEN** the page displays a swipeable/scrollable gallery with thumbnails that can be tapped to view full-size

#### Scenario: No activity for the date
- **WHEN** a parent navigates to a detail page for a date with no published report
- **THEN** the page displays a friendly "Tidak ada aktivitas untuk tanggal ini" message with a link back to the timeline

