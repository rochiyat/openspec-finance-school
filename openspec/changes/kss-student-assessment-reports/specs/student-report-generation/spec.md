## Purpose
Turns a student's published daily observations in a term into a structured report, scored the same way as the PPDB KSS readiness assessment, with narratives filled by the coding agent, by Gemini, or by the teacher.

## ADDED Requirements

### Requirement: One report per student and period
The system SHALL keep at most one student report per student, academic year, period type and period number.

#### Scenario: Generating twice for the same period
- **WHEN** a teacher generates reports for a class, academic year and period that already has a DRAFT report for a student
- **THEN** that student's existing report is updated and no second report is created

### Requirement: Report periods of three types
The system SHALL support three period types. TERM (triwulan): term 1 from the academic year start to 30 September, term 2 from 1 October to 31 December, term 3 from 1 January to 31 March, and term 4 from 1 April to the academic year end. SEMESTER: semester 1 from the academic year start to 31 December, semester 2 from 1 January to the academic year end. YEAR: the whole academic year. A report period SHALL default to its type and number and MAY be narrowed with explicit start and end dates. Semester and year reports SHALL be computed from the daily records of their whole period, not from term reports.

#### Scenario: Semester 1 period
- **WHEN** academic year 2026/2027 starts on 2026-07-13 and a report is generated for semester 1
- **THEN** its period runs from 2026-07-13 to 2026-12-31

#### Scenario: Term and semester of the same months coexist
- **WHEN** a student has a Triwulan 2 report and a Semester 1 report is generated
- **THEN** both reports exist separately

#### Scenario: Term 2 period
- **WHEN** a report is generated for term 2 of academic year 2026/2027
- **THEN** its period runs from 2026-10-01 to 2026-12-31

#### Scenario: Last term follows the academic year end
- **WHEN** academic year 2026/2027 ends on 2027-07-15 and a report is generated for term 4
- **THEN** its period runs from 2027-04-01 to 2027-07-15

### Requirement: Scores come only from published daily reports in the period
The system SHALL compute report data only from daily class reports with status published whose date is within the report period, and MUST NOT use AI output for any score.

#### Scenario: Draft daily report is ignored
- **WHEN** a student has a checked observable in a daily report that is still a draft
- **THEN** that observation does not count toward the student's report

#### Scenario: Day outside the period is ignored
- **WHEN** a published daily report is dated after the report period end
- **THEN** it does not count toward observed or checked days

### Requirement: Behaviour level from weeks with evidence
For each active observable indicator of the student's class, the system SHALL count the evidence days (days in the period where the behaviour is checked) and the evidence weeks (distinct ISO weeks, Monday to Sunday, with at least one evidence day), and SHALL set the behaviour level as: no evidence → "Belum terlihat" (null, not scored); evidence in fewer weeks than the BSH threshold → MB (Mulai Berkembang, 2); evidence in at least the BSH threshold → BSH (Berkembang Sesuai Harapan, 3); evidence in at least the BSB threshold with at least one evidence day in the recent window → BSB (Berkembang Sangat Baik, 4), otherwise BSH. With effective weeks being the distinct ISO weeks in the period that have at least one published daily record of the student, the BSH threshold SHALL be max(3, ceil(0.20 × effective weeks)) and the BSB threshold max(6, ceil(0.45 × effective weeks)), so a term of up to 13 effective weeks uses 3 and 6 weeks. The recent window SHALL be the 28 days ending on the earlier of the period end and the last published day in the period. The system SHALL NOT suggest BB (Belum Berkembang, 1); only the teacher can set it.

#### Scenario: Behaviour tied to a rare activity
- **WHEN** a behaviour was checked on 1 day in the term because its activity happened once
- **THEN** its level is MB, not the lowest level

#### Scenario: Consistent behaviour
- **WHEN** a behaviour was checked in 8 different weeks, the last one within the recent window
- **THEN** its level is BSB

#### Scenario: Consistent early but not recently
- **WHEN** a behaviour was checked in 7 different weeks, none of them within the recent window
- **THEN** its level is BSH

#### Scenario: Semester thresholds
- **WHEN** a semester report has 26 effective weeks and a behaviour was checked in 8 weeks, including recently
- **THEN** its level is BSH, because BSB needs 12 weeks in that semester

#### Scenario: No evidence
- **WHEN** a behaviour was never checked in the period
- **THEN** it is "Belum terlihat" and does not lower any level

