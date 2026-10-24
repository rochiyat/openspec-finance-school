## 1. Data model

- [x] 1.1 Migration: add `academic_year_id`, `term`, `period_start`, `period_end`, `template`, `content` jsonb, `content_version`, `generation_source`, `finalized_at`, `published_at` to `student_reports`; add status `PUBLISHED`; unique (`student_id`, `academic_year_id`, `term`)
- [x] 1.2 Migration and entity: `student_report_files` (`student_report_id` FK cascade, `file_kind`, `cloudinary_public_id`, `url`, `original_filename`, `file_size_bytes`, `uploaded_by_user_id`, `is_published`, `created_at`)
- [x] 1.3 Update `StudentReportEntity`, add `StudentReportContentV1` types and band constants (ported from PPDB `bandFor`)
- [x] 1.4 Expose the read methods student-reports needs from the owning modules (published daily records with focus entries and observable results per student and period, active indicators and observables per class, parent evidence texts per student and period)

## 2. Scoring and generation

- [x] 2.1 Implement pure `StudentReportScoringService` (attendance, item frequency → 1..5, indicator/focus/overall averages, bands, template choice)
- [x] 2.2 Unit tests: thresholds at each boundary, never-observed focus, indicator with a not-observed item, NARRATIVE for class without indicators, draft and out-of-period daily reports ignored
- [x] 2.3 Shared fixture test comparing KSS results with expected values from `iqrolife/lib/assessment-score.ts`
- [x] 2.4 Port default indicator recommendations (PPDB `recoFor`) keyed by indicator label and band
- [x] 2.5 `POST /student-reports/generate` for a class, year and term (optional student ids and period dates): upsert DRAFT, skip FINAL/PUBLISHED as `locked`, keep written texts on regenerate
- [x] 2.6 Unit tests for generate: upsert without duplicates, locked skip, text preserved by focus and indicator id

## 3. Agent scripts

- [x] 3.1 `student-reports:export-source` script (Nest application context): generate drafts for the class, write the JSON with reportId, computed content, daily notes, focus evidence and parent evidence texts
- [x] 3.2 `student-reports:import-narratives` script: validate with the content DTO, write to DRAFT only, set `generation_source = AGENT`, print updated/skipped per report
- [x] 3.3 Tests for the import rules (draft updated, final skipped, invalid payload rejected)
- [x] 3.4 Document both scripts in AGENTS.md and the kss-backend README

## 4. Lifecycle, editing and access

- [x] 4.1 `PUT /student-reports/:id/content` with DTO (text fields only, at most 5,000 characters each), DRAFT only, sets MANUAL source
- [x] 4.2 `finalize`, `reopen`, `publish`, `unpublish` endpoints with the transition table (409 otherwise) and audit log entries
- [x] 4.3 Access guard: SUPERADMIN, KEPSEK, or GURU who is homeroom teacher of the student's class; remove PARENT from staff endpoints
- [x] 4.4 Gemini narratives endpoint: fill empty fields only, key in `x-goog-api-key` header, `generation_source = GEMINI`
- [x] 4.5 Unit and authorization tests: transitions, edit locked report, non-homeroom GURU 403, parent on staff endpoint 403

## 5. Files, publication and parent API

- [x] 5.1 File upload (PDF/DOCX, at most 10 MB, MIME and extension check) through `EvidenceCloudinaryService` as raw under `student-reports/<reportId>`; delete and visibility toggle; delete blocked when PUBLISHED
- [x] 5.2 Publish notification to every linked parent with `sourceEventKey = student-report-published:<reportId>:<publishedAt>`
- [x] 5.3 Parent endpoints `GET /student-reports/parent/student/:studentId` and `GET /student-reports/parent/:id` (ownership via `isParentOfStudent`, PUBLISHED only, visible files only, 404 otherwise)
- [x] 5.4 Tests: other family 404, draft 404, hidden file excluded, two parents notified once each
- [ ] 5.5 e2e test for generate → edit → finalize → upload → publish → parent read (written: `test/student-reports.db.e2e-spec.ts`, opt-in via `E2E_DATABASE_NAME`; not yet run against Postgres)

## 6. DOCX export

