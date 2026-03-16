## Context

The repository is being used as a temporary combined workspace for delivery, but the long-term intention is to split frontend and backend into separate repositories. `frontend/` and `backend/` already exist as empty folders, so this change should create two self-contained applications with their own package manifests, scripts, environment templates, and quality tooling while keeping cross-app coupling minimal.

## Goals / Non-Goals

**Goals:**
- Create a runnable `frontend/` React + Vite + TypeScript application with basic app shell, routing entry, and verification tooling.
- Create a runnable `backend/` NestJS + TypeScript application with Swagger, global validation, environment loading, and TypeORM-ready module structure.
- Keep each app independently installable and runnable from its own folder.
- Establish a backend module boundary rule: repositories are only consumed inside their owning module service, and other modules interact through exported services.
- Provide `.env.example` files and baseline scripts so follow-up changes can implement features without rethinking tooling.

**Non-Goals:**
- Implement business features such as auth, billing, payment, notifications, or dashboards.
- Introduce a shared package used by both apps.
- Finalize production deployment, CI/CD, container orchestration, or advanced infrastructure.

## Decisions

### Decision: Use dual-app structure instead of a true package workspace
The root repository will hold `frontend/` and `backend/` side-by-side, but each app will keep its own `package.json` and local scripts. This matches the user's stated plan to split the apps into separate repositories later and avoids creating temporary root-level coupling that will have to be unwound.

Alternative considered: a root monorepo with workspace dependencies and shared packages. This was rejected because it adds coupling and migration work without being necessary for the current stage.

### Decision: Keep frontend-backend integration at the HTTP boundary only
The frontend will be configured to talk to the backend through environment-configured API URLs rather than shared runtime imports. This keeps the future repo split low-friction and reinforces clean API contracts.

Alternative considered: a shared local package for DTOs or contracts. This was rejected for the initial scaffold because it complicates the future split and is not required to unblock implementation.

### Decision: Prepare backend for service-oriented module boundaries
The backend scaffold will organize code under modules, with repositories kept private to the owning module and only services exported for cross-module use. This enforces the desired architectural rule early and prevents direct repository leakage between modules.

Alternative considered: allowing modules to import each other's repositories where convenient. This was rejected because it creates tight coupling and weakens domain boundaries.

### Decision: Include baseline quality and documentation tooling in each app
Each app should start with TypeScript, linting, test commands, and environment examples so subsequent changes can be verified immediately. The backend should also expose Swagger from the beginning because the PRD Definition of Done requires API availability there.

Alternative considered: delaying tooling until after feature implementation starts. This was rejected because it would force follow-up changes to mix feature work with project bootstrap concerns.

## Risks / Trade-offs

- Two independent app setups can duplicate config -> Mitigate by keeping only minimal baseline config and documenting conventions in `AGENTS.md`.
- Avoiding shared packages may duplicate some contract types later -> Mitigate by favoring explicit HTTP contracts first and revisiting type-sharing only if it becomes painful.
- Early scaffold choices can constrain future features -> Mitigate by sticking close to Vite/NestJS defaults and avoiding premature abstraction.
- Service-only repository access requires discipline as modules grow -> Mitigate by establishing folder structure and export patterns that make repository privacy the easy default.

## Migration Plan

- Add frontend scaffold in `frontend/` with local scripts and env example.
- Add backend scaffold in `backend/` with local scripts, Swagger, validation, and env example.
- Update repository guidance in `AGENTS.md` to reflect the new actual commands and structure.
- Use this scaffold as the prerequisite base for implementing `auth-session-access` next.
