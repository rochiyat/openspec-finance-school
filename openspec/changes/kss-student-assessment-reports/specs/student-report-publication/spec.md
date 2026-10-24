## Purpose
Lets teachers attach final report files and publish a report to parents, and lets parents see only the published reports of their own children.

## ADDED Requirements

### Requirement: Teachers upload final report files
The system SHALL let authorized staff upload PDF or DOCX files of at most 10 MB to a report that is not PUBLISHED. It SHALL check both the MIME type and the extension. Each file SHALL record the uploader, original name, size and kind, and SHALL start as not visible to parents.

#### Scenario: Valid upload
- **WHEN** a teacher uploads a 2 MB DOCX to a FINAL report
- **THEN** the file is stored, listed on the report, and marked not visible to parents

#### Scenario: Unsupported file
- **WHEN** a teacher uploads a JPG or a file larger than 10 MB
- **THEN** the system responds 400 and nothing is stored

#### Scenario: Delete after publishing
- **WHEN** a teacher deletes a file from a PUBLISHED report
- **THEN** the system responds 409

### Requirement: Teachers choose which files parents see
The system SHALL let authorized staff mark each file of a report as visible or not visible to parents.

#### Scenario: Hide a working file
- **WHEN** a report has a visible PDF and a hidden DOCX and is published
- **THEN** parents see only the PDF

### Requirement: Only semester and year reports reach parents
The system SHALL allow publishing only SEMESTER and YEAR reports. Publishing a TERM report SHALL be rejected with 409, and the teacher UI SHALL NOT offer publishing or parent file visibility for term reports.

#### Scenario: Publish a term report
- **WHEN** a teacher publishes a FINAL Triwulan 2 report
- **THEN** the system responds 409 and the report stays FINAL

#### Scenario: Publish a semester report
- **WHEN** a teacher publishes a FINAL Semester 1 report
- **THEN** the report becomes PUBLISHED and the linked parents are notified

### Requirement: Publishing notifies parents
When a report is published, the system SHALL set `published_at` and create one personal notification for every parent linked to the student. Republishing after an unpublish SHALL notify again. A single publish SHALL never notify twice.

#### Scenario: Two linked parents
- **WHEN** a teacher publishes a report for a student with two linked parents
- **THEN** each parent receives one notification that the report for that period (for example "Semester 1 2026/2027") is available

### Requirement: Parents see only published reports of their own children
Parent report endpoints SHALL return a report only if the parent is linked to the student and the report is PUBLISHED, and SHALL return only files marked visible. Any other case SHALL respond 404. Staff report endpoints SHALL NOT be callable with the PARENT role.

#### Scenario: Another family's child
- **WHEN** a parent requests the reports of a student they are not linked to
- **THEN** the system responds 404

#### Scenario: Draft report
- **WHEN** a parent requests a report of their own child that is DRAFT or FINAL
- **THEN** the system responds 404

#### Scenario: Parent calls a staff endpoint
- **WHEN** a parent calls `GET /student-reports/student/:studentId`
- **THEN** the system responds 403

### Requirement: Parent "Rapor Anak" page
The parent area SHALL provide a "Rapor Anak" page that lists the published reports of the selected child by academic year and period. Opening one SHALL show the web report view, a PDF download, and the visible uploaded files. The page SHALL work for children in every class, including KB.

#### Scenario: KB child with a published narrative report
- **WHEN** a parent of a KB student opens "Rapor Anak" after the teacher published the semester report
- **THEN** the narrative report and its visible files are shown

#### Scenario: Nothing published yet
- **WHEN** no report of the selected child is published
- **THEN** the page states that no report has been published yet