- [x] 6.1 Add `docx` dependency; `GET /student-reports/:id/export/docx` with header, identity, attendance, overall, one score table per focus, narratives, recommendations, notes (NARRATIVE variant without scores)
- [x] 6.2 Test that the generated document contains the expected sections for both templates

## 7. Frontend: shared report view and PDF

- [x] 7.1 API client for the new endpoints in `src/lib/student-reports.ts` (types mirror backend status and content exactly)
- [x] 7.2 `StudentReportView` ported from `iqrolife/components/assessment/assessment-report.tsx` and `readiness-radar.tsx` (plain SVG radar with 3.4 baseline, band scale, focus bars, indicator sections), with a NARRATIVE variant
- [x] 7.3 Block-based PDF download ported from `iqrolife/lib/assessment-pdf.ts` (`src/lib/student-report-pdf.ts`); the old `generateStudentReportPdf` is removed together with the legacy teacher form in 8.x
- [x] 7.4 Component tests for both templates

## 8. Frontend: teacher pages

- [x] 8.1 List page (with new `GET /student-reports?classId=&term=` endpoint): class and term (triwulan) filters; generate button switched off for now (`TEACHER_GENERATE_ENABLED`); student table with status, template, band, last generated; bulk generate with the locked result shown
- [x] 8.2 Detail page: data and scores (observed/checked days per item), narrative and notes editor with validation, optional Gemini action, file upload and visibility, lifecycle buttons, PDF/DOCX download
- [x] 8.3 Legacy reports shown read-only as "laporan lama"

## 9. Frontend: parent page

- [x] 9.1 Replace `ParentStudentReportPage` with "Rapor Anak": published reports per term for the selected child, report view, PDF download, visible files; remove the KB block; rename the sidebar item and show it for KB children too
- [x] 9.2 Component test: empty state, KB narrative report, files list

## 10. Evidence-week scoring (content v2)

- [x] 10.1 Content v2 types and level helpers (BB/MB/BSH/BSB); evidence-week item levels, indicator suggestion with data sufficiency, focus/overall by most frequent level
- [x] 10.2 Teacher judgement: `assessments` in the content DTO, reason rule, recompute on save, keep on regenerate, finalize blocked while unconfirmed
- [x] 10.3 Update DOCX, Gemini prompt, class summaries and default recommendations to levels
- [x] 10.4 Frontend: level scale and radar (1–4, BSH baseline), report view without an overall number, data tab with evidence weeks, per-indicator teacher judgement in the editor, finalize hint
- [x] 10.5 Tests for the scoring rules, teacher judgement, exports and pages
- [x] 10.6 Deploy, then regenerate the existing DRAFT reports (Hagia, Triwulan 1) with content v2

## 11. Period types (term internal, semester for parents, year)

- [x] 11.1 Migration: `period_type` + `period_number`, backfill TERM from `term`, swap the unique index, drop `term` (down restores it); entity and content `period` `{ type, number }`; the migration rewrites old `term` content
- [x] 11.2 Period resolution for SEMESTER and YEAR; generate DTO `periodType`/`periodNumber` (accept `term` for one release); CLI `--period` / `--number` with `--term` shortcut
- [x] 11.3 Scoring: effective weeks and scaled thresholds `max(3, ceil(0.2E))` / `max(6, ceil(0.45E))`; tests that terms of up to 13 weeks keep 3/6 and a 26-week semester needs 6/12
- [x] 11.4 Indicator `progress` from term reports when generating SEMESTER/YEAR; shown in editor, report view, PDF and DOCX
- [x] 11.5 Lifecycle: publish only SEMESTER/YEAR (409 `REPORT_PERIOD_INTERNAL`); confirmation required to finalize only SEMESTER/YEAR; period labels in notification, DOCX file name and parent page
- [x] 11.6 Frontend: period type selector in the list, labels, hide publish and file visibility for term reports, progress display; tests
- [ ] 11.7 Deploy and check that Hagia's Triwulan 1 draft is a TERM report with unchanged levels

## 12. Rollout

- [ ] 12.1 Run lint, unit and e2e suites in both apps
- [ ] 12.2 Generate the first semester for SSA, SSB and KB through the agent scripts and hand the drafts to teachers for review
