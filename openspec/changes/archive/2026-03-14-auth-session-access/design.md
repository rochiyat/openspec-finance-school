## Context

This change establishes the authentication and session foundation required by every MVP capability in the PRD. The repository does not contain application code yet, so the design needs to define the technical direction for a future `Vite + React` frontend and `NestJS + TypeORM + PostgreSQL` backend while preserving the PRD requirements for login, current-user session lookup, password hashing, role-based access, input validation, and basic UI availability.

## Goals / Non-Goals

**Goals:**
- Provide a consistent login flow for system users through `POST /auth/login`.
- Provide a current-session endpoint through `GET /auth/me` for frontend bootstrap and role-aware UI.
- Enforce role-based access for `SUPERADMIN`, `FINANCE`, `GURU`, and `PARENT` on protected APIs.
- Define secure credential handling, backend validation, and structured auth errors suitable for MVP.

**Non-Goals:**
- Password reset, email verification, MFA, SSO, or social login.
- Full user and role administration workflows beyond what auth needs to identify roles.
- Session revocation across devices, refresh token rotation, or advanced security telemetry.

## Decisions

### Decision: Use NestJS auth module with hashed passwords and signed bearer tokens
The backend should authenticate credentials against stored user records with hashed passwords, then issue a signed access token for subsequent requests. This keeps the MVP implementation straightforward, aligns with common NestJS patterns, and avoids server-side session storage complexity before the application is fully scaffolded.

Alternative considered: server-managed sessions persisted in the database. This was rejected for MVP because it adds operational complexity without improving the immediate PRD requirements.

### Decision: Expose session identity through `GET /auth/me`
The frontend needs a single bootstrap endpoint to determine the logged-in user and role after login or refresh. `GET /auth/me` should return user identity and assigned role so all downstream screens can gate actions consistently.

Alternative considered: embedding all role context only in the login response. This was rejected because the frontend still needs a canonical session rehydration endpoint.

### Decision: Enforce authorization with role guards on protected endpoints
Protected modules should rely on reusable authorization guards rather than ad hoc checks inside handlers. This keeps permission decisions centralized and makes later modules easier to implement consistently.

Alternative considered: checking roles in each controller method manually. This was rejected because it is error-prone and scales poorly as more modules are added.

### Decision: Keep repositories private to their owning module service
The auth implementation should follow the repository boundary rule established for the backend scaffold. If `auth` needs user or role data, it should integrate through the owning module's exported service instead of reaching into another module's repository directly.

Alternative considered: letting auth import user or role repositories directly for convenience. This was rejected because it creates tight cross-module coupling and breaks the intended module ownership model.

### Decision: Standardize auth failures as validation-safe, structured errors
Invalid credentials, missing tokens, expired tokens, and forbidden role access should return predictable structured errors. This supports the PRD requirement for error handling and gives the future UI a stable contract.

Alternative considered: relying on framework default exception payloads. This was rejected because defaults vary and do not provide a deliberate application contract.

## Risks / Trade-offs

- Token-based auth requires careful secret management once implementation begins -> Mitigate by using environment-based secrets and documented local setup.
- Role checks can drift across modules if not centralized -> Mitigate by introducing shared guards/decorators early.
- Cross-module auth flows can bypass boundaries if repositories are imported directly -> Mitigate by keeping repository usage inside the owning module service only.
- Parent users may later require student-linked context in session payloads -> Mitigate by keeping session identity extensible without overloading the initial auth contract.
- Audit log is referenced in the PRD DoD but is Phase 2 scope -> Mitigate by leaving audit integration as a follow-up dependency rather than blocking auth design.
