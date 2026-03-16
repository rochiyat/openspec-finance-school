## Why

The MVP requires a secure entry point before any master data, billing, payment, notification, or dashboard capability can be implemented. The PRD explicitly calls for Auth & Role in Phase 1, with password hashing, role-based access, input validation, and `POST /auth/login` plus `GET /auth/me` as the initial access foundation.

## What Changes

- Add login and current-session API requirements for authenticated users.
- Define role-aware access behavior for `SUPERADMIN`, `FINANCE`, `GURU`, and `PARENT`.
- Establish session identity retrieval so downstream modules can enforce authorization consistently.
- Require password hashing, backend validation, structured errors, and basic UI availability as part of MVP readiness.

## Capabilities

### New Capabilities
- `auth-session-access`: Authenticate users, return current session identity, and enforce role-based access for protected application features.

### Modified Capabilities

## Impact

- APIs: `POST /auth/login`, `GET /auth/me`, and authorization behavior for protected endpoints.
- Backend foundation: auth, users, and roles modules; password hashing; request validation; error handling.
- Frontend foundation: basic login UI and role-aware session bootstrapping.
- Delivery dependency: unlocks implementation planning for all Phase 1 modules that require authenticated access.
