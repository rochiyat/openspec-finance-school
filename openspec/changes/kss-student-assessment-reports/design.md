## Context

See proposal.md for motivation. Constraints that shape the approach:

- **Source data already matches the PPDB assessment shape.** In KSS, `education_focuses` (Pendidikan Iman, Pendidikan Ego & Individualitas, Pendidikan Bahasa, Psikomotor) correspond to the four PPDB aspects. `kss_indicators` per class (Perasaan, Ucapan, Konsep Diri, …) correspond to the PPDB indicator groups. `observable_indicators` correspond to the PPDB items. Per day and per student, `student_focus_entries` record that a focus was observed, and `student_focus_entry_observables.is_checked` records which items were seen.
- **KSS indicators are seeded only for SSA and SSB.** KB classes (`KB - Jum`, `KB - Kamis`) have no indicators, so they cannot be scored.
- **Existing building blocks:** `DailyClassReportsRepository.findPublishedByStudentWithSummary`, `EvidenceCloudinaryService.uploadEvidence`, `StudentParentMapsService.isParentOfStudent` / `getParentsByStudent`, `NotificationsService.createNotification` (idempotent by `sourceEventKey`), `AuditLogsService.registerEvent`, and `jspdf` in kss-frontend.
- **Module boundaries:** repositories stay private to their owning module. The student-reports module reads daily reports, indicators and parent evidences through exported services or read-only repository methods that the owning module exposes (`src/modules/README.md`).
- **PPDB reference implementation:** `iqrolife/lib/assessment-score.ts`, `lib/data/assessment-bank.ts` (`bandFor`), `components/assessment/assessment-report.tsx`, `readiness-radar.tsx` and `lib/assessment-pdf.ts`. These are ported, not imported, because the apps stay independent.

## Goals / Non-Goals

**Goals:**
- One structured report per student, academic year and term, with scores computed the same way as the PPDB assessment.
- Teachers can edit on the web, download PDF/DOCX, upload a final file, and publish to parents.
- Parents see only published reports of their own children.
- Narratives can be produced now by the coding agent, without an in-app AI dependency.

**Non-Goals:**
- Seeding KSS indicators for KB. KB uses the NARRATIVE template until indicators exist; after that, the template switches automatically.
- Parsing uploaded DOCX back into `content`. An uploaded file is an opaque attachment.
- Embedding evidence photos or videos in the report or the export. Evidence text is used as input for narratives only.
- Kepsek approval workflow or e-signature. FINAL is set by GURU, KEPSEK or SUPERADMIN.
- Monthly reports and free date ranges as separate report rows. A report period is one of three fixed types (Decision 10); its dates can only be narrowed.

## Decisions

