## Context

See proposal.md for motivation. Constraints that shape the approach:

- **Two apps, two databases.** PPDB is `iqrolife-backend` (Express + Sequelize, Postgres `db_iqrolife`) with the `iqrolife` Next.js admin; KSS is `kss-backend` (NestJS + TypeORM, Postgres `db_kss`) with `kss-frontend`. They share nothing but the docker network and Caddy.
- **PPDB has no job runner.** It runs as a plain Express process (and historically on Vercel). There is no queue or cron to drain an outbox.
- **KSS module boundaries.** Repositories are private to their module; other modules must call exported services (`src/modules/README.md`). KSS services do not take a transaction manager, so one DB transaction across users, parents, students and mappings would break that rule.
- **Existing KSS building blocks:** `UsersService.createUser`/`updateUserRoles`, `ParentsService.createParent`/`getParentByUserId`, `StudentsService.createStudent` (validates class/year, generates NIS), `StudentParentMapsService.createMapping` (first mapping must be primary), `AuthService.requestPasswordReset` (hashed tokens, email/WA delivery, 60-minute TTL). `UsersService.createUser` emits `user.created`, which sends a plaintext password when `sendNotification` is true.
- **Relevant PPDB rules already in place:** a formulir can only become `accepted` from `reviewed`, through `POST /api/formulir-pendaftaran/accept` with a level; PPDB staff roles are `superadmin`, `staff`, `teacher`.

## Goals / Non-Goals

**Goals:**
- One accepted formulir becomes exactly one KSS student linked to one KSS parent, without manual re-entry.
- Failures are visible and recoverable by PPDB staff without developer help.
- No password is generated or transmitted for the parent's KSS account.

**Non-Goals:**
- Syncing later edits (name changes, class moves, withdrawals) between the systems. KSS is the owner after intake.
- Sending the second parent (ibu/wali) or health data. They have no email in PPDB and KSS does not need them for MVP.
- Single sign-on between PPDB and KSS accounts.
- Backfilling applicants accepted before this change. Staff can retry them from the formulir list once the feature is live, since retry also covers formulir without a handoff row.

## Decisions

### 1. Synchronous send after commit, tracked in a PPDB handoff table, with manual retry
On accept, PPDB writes `ppdb_kss_handoffs` (`formulir_id` unique, `status` PENDING/SENT/FAILED, `attempts`, `last_error`, `kss_student_id`, `kss_parent_id`, `kss_nis`, `sent_at`) in the same transaction as the status change, then calls KSS with a 10-second timeout after commit and stores the result. A `POST /api/formulir-pendaftaran/:id/kss-handoff` endpoint (PPDB staff only) retries anything not `SENT`; it creates the row if it is missing (applicants accepted before this change).

*Alternatives:* a background outbox worker needs a scheduler PPDB does not have; calling KSS inside the accept transaction would block or roll back acceptance when KSS is down. The chosen approach keeps acceptance independent of KSS and needs no new infrastructure; the cost is that recovery is a manual click, which matches the low volume of PPDB.

### 2. Resumable, step-wise intake in KSS keyed by `ppdb_enrollments`
KSS stores `ppdb_enrollments` (`source_id` unique, `status` IN_PROGRESS/COMPLETED, `user_id`, `parent_id`, `student_id`, `mapping_id`, `created_at`, `completed_at`). Intake:
1. Insert or load the row for `source_id` (unique constraint serializes concurrent duplicates). If `COMPLETED`, return its ids.
2. Resolve academic year by name and class through `ppdb_class_mappings` → 422 before creating anything if either is missing.
3. Each step reuses the id already stored on the row, otherwise finds-or-creates through the owning module's service and stores the id immediately: user (by email; add `PARENT` role if missing) → parent (by user id) → student → primary mapping.
4. Mark `COMPLETED`, then send the setup link if step 3 created the user.

*Alternatives:* a single TypeORM transaction across modules would require injecting other modules' repositories or a shared entity manager, violating the module boundary rule. A two-phase design is overkill for four inserts. Persisting progress per step gives the same end state on retry with plain service calls.

