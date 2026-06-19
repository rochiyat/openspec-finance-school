## ADDED Requirements

### Requirement: Facilitator daily report form page
The system SHALL provide a frontend page at `/facilitator/daily-report` for creating and editing daily class reports. The form SHALL be mobile-first and optimized for fast input (< 5 minutes per class).

#### Scenario: Form loads with today's date and class info
- **WHEN** an authenticated `GURU` navigates to `/facilitator/daily-report`
- **THEN** the system displays a form pre-filled with today's date
- **AND** shows the teacher's assigned class name
- **AND** loads the list of available active activity types as checkboxes
- **AND** loads the list of active students in the class

#### Scenario: Teacher has no class assignment
- **WHEN** an authenticated `GURU` navigates to `/facilitator/daily-report` but has no homeroom class assigned
- **THEN** the system displays an informational message indicating no class is assigned
- **AND** does not show the form

---

### Requirement: Activity type selection
The system SHALL display all active activity types as toggle checkboxes in the daily report form. The facilitator SHALL select one or more activities performed that day.

#### Scenario: Select multiple activities
- **WHEN** the facilitator toggles activity type checkboxes (e.g., "Pembukaan", "Circle Time", "Tematic")
- **THEN** the form tracks the selected activity type IDs for submission

#### Scenario: No activities selected
- **WHEN** the facilitator attempts to save or publish without selecting any activities
- **THEN** the form displays a validation error requiring at least one activity selection

---

### Requirement: Per-student collapsible cards with focus entries
The system SHALL display a collapsible card for each student in the class. Each card SHALL allow the facilitator to add education focus entries with checklist items and evidence text.

#### Scenario: Expand student card to add focus
- **WHEN** the facilitator taps on a student's card
- **THEN** the card expands to show the student's existing focus entries (if any)
- **AND** displays a button to add a new focus entry

#### Scenario: Add a focus entry for a student
- **WHEN** the facilitator clicks "Add Focus" within a student's card
- **THEN** a focus selection dropdown appears with all active education focuses
- **AND** upon selecting a focus, the associated active checklist items appear as toggleable checkboxes
- **AND** an evidence text textarea is displayed for narrative input

#### Scenario: Check off checklist items
- **WHEN** the facilitator toggles a checklist item checkbox
- **THEN** the `isChecked` state is tracked locally for submission

#### Scenario: Multiple focuses per student
- **WHEN** the facilitator adds multiple focus entries for a single student
- **THEN** each focus entry is displayed independently within the student's card
- **AND** each has its own checklist toggles and evidence text

---

### Requirement: Save draft and publish actions
The system SHALL provide two submission actions: "Save Draft" (creates/updates the report with `DRAFT` status) and "Publish" (transitions to `PUBLISHED` status with confirmation).

#### Scenario: Save as draft
- **WHEN** the facilitator clicks "Save Draft"
- **THEN** the system sends the report data to the API (create or update)
- **AND** displays a success notification
- **AND** the form remains editable

#### Scenario: Publish with confirmation
- **WHEN** the facilitator clicks "Publish"
- **THEN** the system displays a confirmation dialog ("Once published, this report cannot be edited. Continue?")
- **AND** upon confirmation, sends the publish request
- **AND** displays a success notification
- **AND** the form becomes read-only

#### Scenario: Resume editing an existing draft
- **WHEN** the facilitator navigates to `/facilitator/daily-report` and a DRAFT report already exists for today
- **THEN** the system loads the existing report data into the form
- **AND** the form is in edit mode

---

### Requirement: Daily report history list
The system SHALL provide a report history page at `/facilitator/daily-reports` showing a paginated list of past daily reports for the teacher's class.

#### Scenario: View report history
- **WHEN** an authenticated `GURU` navigates to `/facilitator/daily-reports`
- **THEN** the system displays a list of daily reports ordered by date descending
- **AND** each row shows the date, status badge (DRAFT / PUBLISHED), activity count, and student count

#### Scenario: Click to view or edit a report
- **WHEN** the facilitator clicks on a report in the list
- **THEN** the system navigates to the daily report form pre-filled with that report's data
- **AND** if the report is PUBLISHED, the form is read-only

#### Scenario: Filter by date range
- **WHEN** the facilitator applies a date range filter
- **THEN** the list updates to show only reports within the selected date range

---

### Requirement: Frontend API client for daily class reports
The system SHALL provide a frontend API client module at `src/lib/daily-class-reports.ts` with functions for all daily class report operations.

#### Scenario: Create report
- **WHEN** the frontend calls `createDailyClassReport(data)` with report date, notes, and activity type IDs
- **THEN** the function sends a `POST /daily-class-reports` request and returns the created report

#### Scenario: Get report detail
- **WHEN** the frontend calls `getDailyClassReport(id)` with a report UUID
- **THEN** the function sends a `GET /daily-class-reports/:id` request and returns the full report with nested data

#### Scenario: Add focus entry
- **WHEN** the frontend calls `addFocusEntry(reportId, studentId, data)` with focus and checklist data
- **THEN** the function sends a `POST /daily-class-reports/:reportId/students/:studentId/focus-entries` request and returns the created entry

#### Scenario: Publish report
- **WHEN** the frontend calls `publishDailyClassReport(id)` with a report UUID
- **THEN** the function sends a `POST /daily-class-reports/:id/publish` request and returns the updated report
