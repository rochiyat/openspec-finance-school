## Context

The codebase already supports authentication, superadmin user management, academic structure, and student records. The next dependency for parent mapping, notifications, and parent-facing visibility is a proper parent directory that links contact records to existing managed `PARENT` user accounts without breaking the module boundary rule established across the backend.

## Goals / Non-Goals

**Goals:**
- Let superadmin create, list, and view parent records.
- Link each parent record to an existing managed user with the `PARENT` role.
- Store contact information needed for future notification and parent portal features.
- Provide a basic frontend administration interface for parent master data.

**Non-Goals:**
- Student-parent relationship mapping.
- Parent self-registration, self-service profile updates, or invite workflows.
- WhatsApp/email notification sending itself.

## Decisions

### Decision: Implement a dedicated parents module with repository and service ownership
Parent records should live in their own module because they become the canonical source for contact identity referenced by student-parent mapping and notifications. Keeping a dedicated repository and service avoids overloading user-role management with parent profile details.

Alternative considered: storing all parent profile fields directly inside the users module. This was rejected because parent contact data is a separate domain concern from generic user-role administration.

### Decision: Restrict parent management to superadmin-only endpoints for MVP
Parent master data creation and administration remains a controlled setup workflow at this stage. Reusing the existing superadmin-only guard pattern keeps authorization simple and consistent with other master-data changes.

Alternative considered: allowing parent users to manage their own directory records. This was rejected because self-service behavior is not required by the PRD at this stage.

### Decision: Validate linked parent users through exported user services
Each parent record includes `user_id`, and backend module boundaries require repository ownership to stay inside the owning service. The parents service should therefore validate linked identities through `UsersService` and reject any user not assigned the `PARENT` role.

Alternative considered: trusting raw `user_id` values from the client without validation. This was rejected because it would permit invalid identity links and break later notification assumptions.

### Decision: Start with CRUD-lite parent management aligned to PRD endpoints
The PRD only requires `GET /parents`, `POST /parents`, and `GET /parents/:id`, so the first version should focus on create/list/detail flows rather than broader account maintenance. This keeps the capability tightly scoped and ready for the next mapping change.

Alternative considered: adding update and delete flows immediately. This was rejected because it extends beyond the current PRD endpoints and would broaden the capability unnecessarily.

## Risks / Trade-offs

- In-memory persistence will not survive restarts -> Mitigation: keep DTOs and service contracts straightforward to migrate to database-backed storage later.
- A parent user could be created without a matching parent record -> Mitigation: treat this directory as the authoritative profile layer and rely on admin workflows until mapping is added.
- Duplicate contact data may appear if uniqueness rules are too loose -> Mitigation: validate linked user identity and reject duplicate `user_id` associations.
- Later notification work may need more fields than the initial profile set -> Mitigation: keep the model additive and avoid locking into a narrow shape.

## Migration Plan

- Add backend `parents` module with superadmin-only create/list/detail APIs.
- Reuse auth/session and user-role administration for authorization and linked-user validation.
- Add frontend parent management UI alongside the existing superadmin master-data screens.
- Use this capability as the prerequisite for `student-parent-mapping` and personal notifications.

## Open Questions

- None for MVP; the PRD provides enough detail to implement parent create/list/detail behavior directly.
