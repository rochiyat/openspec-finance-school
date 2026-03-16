## 1. Backend auth foundation

- [x] 1.1 Scaffold `auth`, `users`, and `roles` backend modules needed for login and authorization, following the rule that repositories stay inside their owning module service.
- [x] 1.2 Add secure password hashing and credential verification for stored user records.
- [x] 1.3 Implement `POST /auth/login` with input validation and structured authentication errors.
- [x] 1.4 Implement signed bearer-token authentication and request guards for protected routes.

## 2. Session identity and authorization

- [x] 2.1 Implement `GET /auth/me` to return the authenticated user's identity and assigned role.
- [x] 2.2 Add reusable role-based access guards/decorators for `SUPERADMIN`, `FINANCE`, `GURU`, and `PARENT`.
- [x] 2.3 Define a consistent auth response shape for success, unauthenticated, and forbidden states.

## 3. Frontend login flow

- [x] 3.1 Create a basic login UI that submits credentials to `POST /auth/login`.
- [x] 3.2 Add client-side session bootstrap using `GET /auth/me` after login or refresh.
- [x] 3.3 Add role-aware UI handling for authenticated, validation-error, and unauthorized states.

## 4. Verification

- [x] 4.1 Add backend tests for successful login, invalid credentials, missing fields, unauthenticated access, and forbidden role access.
- [x] 4.2 Add frontend or integration verification for login submission and authenticated session bootstrap.
- [x] 4.3 Document the auth contract in Swagger and confirm the change meets MVP PRD acceptance expectations.
