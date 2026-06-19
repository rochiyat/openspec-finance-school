## Context

The Class Activity module extends the existing Sistem Informasi Keuangan Sekolah with education-focused capabilities. The first capability needed is master data management for Education Focuses (Fokus Pendidikan) and their associated checklists.

The existing codebase follows a consistent NestJS module pattern: entity → repository → service → controller → DTOs, with Swagger decorators, `BearerAuthGuard` + `RolesGuard` for protection, and `@Roles('SUPERADMIN')` for admin-only endpoints. The frontend uses React + Tailwind CSS with role-based routing and dedicated admin pages under `src/pages/admin/`.

**Current state**: No education-focused entities exist. The `billing-types` module is the closest pattern match — it's a simple master-data CRUD module with admin-only access.

**Dependencies**: `auth-session-access` (guards, decorators) and `user-role-administration` (SUPERADMIN role) are already implemented and available.

## Goals / Non-Goals

**Goals:**
- Provide full CRUD for `EducationFocus` with soft-delete (`is_active` flag) and `display_order` support
- Provide full CRUD for `FocusChecklist` as nested child items under each focus
- Seed 4 default education focuses on first deployment
- Admin UI for managing focuses and inline checklist editing
- Read-only list endpoint accessible to GURU role (needed later by `daily-class-report-core`)
- Follow existing codebase patterns exactly (entity → repository → service → controller)

**Non-Goals:**
- Multi-level focus hierarchy (parent/child focuses)
- Checklist versioning or historical tracking
- Bulk import/export of focuses or checklists
- Frontend for non-admin roles (teacher-facing UI is in `daily-class-report-core`)

## Decisions

### 1. Single module for both entities

**Decision**: Put both `EducationFocus` and `FocusChecklist` in one `education-focuses` module.

**Rationale**: `FocusChecklist` is always accessed in the context of its parent `EducationFocus`. Separate modules would add cross-module dependency overhead without benefit. This matches the PRD endpoint structure where checklists are nested routes under `/education-focuses/:id/checklists`.

**Alternative considered**: Separate `focus-checklists` module — rejected because checklists have no independent access patterns.

### 2. Soft-delete via `is_active` flag (not `deleted_at`)

**Decision**: Use `is_active: boolean` column instead of TypeORM's `@DeleteDateColumn`.

**Rationale**: The PRD defines `is_active` in the entity model. Soft-delete allows admin to deactivate a focus/checklist without losing references from historical daily reports. Using a boolean flag keeps the query filter simple and matches the existing entity patterns in the codebase.

**Alternative considered**: TypeORM `@DeleteDateColumn` with soft-delete support — rejected because the PRD specifies `is_active` explicitly and the codebase doesn't use this pattern elsewhere.

### 3. UUID primary keys

**Decision**: Use UUID v4 for primary keys via `@PrimaryGeneratedColumn('uuid')`.

**Rationale**: The PRD specifies `id: uuid` for both entities. While the `billing-types` module uses string PKs with manual ID generation, the newer modules in the codebase (students, classes) use UUID generation. UUID v4 is more appropriate for new tables.

### 4. Seed data via TypeORM migration

**Decision**: Create a dedicated migration file that inserts the 4 default education focuses.

**Rationale**: Migrations are idempotent and run automatically on deploy. This ensures the seed data is present in every environment without requiring a separate seed command. The migration will use `INSERT ... ON CONFLICT DO NOTHING` to be safe for re-runs.

### 5. Dual access patterns (admin write, authenticated read)

**Decision**: Separate the controller into admin-only write endpoints (`POST/PATCH/DELETE` guarded by `@Roles('SUPERADMIN')`) and authenticated read endpoints (`GET` available to all authenticated users).

**Rationale**: Teachers need to read the focus list when creating daily reports. Restricting reads to SUPERADMIN would force a workaround later. The existing `BearerAuthGuard` is sufficient for read protection.

### 6. Admin UI as a new tab in existing admin page or standalone

**Decision**: Create a new admin page `EducationFocusPage.tsx` under `src/pages/admin/` with a dedicated route, rather than adding a tab to an existing page.

**Rationale**: Education focuses are a separate domain from finance. Adding them to `FinancePage.tsx` or `AcademicPage.tsx` would conflate domains. A standalone page keeps the admin interface organized by capability.

## Risks / Trade-offs

- **[Risk] Checklist items referenced by future daily reports cannot be hard-deleted** → Mitigation: Use `is_active` soft-delete so deactivated items remain in the database for referential integrity. API returns only active items by default with an optional `includeInactive` query param for admin.

- **[Risk] Display order conflicts during concurrent admin edits** → Mitigation: Display order is advisory (not unique constraint). Duplicates are tolerable; the frontend sorts by `display_order ASC, name ASC` as tiebreaker. Acceptable for a low-concurrency admin operation.

- **[Risk] Seed data may conflict with manual admin entries** → Mitigation: Use `ON CONFLICT DO NOTHING` in the seed migration. Admins can modify seeded entries freely after deployment.

## Migration Plan

1. Create TypeORM migration for `education_focuses` and `focus_checklists` tables
2. Create seed migration for 4 default education focuses
3. Deploy backend module with new endpoints
4. Deploy frontend admin page
5. **Rollback**: Drop the two tables via a down migration. No other tables or modules are affected.
