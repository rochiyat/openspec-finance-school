## 1. Frontend scaffold

- [x] 1.1 Create the `frontend/` Vite React TypeScript application structure with its own `package.json` and TypeScript config.
- [x] 1.2 Add frontend scripts for dev, build, lint, and test, plus a minimal app shell and entrypoint.
- [x] 1.3 Add `frontend/.env.example` and configure the frontend to read the backend API base URL from environment variables.

## 2. Backend scaffold

- [x] 2.1 Create the `backend/` NestJS TypeScript application structure with its own `package.json` and TypeScript config.
- [x] 2.2 Add backend scripts for dev, build, lint, and test, plus baseline app bootstrap with Swagger and global validation.
- [x] 2.3 Add `backend/.env.example` and baseline configuration wiring for app port, database connection, CORS origin, and JWT secret placeholders.

## 3. Architectural boundaries

- [x] 3.1 Establish backend module folder conventions that keep repositories private to the owning module service.
- [x] 3.2 Add a backend example module structure or documentation pattern showing that cross-module access goes through exported services, not repositories.
- [x] 3.3 Update repository guidance in `AGENTS.md` to reflect the new real scaffold structure and commands.

## 4. Verification

- [x] 4.1 Verify frontend installs and exposes working dev, build, lint, and test commands.
- [x] 4.2 Verify backend installs and exposes working dev, build, lint, and test commands.
- [x] 4.3 Confirm the scaffold is sufficient to unblock `auth-session-access` as the next implementation change.