### 3. Dedicated integration key, separate from user auth
`PpdbIntegrationGuard` compares the `x-integration-key` header with `PPDB_INTEGRATION_API_KEY` using a constant-time compare and rejects everything when the variable is unset. The intake controller does not use `BearerAuthGuard`/`RolesGuard`, and the guard ignores bearer tokens. The same secret is configured in PPDB as `KSS_INTEGRATION_API_KEY`.

*Alternatives:* a KSS service account with a JWT would expire and need refresh logic, and would carry broad role permissions. The `api_keys` module stores outbound third-party keys per user and is not an inbound auth mechanism.

### 4. Class mapping table managed by superadmin
`ppdb_class_mappings` (`academic_year_id`, `ppdb_level` stored normalized as trimmed upper case, `class_id`; unique on year + level). CRUD under `/ppdb-class-mappings` with `@Roles('SUPERADMIN')`; create/update checks the class belongs to the mapping's year. A kss-frontend page under the superadmin menu lists and edits mappings. Intake reads the mapping at the time of the enrollment only, so later edits never move students (spec: ppdb-class-mapping).

*Alternatives:* name matching was rejected by the user in favour of explicit control, since PPDB levels (`KSS A`) and KSS class names may diverge.

### 5. Account setup link instead of a password
Intake creates the user through `UsersService.createUser` with an unusable random password and `sendNotification: false`, so the `user.created` listener sends nothing. `AuthService` gains `sendAccountSetupLink(userId)`, which reuses the reset-token table and `/reset-password` page with a 72-hour TTL and setup wording, delivered by email and by WhatsApp when a phone exists. A failed delivery does not fail the intake; it is logged, and the parent can still use "Lupa password".

### 6. Payload and field mapping
PPDB sends `{ sourceId: "iqrolife-formulir-<id>", academicYearName, level, student: { fullName, gender }, parent: { fullName, email, phone, address } }`. Gender maps `Laki-laki`→`MALE`, `Perempuan`→`FEMALE`; anything else fails in PPDB before sending. Parent identity comes from the PPDB account that owns the formulir (its email is what the parent already uses), phone from `telepon`, address from `alamatLengkap`. KSS validates with a DTO (`class-validator`), normalizes email to lower case and phone with the existing `normalizePhone`.

## Risks / Trade-offs

- [Email belongs to a different person in KSS] → intake reuses users by email by design (siblings); the response includes `parentReused: true` so PPDB shows "orang tua sudah ada di KSS" and staff can check.
- [Partial data left after a failure mid-intake] → the enrollment row keeps the ids already created and the next retry completes the rest; an `IN_PROGRESS` row older than a day is listed for superadmin follow-up in the mapping page.
- [Shared secret leaks] → separate key from the notification key, rotate by changing both env vars; intake only creates PARENT data and cannot read KSS data.
- [KSS down at acceptance time] → handoff stays `FAILED` with reason and a visible retry; acceptance itself is never blocked.
- [Personal data in transit] → only the fields in Decision 6, sent over the internal docker network or HTTPS; no payload logging on either side.

## Migration Plan

1. Deploy kss-backend with the new migration (`ppdb_enrollments`, `ppdb_class_mappings`) and `PPDB_INTEGRATION_API_KEY` set; deploy kss-frontend; superadmin creates class mappings for the current academic year.
2. Run PPDB migration 004 (`ppdb_kss_handoffs`) and deploy iqrolife-backend with `KSS_API_URL` (`http://kss-backend:3000/api` inside docker; KSS uses the global `/api` prefix) and `KSS_INTEGRATION_API_KEY`; deploy iqrolife.
3. Use "Kirim ke KSS" in the formulir list for applicants accepted before the release.
4. Rollback: unset `KSS_API_URL` in PPDB (handoffs then fail with "KSS belum dikonfigurasi" and acceptance keeps working); KSS tables can stay, they are unused without calls.
