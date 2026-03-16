## Why

The repository now contains empty `frontend/` and `backend/` folders, but there is no runnable application scaffold to host the MVP features. A small foundation change is needed so implementation can begin in-place while keeping the two apps loosely coupled and easy to split into separate repositories later.

## What Changes

- Scaffold a standalone React application in `frontend/` using Vite and TypeScript.
- Scaffold a standalone NestJS application in `backend/` using TypeScript, Swagger, validation, and TypeORM-ready structure.
- Add per-app package manifests, basic build/lint/test scripts, and local environment example files.
- Establish repository boundaries so frontend consumes backend only through HTTP APIs.
- Define backend module interaction rules so repositories remain private to their owning module service and other modules integrate through services instead of direct repository access.

## Capabilities

### New Capabilities
- `app-scaffold-foundation`: Provide the minimal frontend and backend application structure, scripts, environment templates, and module boundaries needed to start implementing MVP features.

### Modified Capabilities

## Impact

- Repository structure: `frontend/` and `backend/` become runnable applications instead of empty folders.
- Tooling: each app gets its own `package.json`, TypeScript config, and verification scripts.
- Backend architecture: establishes service-oriented module boundaries for future `auth`, `users`, `roles`, and domain modules.
- Delivery sequence: unblocks implementation of `auth-session-access` and all subsequent MVP changes.
