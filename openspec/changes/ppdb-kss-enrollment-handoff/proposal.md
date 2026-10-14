## Why

PPDB (iqrolife, its own database) and KSS (this ERP, its own database) are not connected: once a candidate is accepted in PPDB, staff must re-create the student, the parent account and the student-parent link in KSS by hand. The referenced `generate:iqrolife-seed` script no longer exists, so there is no repeatable path at all. Manual re-entry is slow, error-prone (typos, duplicate parents, wrong class) and leaves no record of which PPDB applicant became which KSS student.

## What Changes

- PPDB sends an enrollment to KSS automatically when a formulir is accepted with a level. Each send is tracked per formulir (`PENDING`, `SENT`, `FAILED` with the reason), and staff can retry a failed send from the formulir list.
- KSS gets a service-to-service intake endpoint, protected by a dedicated integration key, that creates (or reuses) the parent user with the `PARENT` role, the parent record, the student (with generated NIS) and the primary student-parent mapping.
- Intake is idempotent per PPDB formulir: resending the same enrollment never creates a second student or parent.
- The KSS class is resolved from a new, admin-managed mapping of "PPDB level per academic year → KSS class". A missing mapping fails the enrollment with a clear reason instead of guessing.
- New parent users get no known password; KSS sends them an account setup link through its existing reset-token mechanism, with a longer validity than a normal password reset.
- Only the data KSS needs crosses the boundary: student name and gender, parent name, email, phone and address, the academic year name and the accepted level.

## Capabilities

### New Capabilities
- `ppdb-enrollment-handoff`: PPDB side. Triggering the send on acceptance, tracking per-formulir handoff status and failure reasons, and staff retry.
- `ppdb-enrollment-intake`: KSS side. Authenticated, idempotent intake that creates or reuses the parent user, parent record, student and primary mapping, and sends the parent an account setup link.
- `ppdb-class-mapping`: KSS side. Superadmin management of the mapping from PPDB level and academic year to a KSS class.

### Modified Capabilities
(none — student, parent and mapping directories keep their current requirements; intake uses them as a new caller.)

## Impact

- **iqrolife-backend** (PPDB API, Express + Sequelize): new `ppdb_kss_handoffs` table and migration, KSS client, send on accept, retry endpoint, handoff status in formulir responses. New env: `KSS_API_URL`, `KSS_INTEGRATION_API_KEY`.
- **iqrolife** (PPDB web, Next.js): handoff status badge and "Kirim ulang ke KSS" action in the formulir review list.
- **kss-backend** (NestJS + TypeORM): new integration module with key guard, `ppdb_enrollments` and `ppdb_class_mappings` tables and migrations, intake endpoint, mapping CRUD, account-setup link with longer TTL in the auth module. New env: `PPDB_INTEGRATION_API_KEY`.
- **kss-frontend**: superadmin page to manage PPDB class mappings.
- **docker-compose**: shared integration key passed to `iqrolife-backend` and `kss-backend`.
- Data: parent and student personal data now flows PPDB → KSS over HTTPS; limited to the fields listed above.
