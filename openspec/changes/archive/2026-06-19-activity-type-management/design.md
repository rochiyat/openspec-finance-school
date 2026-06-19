## Context

The Class Activity module is being built incrementally. `education-focus-management` (capability #1) is already implemented, providing a reference pattern for master-data CRUD modules. `activity-type-management` (capability #2) follows the same architectural pattern — a simpler variant since ActivityType has no child entity (unlike EducationFocus which has FocusChecklist).

The existing `education-focuses/` backend module demonstrates the established pattern: entity → repository → service → controller → DTOs, with Swagger documentation, SUPERADMIN role guards, and soft-delete via `isActive` flag. The frontend follows a single-page admin pattern with inline modals for create/edit.

## Goals / Non-Goals

**Goals:**
- Provide a fully functional CRUD module for ActivityType master data
- Follow existing patterns from the `education-focuses` module for consistency
- Seed 8 default activity types per the PRD
- Deliver admin UI consistent with the EducationFocusPage

**Non-Goals:**
- Activity scheduling per class (future: `daily-class-report-core`)
- Duration tracking per activity
- Activity type versioning or history
- Activity type hierarchy / nesting

## Decisions

### 1. Mirror `education-focuses` module structure (simpler)

**Decision**: Follow the exact same file structure as `education-focuses/` but without the child entity (no checklist equivalent).

**Rationale**: ActivityType is structurally identical to EducationFocus minus the one-to-many child relationship. Using the same pattern reduces cognitive load and keeps the codebase consistent.

**Alternatives considered**:
- Generic CRUD generator: Over-engineered for a single entity.

### 2. Soft-delete via `isActive` flag

**Decision**: Use `isActive = false` for deletion, same as EducationFocus.

**Rationale**: ActivityTypes will be referenced by `DailyActivitySelection` in future. Hard-deleting would break referential integrity. Soft-delete preserves historical data.

### 3. Unique name constraint

**Decision**: Enforce unique `name` at the database level and check in the service layer before create/update.

**Rationale**: Prevents duplicate activity types. Mirrors the EducationFocus pattern which uses ConflictException with structured error codes.

### 4. Frontend: Separate page under admin section

**Decision**: Create `ActivityTypePage.tsx` in `src/pages/admin/`, register route alongside `EducationFocusPage`.

**Rationale**: Admin pages are grouped under `/admin/*` in the existing frontend structure. A standalone page with inline modals matches the existing pattern.

## Risks / Trade-offs

- **[Low risk] Structural similarity to EducationFocus**: This module is intentionally simple. The risk of over-simplifying is low since the PRD explicitly scopes this to basic CRUD with no child entities. → Mitigation: Follow PRD exactly; future changes can extend via OpenSpec.
- **[Low risk] Seed data idempotency**: Seed migration must be idempotent to avoid duplicates on re-runs. → Mitigation: Use `INSERT ... ON CONFLICT DO NOTHING` or check-before-insert in the seed migration.
