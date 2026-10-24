## Purpose
Lets teachers review and edit a generated student report on the web, move it through its lifecycle, and download it as PDF or editable DOCX.

## ADDED Requirements

### Requirement: Report lifecycle
The system SHALL allow only these status transitions: DRAFT → FINAL (finalize), FINAL → DRAFT (reopen), FINAL → PUBLISHED (publish), and PUBLISHED → FINAL (unpublish). Any other transition SHALL be rejected with 409. Each transition SHALL be recorded in the audit log with the actor.

#### Scenario: Publishing a draft
- **WHEN** a teacher publishes a report that is still DRAFT
- **THEN** the system responds 409 and the status is unchanged

#### Scenario: Finalize is audited
- **WHEN** a teacher finalizes a DRAFT report
- **THEN** the report becomes FINAL, `finalized_at` is set, and an audit entry records the teacher and the report

### Requirement: Only authorized staff manage reports
The system SHALL allow report generation, editing, transitions, exports and file management only for SUPERADMIN, KEPSEK, and GURU users who are the homeroom teacher of the student's class.

#### Scenario: Teacher of another class
- **WHEN** a GURU who is not the homeroom teacher of the student's class edits the report
- **THEN** the system responds 403

#### Scenario: Parent calls a teacher endpoint
- **WHEN** a PARENT calls the content update endpoint
- **THEN** the system responds 403

### Requirement: Web editing of drafts
The system SHALL let authorized staff edit the narrative per focus, the recommendation per indicator, strengths, next steps, home recommendations and teacher notes of a DRAFT report. Each text SHALL be at most 5,000 characters. Computed scores SHALL NOT be editable.

#### Scenario: Edit a draft
- **WHEN** a teacher saves a new narrative for a focus of a DRAFT report
- **THEN** the narrative is stored and `generation_source` becomes MANUAL

#### Scenario: Edit a final report
- **WHEN** a teacher saves content for a FINAL report
- **THEN** the system responds 409

#### Scenario: Attempt to change a score
- **WHEN** an edit payload contains a score value
- **THEN** the score is not changed

### Requirement: Teacher confirms every indicator level
The teacher SHALL review each indicator of an ASSESSMENT report and either confirm the suggested level or choose another level (BB, MB, BSH or BSB), or confirm that the indicator cannot be assessed yet. A reason of at most 1,000 characters SHALL be required whenever the teacher's level differs from the suggested level. A SEMESTER or YEAR report SHALL NOT be finalized while any indicator is unconfirmed. For a TERM report, confirmation SHALL be optional and finalizing SHALL lock the current levels.

#### Scenario: Confirm the suggestion
- **WHEN** the teacher confirms an indicator without changing the suggested BSH
- **THEN** the indicator is confirmed with level BSH and no reason is required

#### Scenario: Change without a reason
- **WHEN** the teacher sets BSB on an indicator suggested as BSH without a reason
- **THEN** the system responds 400 and nothing is saved

#### Scenario: Finalize with unconfirmed indicators
- **WHEN** a teacher finalizes a DRAFT semester report with two unconfirmed indicators
- **THEN** the system responds 409 and names the unconfirmed indicators

#### Scenario: Finalize an unconfirmed term report
- **WHEN** a teacher finalizes a DRAFT term report with unconfirmed indicators
- **THEN** the report becomes FINAL

### Requirement: Teacher report list per class and period
The teacher student-reports page SHALL list the students of a selected class and period (type Triwulan, Semester or Tahunan plus number, in the class's academic year) with report status, template, overall band and last generated time. Generating reports for the whole class from this page SHALL be switchable off; while it is off, the button is disabled with a note that reports are prepared by the school team, and reports are generated through the agent scripts.

#### Scenario: Class without reports yet
- **WHEN** a teacher opens the list for a period with no reports
- **THEN** every student is listed as "Belum dibuat"

#### Scenario: Generating switched off for teachers
- **WHEN** generating from the teacher page is switched off
- **THEN** the generate button is disabled and the page says that reports are prepared by the school team

### Requirement: Web report view matches the assessment format
The system SHALL render ASSESSMENT reports with identity, the level of each education focus (BB, MB, BSH or BSB), a level scale, a radar chart of the four focuses with the BSH baseline, indicator levels, narratives, recommendations and teacher notes. It SHALL NOT show a single overall number. NARRATIVE reports SHALL render without levels, scale and radar.

#### Scenario: Assessment view
- **WHEN** a teacher opens an ASSESSMENT report
- **THEN** the focus levels, level scale and radar chart are shown, and no overall number is shown

#### Scenario: Narrative view
- **WHEN** a teacher opens a NARRATIVE report
- **THEN** narratives per focus and attendance are shown, and no score or radar is shown

### Requirement: PDF and DOCX export
The system SHALL let authorized staff download any report as a PDF that matches the web view, and as an editable DOCX that contains identity, attendance, scores and bands in tables (for ASSESSMENT), narratives, recommendations and notes.

#### Scenario: DOCX download
- **WHEN** a teacher downloads the DOCX of an ASSESSMENT report
- **THEN** the file opens in Word with one score table per education focus and all narrative text editable

#### Scenario: PDF page breaks
- **WHEN** a teacher downloads the PDF of a long report
- **THEN** no section block is split across two pages
