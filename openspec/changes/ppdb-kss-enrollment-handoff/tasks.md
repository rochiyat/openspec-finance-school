## 1. KSS data model

- [x] 1.1 Add `ppdb_enrollments` entity and migration (`source_id` unique, `status`, `user_id`, `parent_id`, `student_id`, `mapping_id`, `created_at`, `completed_at`)
- [x] 1.2 Add `ppdb_class_mappings` entity and migration (`academic_year_id`, normalized `ppdb_level`, `class_id`, unique year + level)
- [x] 1.3 Create `ppdb-integration` module that owns both repositories and exports only its services

## 2. KSS class mapping management

- [x] 2.1 Implement mapping service: list with year and class names, create, update, delete; normalize level; 409 on duplicate year + level; 422 when the class is in another year
- [x] 2.2 Add `/ppdb-class-mappings` controller guarded by `BearerAuthGuard` + `@Roles('SUPERADMIN')`
- [x] 2.3 Unit tests for mapping rules (uniqueness, cross-year class, level normalization, non-superadmin rejected)

## 3. KSS account setup link

- [x] 3.1 Add `AuthService.sendAccountSetupLink(userId)` reusing the reset-token table with a 72-hour TTL and setup wording, email plus WhatsApp when a phone exists
- [x] 3.2 Unit test: token TTL, both channels, no password in any message

## 4. KSS enrollment intake

- [x] 4.1 Add `PpdbIntegrationGuard` (constant-time `x-integration-key` check against `PPDB_INTEGRATION_API_KEY`, fail closed when unset, ignores bearer tokens)
- [x] 4.2 Add intake DTO with validation (sourceId, academicYearName, level, student fullName/gender, parent fullName/email/phone/address)
- [x] 4.3 Implement resumable intake service: enrollment row by `source_id`, resolve year and mapping before any write, find-or-create user (add `PARENT` role if missing, `sendNotification: false`, unusable password), parent, student, primary mapping, mark completed, then send setup link for new users
- [x] 4.4 Add `POST /integrations/ppdb/enrollments` controller returning student id, parent id, NIS, `parentReused`
- [x] 4.5 Unit tests: new family, sibling reuse, staff user gains PARENT role, completed source id returns existing ids, resume after partial progress, missing mapping / unknown year create nothing, guard rejects missing, wrong and unconfigured key
- [x] 4.6 e2e test for the intake endpoint against the test database (`test/ppdb-intake.db.e2e-spec.ts`, opt-in via `E2E_DATABASE_NAME`; HTTP contract test without DB in `test/ppdb-intake.e2e-spec.ts`)

## 5. KSS frontend

- [x] 5.1 Add superadmin "Pemetaan Kelas PPDB" page: list, create, edit, delete mappings per academic year
- [x] 5.2 Add the page to the superadmin navigation and component tests for the form validation

## 6. PPDB handoff (iqrolife-backend)

- [x] 6.1 Add migration 004 (TS + SQL) for `ppdb_kss_handoffs` and the Sequelize model
- [x] 6.2 Add KSS client util (payload builder with gender mapping, 10-second timeout, no payload logging, fails with "KSS belum dikonfigurasi" when env is missing)
- [x] 6.3 Create the handoff row in the accept transaction and send after commit; include handoff outcome in the accept response
- [x] 6.4 Add `POST /api/formulir-pendaftaran/:id/kss-handoff` (PPDB staff only, 409 when already SENT, creates the row for formulir accepted before this change)
- [x] 6.5 Include handoff status, attempts and last error in formulir list and detail responses for staff
- [x] 6.6 Unit tests for payload building and gender mapping; smoke tests for accept success, KSS down, retry, already sent, parent forbidden

## 7. PPDB frontend (iqrolife)

- [x] 7.1 Proxy route for the retry endpoint, forwarding backend 4xx errors
- [x] 7.2 Show handoff status badge, last error and "Kirim ke KSS / Kirim ulang" action in the formulir review list
- [x] 7.3 Show the handoff outcome after accepting a formulir

## 8. Deployment

- [x] 8.1 Add `PPDB_INTEGRATION_API_KEY` to kss-backend and `KSS_API_URL` + `KSS_INTEGRATION_API_KEY` to iqrolife-backend in docker-compose and the env examples (env examples committed; `docker-compose.yml` and `.env.production.example` changes left uncommitted in the ERP working tree alongside other pending edits)
- [x] 8.2 Document rollout order, class-mapping setup and backfill of earlier accepted applicants (`openspec/docs/ppdb-deploy-runbook.md`)
