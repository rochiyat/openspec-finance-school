## Why

The Class Activity module requires configurable master data for Education Focuses (Fokus Pendidikan) and their associated checklists before any daily reporting or student progress tracking can begin. Currently, there is no entity or management interface for the four core education focus areas (Pendidikan Iman, Pendidikan Ego & Individualitas, Pendidikan Bahasa, Psikomotor) nor the per-focus checklist items that teachers use to record student progress. This is the first capability in the Phase 1 implementation sequence and blocks `daily-class-report-core`, making it a critical-path dependency.

## What Changes

- Introduce `EducationFocus` entity with CRUD operations and soft-delete support
- Introduce `FocusChecklist` entity as child items under each focus, with CRUD operations and ordering
- Seed 4 default education focuses on deployment
- Provide admin-only API endpoints under `/education-focuses` for managing focuses and their checklists
- Provide admin UI page for managing education focuses and checklist items
- Add display ordering support for both focuses and checklists
- Expose read-only endpoints for non-admin roles (teachers will need to list focuses when creating daily reports)

## Capabilities

### New Capabilities
- `education-focus-crud`: CRUD operations for EducationFocus master data including soft-delete, display ordering, and seed data for the 4 default focuses
- `focus-checklist-crud`: CRUD operations for FocusChecklist items nested under each EducationFocus, including display ordering and soft-delete

### Modified Capabilities
- `user-role-administration`: SUPERADMIN role gains permission to manage education focuses and checklists via new protected endpoints

## Impact

- **Backend**: New `education-focuses` module under `src/modules/education-focuses/` with entity, controller, service, repository, and DTOs. New migration for `education_focuses` and `focus_checklists` tables. Seed script for default data.
- **Frontend**: New admin page at `/admin/education-focuses` for CRUD management with inline checklist editing.
- **APIs**: New REST endpoints under `/education-focuses` and `/education-focuses/:id/checklists`.
- **Dependencies**: Depends on `auth-session-access` (JWT guard, role decorator) and `user-role-administration` (SUPERADMIN role).
- **Database**: Two new tables: `education_focuses`, `focus_checklists` with FK relationship.
