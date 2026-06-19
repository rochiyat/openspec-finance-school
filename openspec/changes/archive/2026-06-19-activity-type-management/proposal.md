## Why

The Class Activity module requires configurable master data for daily activity types (e.g., "Pembukaan", "Circle Time", "Multi Sensory") before teachers can record daily class reports. Activity types are Phase 1 / Priority Blue — they must be ready before POG UAT. The `daily-class-report-core` capability depends on this master data being available.

## What Changes

- Add a new `ActivityType` entity with CRUD operations (create, read, update, soft-delete)
- Provide a backend REST API at `/activity-types` with full CRUD, protected by SUPERADMIN role
- Add an admin UI page for managing activity types (list, create, edit, delete with display order)
- Seed 8 default activity types on initial deployment
- Add a frontend API client for the activity-types endpoints

## Capabilities

### New Capabilities
- `activity-type-crud`: Full CRUD management for daily activity types including backend entity, service, controller, DTOs, repository, seed data, admin UI page, and frontend API client.

### Modified Capabilities
_(none — this is a new standalone module with no changes to existing specs)_

## Impact

- **Backend**: New NestJS module `activity-types/` under `src/modules/` with entity, service, controller, repository, DTOs, and migration
- **Frontend**: New admin page `ActivityTypePage.tsx` under `src/pages/admin/`, new API client `activity-type.ts` under `src/lib/`, route registration in app router
- **Database**: New `activity_types` table with seed data migration
- **APIs**: 5 new REST endpoints under `/activity-types`
- **Dependencies**: Requires existing `auth-session-access` and `user-role-administration` capabilities (already implemented)
