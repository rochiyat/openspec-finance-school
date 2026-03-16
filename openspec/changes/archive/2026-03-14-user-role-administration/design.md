## Context

The repository now has a working auth foundation with seeded users, bearer authentication, `GET /auth/me`, and role guards. The next MVP step is to replace hard-coded operational access with a manageable user and role administration flow owned by superadmin, while preserving the backend boundary rule that repositories stay private to their owning module service.

## Goals / Non-Goals

**Goals:**
- Let superadmin create internal users needed for school operations.
- Let superadmin list users and update assigned roles across `SUPERADMIN`, `FINANCE`, `GURU`, and `PARENT`.
- Keep user management behind existing auth and authorization controls.
- Add a basic frontend administration screen for viewing users and changing role assignments.

**Non-Goals:**
- Public self-registration or self-service role changes.
- Password reset, invite email workflows, or account recovery.
- Fine-grained permission matrices beyond the four PRD roles.

## Decisions

### Decision: Extend existing users and roles modules rather than creating a separate admin-only persistence layer
User-role administration belongs to core operational identity management, so it should build on the current `users` and `roles` modules. This keeps ownership clear and avoids duplicating user state between auth and admin flows.

Alternative considered: a separate admin management module with its own repository layer. This was rejected because it would duplicate user ownership and create unnecessary synchronization complexity.

### Decision: Restrict user and role administration to superadmin-only endpoints
The PRD assigns user and role management to superadmin, so all mutating administration APIs should require authenticated superadmin access. This keeps the authorization model simple and aligned with the product rules.

Alternative considered: allowing finance or teacher roles to manage some subsets of users. This was rejected because the PRD does not authorize them for system-level user management.

### Decision: Keep repository access inside owning module services
The implementation should preserve the backend scaffold rule that repositories remain private to their owning module service. Auth, admin controllers, or future modules must call exported `UsersService` and `RolesService` methods rather than pulling repositories directly.

Alternative considered: allowing auth and admin controllers to inject repositories directly for convenience. This was rejected because it breaks service ownership and weakens module boundaries.

### Decision: Start with basic CRUD-lite user management and explicit role assignment
MVP only needs enough administration to create users, list them, and update their assigned role. Starting with those workflows keeps the change capability-scoped and avoids mixing in broader identity lifecycle concerns.

Alternative considered: full user lifecycle management including deactivate/reactivate, password rotation, and profile editing. This was rejected because it broadens scope beyond the immediate PRD need.

## Risks / Trade-offs

- Seeded users and newly managed users may coexist temporarily -> Mitigate by treating seeds as baseline data until full persistence is expanded.
- Role changes can lock admins out if no superadmin remains -> Mitigate by guarding destructive role changes in service logic.
- Frontend admin UI may stay basic compared to later operational pages -> Mitigate by optimizing for correctness and clear authorization first.
- User administration requirements may later need audit logging -> Mitigate by keeping service methods explicit so audit hooks can be added in a later change.

## Migration Plan

- Extend backend `users` and `roles` modules with administration APIs protected by superadmin authorization.
- Add frontend administration UI for viewing users and updating roles.
- Reuse the current auth flow so only authenticated superadmin sessions can access management screens.
- Use this capability as the next source of truth for operational user setup instead of relying only on hard-coded seeded accounts.