### 1. Same module and route, structured content plus a separate files table
Keep `student-reports` (backend module, `teacher/student-reports` route) as the single owner. Extend `student_reports`:
- `academic_year_id`, `term` (1–4, three months each)
- `period_start`, `period_end` (default: the term's three months within the academic year, editable)
- `template` (`ASSESSMENT` | `NARRATIVE`)
- `content` jsonb, `content_version` int
- `generation_source` (`AGENT` | `GEMINI` | `MANUAL`)
- `generated_at`, `finalized_at`, `published_at`

Add a unique constraint on (`student_id`, `academic_year_id`, `term`); Decision 10 replaces it with (`student_id`, `academic_year_id`, `period_type`, `period_number`). Legacy rows have NULL year/term, so the constraint does not block them. They keep `generated_draft`/`final_content` and are shown to teachers as "laporan lama".

The new table `student_report_files` holds `id`, `student_report_id` (FK, cascade), `file_kind` (`PDF` | `DOCX`), `cloudinary_public_id`, `url`, `original_filename`, `file_size_bytes`, `uploaded_by_user_id`, `is_published`, `created_at`.

*Alternatives:* a separate module and route for "published reports" would split one document across two owners, and make it hard to tell which file belongs to which generated data. Storing the uploaded file inside `content` would make the jsonb carry storage concerns.

### 2. Content schema (version 2)
Version 1 used PPDB-style frequency scores; it was replaced before any report was published (see Decision 3). Reports are regenerated in DRAFT to move to version 2.
```ts
type Level = 1 | 2 | 3 | 4;   // BB, MB, BSH, BSB (Kurikulum Merdeka PAUD)
interface StudentReportContentV2 {
  version: 2;
  template: 'ASSESSMENT' | 'NARRATIVE';
  identity: { studentName: string; nis: string | null; className: string; parentNames: string[]; teacherName: string };
  period: { academicYearName: string; term: 1 | 2 | 3 | 4; start: string; end: string };
  attendance: { schoolDays: number; present: number; sick: number; permission: number; absent: number };
  overall: { level: Level | null } | null;                          // null for NARRATIVE; never shown as a number
  focuses: Array<{
    focusId: string; label: string;
    level: Level | null;                                              // from final indicator levels
    narrative: string;
    indicators: Array<{                                               // [] for NARRATIVE
      indicatorId: string; label: string;
      itemsWithEvidence: number; total: number; dataSufficient: boolean;
      suggestedLevel: Level | null;                                   // system
      teacherLevel: Level | null; teacherReason: string; confirmed: boolean;  // teacher
      level: Level | null;                                            // final: teacherLevel when confirmed, else suggestedLevel
      recommendation: string; recommendationEdited?: boolean;
      items: Array<{ observableId: string; description: string; evidenceDays: number; evidenceWeeks: number; lastEvidenceDate: string | null; level: Level | null }>;
    }>;
  }>;
  strengths: string; nextSteps: string; homeRecommendations: string; teacherNotes: string;
}
```
Labels and descriptions are snapshotted into `content`, so renaming an indicator later does not change a published report.

### 3. Evidence-week scoring with teacher judgement
`computeStudentReportScores` (pure functions in `student-reports/scoring/`), fed by `StudentReportGenerationService`:
1. Load the student's records from **published** daily class reports in [start, end]; count attendance as before.
2. Items: the active observables of the active KSS indicators of the student's current class.
3. Per item: evidence days (checked), evidence weeks (distinct ISO weeks), last evidence date. Level: 0 weeks → null ("Belum terlihat"); 1–2 → MB; 3–5 → BSH; ≥ 6 → BSB if the last evidence falls in the recent window (28 days ending at the earlier of the period end and the last published day), else BSH. BB is never suggested.
4. Indicator: suggested level only if items with evidence ≥ ceil(total / 2) (`dataSufficient`), as the most frequent item level (lower on a tie). Final level = `teacherLevel` when `confirmed`, else `suggestedLevel`.
5. Focus and overall: most frequent final level of their children with a level (lower on a tie). Recomputed whenever the teacher changes an indicator.
6. Template = `ASSESSMENT` if the class has items, otherwise `NARRATIVE`.

Why: the version 1 rule (checked days ÷ days the focus was observed, mapped to PPDB's 1–5 Likert thresholds) measured how often a box was ticked rather than what the child can do. Behaviours tied to rare activities (meronce, sensory experiments), behaviours teachers stop ticking once mastered, and gaps between the checklist and the written evidence all pushed real reports into "Perlu Pendampingan Intensif". Counting weeks with evidence removes the dependence on how often an activity happens, "Belum terlihat" no longer counts as 0, and the teacher, who also reads the written evidence, makes the final call per indicator, as PAUD assessment practice expects. The thresholds are constants in the scoring module so the school can tune them.

*Alternatives:* restricting the denominator to days with an opportunity needs a per-item "no opportunity" flag or an activity-to-item mapping that the daily form does not record yet; it stays a later improvement. Tagging written evidence to behaviours with AI is also later and would only feed evidence, never set levels.

### 3a. Teacher judgement
`PUT /student-reports/:id/content` also accepts `assessments: [{ indicatorId, teacherLevel (1–4 or null), reason, confirmed }]`. A reason (≤ 1,000 characters) is required when `teacherLevel` differs from `suggestedLevel`. Saving recomputes focus and overall levels. `POST /:id/finalize` returns 409 listing the unconfirmed indicators. Regeneration keeps `teacherLevel`, `teacherReason` and `confirmed` per `indicatorId`. The agent import never sets levels.

### 4. Generate and regenerate
`POST /student-reports/generate` with `{ classId, academicYearId, term, studentIds?, periodStart?, periodEnd? }` computes and upserts DRAFT reports for every student in the class (or only the listed ones).
- If a report is FINAL or PUBLISHED, it is skipped and reported as `locked`.
- On regenerate, evidence, suggested levels, attendance, identity and items are replaced; teacher levels are kept (Decision 3a). The texts the teacher or agent wrote (`narrative`, edited `recommendation`, `strengths`, `nextSteps`, `homeRecommendations`, `teacherNotes`) are kept, matched by `focusId` and `indicatorId`.
- Default indicator recommendations come from a static table, ported from PPDB `recoFor` and keyed by indicator label and level (MB → 2, BSH → 3, BSB → 4, BB → 1, no level → starting stimulation). They are used only when the field is empty.

Gemini (`POST /student-reports/:id/generate-narratives`) fills empty narrative fields from the computed content plus evidence texts, and sets `generation_source = GEMINI`. The key is sent in the `x-goog-api-key` header.

### 5. Agent path through backend CLI scripts
The coding agent does not log in as a user and never handles credentials. Two scripts boot the Nest application context against the configured database:
- `npm run student-reports:export-source -- --class <id> --year <id> --term <1-4> --out <file.json>` runs step 4 for the class (as the class homeroom teacher). It then writes, for each report: `reportId`, the computed content, the daily notes and focus `evidenceText` in the period, and the parent evidence texts in the period. Names are included because the narrative needs them. The file is written to a path the operator chooses, and it is not committed.
- `npm run student-reports:import-narratives -- --in <file.json>` takes `[{ reportId, focuses: [{ focusId, narrative, indicators: [{ indicatorId, recommendation }] }], strengths, nextSteps, homeRecommendations }]`. It validates the input with the same DTO as the web editor, writes only to DRAFT reports, and sets `generation_source = AGENT`. It prints one line per report: updated or skipped, with the reason.

*Alternatives:* calling the HTTP API would need a teacher token in the agent's hands. A one-off SQL write would bypass validation and the lock rules.

### 6. Lifecycle and editing
- `PUT /student-reports/:id/content` replaces the editable text fields (DTO-validated, each text at most 5,000 characters). Only DRAFT reports can be edited, and editing sets `generation_source = MANUAL` if it was not already.
- `POST /:id/finalize` moves DRAFT → FINAL. `POST /:id/reopen` moves FINAL → DRAFT.
- `POST /:id/publish` moves FINAL → PUBLISHED. `POST /:id/unpublish` moves PUBLISHED → FINAL.

Invalid transitions return 409. Every transition is written to `audit_logs`. Audit entries use entity type `STUDENT_REPORT`, action `UPDATE`, and the transition in `metadata`.

Legacy endpoints stay for old free-text reports: `PUT /:id/finalize` refuses structured reports and the PUBLISHED status, and `POST /generate-draft` no longer overwrites a FINAL or structured report. Roles: GURU (homeroom teacher of the student's class), KEPSEK, SUPERADMIN. A GURU who is not the homeroom teacher of the class gets 403.

### 7. Exports
- **PDF:** in the browser. `StudentReportView` (a port of `assessment-report.tsx` + `readiness-radar.tsx`) is rendered off-screen and paged with `jspdf` + `html-to-image` (pinned `1.11.11`, same as iqrolife), using the `[data-pdf-block]` approach from `iqrolife/lib/assessment-pdf.ts`, with the KSS letterhead on every page. The radar stays plain SVG like in PPDB rather than recharts, whose ResizeObserver-based sizing does not survive the off-screen capture. The report always uses fixed light "paper" colors, also in dark mode, so screen and PDF match.
- **DOCX:** `GET /student-reports/:id/export/docx` built with the `docx` package (pinned `9.8.1`); the file name is ASCII-only (`Rapor-<name>-S<term>-<year>.docx`) because it goes into `Content-Disposition`. It contains a header, identity table, attendance, a table of focus levels, a table per focus with indicator levels and recommendations, narratives and notes, without any overall number. The radar chart is left out of DOCX (the tables carry the same data), so the file stays fully editable.

### 8. Files, publication and parent access
- `POST /student-reports/:id/files` (multipart, PDF or DOCX, ≤ 10 MB; extension, MIME type and file signature checked) uploads through `EvidenceCloudinaryService.uploadDocument` as a raw asset under `student-reports/<reportId>`, keeping the extension in the public id. `GET /:id/files` lists them. `DELETE /:id/files/:fileId` is allowed while the report is not PUBLISHED. `PATCH /:id/files/:fileId` toggles `is_published` at any status. Uploads far above the limit are stopped by multer with 413.
- Publishing requires FINAL. It sets `published_at` and emits `student-report.published`; the notification listener creates an in-app notification for every parent from `getParentsByStudent`, with `sourceEventKey = student-report.published:<reportId>:<publishedAt ms>:<parent userId>` (the parent id keeps one parent's key from suppressing the other's).
- Parent endpoints: `GET /student-reports/parent/student/:studentId` and `GET /student-reports/parent/:id`. Both check `isParentOfStudent` and return only PUBLISHED reports with only `is_published` files. Anything else returns 404, so parents cannot probe for drafts. The existing generic `GET` endpoints drop the PARENT role.
- Parent page "Rapor Anak" (`/parent/reports`) lists published reports for the selected child, renders `StudentReportView`, and offers PDF download plus the published files. The KB block is removed.

### 9. Teacher UI
`GET /student-reports?classId=&term=` lists light summaries (status, template, overall band, timestamps) of the class's active students for the class's own academic year, plus their legacy free-text reports; teachers cannot list academic years, so the year always comes from the class.

`teacher/student-reports` becomes:
- **List:** filters for class, academic year and term. A table of students with status, template, overall band and last generated time. Bulk "Generate" for the class.
- **Detail page** with three sections:
  1. Data & skor: read-only, with item-level observed/checked days.
  2. Narasi & catatan: editable while in DRAFT, with an optional "Isi narasi dengan Gemini" action.
  3. File & publikasi: upload, toggle file visibility, finalize/reopen/publish/unpublish, and PDF/DOCX download.

The detail page lives at `teacher/student-reports/:id`; it opens on the narrative editor and has a fourth tab with the report preview (also the source of the PDF, showing unsaved edits). Only changed fields are sent on save, so untouched default recommendations keep following their band. Legacy reports open read only on the same route. The old create/edit form and its jsPDF generator are removed.

### 10. Period types: term (internal), semester (parents), year
The school wants term reports as a working tool for teachers and the semester report as the official report for parents, with year reports possible later.

- **Columns:** `period_type` (`TERM` | `SEMESTER` | `YEAR`, not null) and `period_number` (TERM 1–4, SEMESTER 1–2, YEAR 1) replace `term`. The migration backfills existing rows as `TERM` with `period_number = term`, drops `term`, and replaces the unique index with (`student_id`, `academic_year_id`, `period_type`, `period_number`). Legacy rows keep NULL year and period. `content.period` becomes `{ academicYearName, type, number, start, end }`; the migration rewrites old content `term: n` to `{ type: 'TERM', number: n }`. Content also stores `scoring: { effectiveWeeks, weeksForBsh, weeksForBsb }` so the basis of the levels is visible.
- **Dates:** TERM as before. SEMESTER 1 = academic year start → 31 December, SEMESTER 2 = 1 January → academic year end. YEAR = academic year start → end. Dates can still be narrowed with `periodStart`/`periodEnd`.
- **Generate:** `POST /student-reports/generate` takes `periodType` and `periodNumber` (`term` stays accepted as `TERM` + number for one release). The CLI takes `--period term|semester|year --number <n>`, with `--term <n>` kept as a shortcut. A semester or year report is computed from the raw daily records of its whole period, never by averaging term reports.
- **Thresholds scale with the period.** `effectiveWeeks` = distinct ISO weeks in the period with at least one published daily record for the student. BSH needs at least `max(3, ceil(0.20 × effectiveWeeks))` evidence weeks and BSB at least `max(6, ceil(0.45 × effectiveWeeks))` plus recent evidence. With up to 13 effective weeks this is exactly the current 3 / 6 rule, so existing term reports do not change; a semester of 26 weeks needs 6 and 12.
- **Progress from term reports.** When a SEMESTER or YEAR report is generated, every indicator gets `progress: [{ periodType: 'TERM', periodNumber, level }]` from the term reports of the same student inside its period (any status, final level). It is shown as "Perkembangan" (e.g. T1 MB → T2 BSH) in the teacher editor next to the suggestion, and in the report view and exports. The teacher's term reasons are shown in the editor only.
- **Publication:** only SEMESTER and YEAR reports can be published; publishing a TERM report returns 409 `REPORT_PERIOD_INTERNAL`, and the teacher UI hides the publish action and the parent-visibility toggle for term reports. Parent endpoints therefore never return term reports. The notification and parent page use the period label ("Rapor Semester 1 2026/2027").
- **Teacher confirmation:** required to finalize SEMESTER and YEAR reports. For TERM reports it is optional; finalizing a term report with unconfirmed indicators is allowed and simply locks the suggestions.
- **UI:** the teacher list gets a period type selector (Triwulan / Semester / Tahunan) next to the number; the default is the term or semester containing today. Labels: "Triwulan n", "Semester n", "Tahunan". DOCX file names use `T<n>`, `S<n>` or `TH`.
- **Hagia's existing Triwulan 1 draft** becomes a TERM report through the backfill and stays internal.

*Alternatives:* free date ranges would allow overlapping reports per child and make it unclear which one parents see. Deriving the semester level from the term levels would hide behaviours that only appear across the longer period and would double-count teacher judgements.

## Risks / Trade-offs

- [Few observation days make scores swing] → the detail view shows `observedDays` per item, and an indicator with no observed item shows "Belum teramati" instead of a low score. Teachers can see thin data before finalizing.
- [Scoring drifts from PPDB] → a shared fixture test checks KSS scoring against expected values taken from `iqrolife/lib/assessment-score.ts`.
- [Uploaded files are public Cloudinary URLs] → URLs are unguessable and only returned to authorized users. Signed delivery is a later hardening step if needed.
- [Export JSON contains student personal data] → it is written only to an operator-chosen path, never committed, and the script prints a reminder to delete it after import.
- [Student moved class mid-term] → indicators come from the current class only. This is documented, and acceptable for MVP.

## Migration Plan

0. (Decision 10) A later migration adds `period_type` / `period_number`, backfills from `term`, swaps the unique index and drops `term`; its down migration restores `term` for TERM rows and deletes nothing else.

1. Run the migration: add columns to `student_reports`, create `student_report_files`, and add the unique index.
2. Deploy the backend, then the frontend. Legacy reports stay visible to teachers only.
3. For the first term, run `export-source` per class. The agent then writes narratives and runs `import-narratives`, and teachers review, finalize, upload and publish.

Rollback: revert the frontend. Then run the migration down, which drops only the new table and columns; legacy text columns are untouched.