### Requirement: Suggested indicator, focus and overall levels
The system SHALL suggest an indicator level only when at least half of its behaviours (rounded up) have evidence; otherwise the indicator SHALL be marked "data belum cukup" with no suggested level. The suggested level SHALL be the most frequent level among its behaviours with evidence, taking the lower level on a tie. The final indicator level SHALL be the teacher's level once the teacher confirmed the indicator, and the suggested level before that. A focus level SHALL be the most frequent final level among its indicators with a level (lower on a tie), and null when none has a level. The overall level SHALL be computed the same way from the focus levels and SHALL NOT be shown to parents as a number.

#### Scenario: Too little evidence for an indicator
- **WHEN** an indicator has 4 behaviours and only 1 has evidence
- **THEN** the indicator has no suggested level and is marked "data belum cukup"

#### Scenario: Tie between levels
- **WHEN** an indicator's behaviours with evidence have levels BSB, BSB, MB and MB
- **THEN** the suggested level is MB

#### Scenario: Teacher level wins
- **WHEN** the system suggests BSH for an indicator and the teacher confirms it as BSB
- **THEN** the final indicator level, and the focus level built from it, use BSB

### Requirement: Semester and year reports show term progress
When a SEMESTER or YEAR report is generated, the system SHALL attach to each indicator the final levels of the same student's term reports inside its period, in term order, and SHALL show them as progress in the teacher editor, the report view and the exports. Terms without a report SHALL be left out.

#### Scenario: Progress across two terms
- **WHEN** a student's Triwulan 1 report has MB for Perasaan and Triwulan 2 has BSH, and Semester 1 is generated
- **THEN** the Semester 1 report shows Perasaan progress T1 MB → T2 BSH

### Requirement: Template depends on available indicators
The system SHALL use the ASSESSMENT template when the student's class has at least one active observable indicator, and the NARRATIVE template otherwise. NARRATIVE reports SHALL contain identity, period, attendance, a narrative per education focus and teacher text fields, and SHALL NOT contain scores or bands.

#### Scenario: KB student
- **WHEN** a report is generated for a student in a KB class without KSS indicators
- **THEN** the report uses the NARRATIVE template with one narrative section per active education focus and no scores

#### Scenario: SSA student
- **WHEN** a report is generated for a student in SSA
- **THEN** the report uses the ASSESSMENT template with behaviour evidence and suggested indicator, focus and overall levels

### Requirement: Attendance summary
The system SHALL include the number of school days in the period, and the counts of present, sick, permission and absent-without-reason, taken from the student's daily records.

#### Scenario: Attendance counted
- **WHEN** a student has 20 daily records in the period, 2 of them marked sick
- **THEN** the report shows 20 school days and 2 sick

### Requirement: Regeneration is limited to drafts and keeps written text
The system SHALL regenerate only DRAFT reports. It SHALL replace computed data and SHALL keep existing narrative, recommendation and note texts, matched by focus and indicator.

#### Scenario: Final report is locked
- **WHEN** a teacher generates reports for a class where one student's report is FINAL
- **THEN** that report is unchanged and the response lists it as locked

#### Scenario: Teacher text survives regeneration
- **WHEN** a teacher regenerates a DRAFT report whose Pendidikan Iman narrative was already written
- **THEN** the evidence and suggested levels are recomputed and the narrative text is unchanged

#### Scenario: Teacher judgement survives regeneration
- **WHEN** a DRAFT report with a confirmed teacher level for an indicator is regenerated
- **THEN** the teacher level, reason and confirmation are kept for that indicator

### Requirement: Narratives from the coding agent through backend scripts
The system SHALL provide a backend script that generates DRAFT reports for a class, academic year and period of any type (optionally only for listed students of that class) and writes their computed content and the period's evidence texts to a JSON file. It SHALL also provide a script that imports narratives from a JSON file into DRAFT reports only, validating the input like the web editor, and recording the source as AGENT.

#### Scenario: Import into a draft
- **WHEN** the import script receives narratives for a DRAFT report
- **THEN** the narratives are saved, `generation_source` is AGENT, and the script reports the report as updated

#### Scenario: Import into a final report
- **WHEN** the import script receives narratives for a FINAL report
- **THEN** nothing is written for that report and the script reports it as skipped because it is locked

### Requirement: Optional Gemini narratives
The system SHALL let an authorized teacher fill the empty narrative fields of a DRAFT report with Gemini, using the teacher's active Gemini key sent in a request header, and SHALL record the source as GEMINI.

#### Scenario: Gemini fills only empty fields
- **WHEN** a teacher runs Gemini on a draft where one focus narrative is already written
- **THEN** only the empty narrative fields are filled
