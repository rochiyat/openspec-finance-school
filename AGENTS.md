# AGENTS.md
## Repository Snapshot
- This repository is an OpenSpec-first planning repo with active application scaffolds in `frontend/` and `backend/`.
- Present top-level directories: `frontend/`, `backend/`, `docs/`, `openspec/`, and `.codex/`.
- Product and technical direction lives in `docs/prd-si-keuangan-sekolah.md`.
- Intended stack from the PRD: `Vite + React + Tailwind CSS` on the frontend and `NestJS + TypeORM + PostgreSQL` on the backend.
- `frontend/` and `backend/` are intentionally independent apps with their own `package.json` files so they can be split into separate repositories later.
- There is no root workspace package manifest; run commands from `frontend/` or `backend/` directly.

## Source of Truth
- Treat `docs/prd-si-keuangan-sekolah.md` as the product source of truth.
- Treat `openspec/` as the source of truth for planned and approved changes.
- Keep dashboard work separate from billing/payment data foundation work.
- Prefer introducing large changes through OpenSpec artifacts first.

## Agent Priorities
- Preserve PRD intent.
- Keep changes small, testable, and capability-scoped.
- Sequence work by technical dependency.
- Avoid inventing extra architecture unless the PRD clearly requires it.
- When the app is scaffolded, follow existing local patterns over generic framework defaults.

## Cursor / Copilot Rules
- No `.cursorrules` file was found.
- No files were found under `.cursor/rules/`.
- No `.github/copilot-instructions.md` file was found.
- Re-check these locations before large edits in case they are added later.

## Available Commands Today
The repository uses per-app commands rather than a root workspace script.

### OpenSpec Commands
- `openspec status --json` - check project status; currently errors if no changes exist.
- `openspec new change "<change-name>"` - create a change container.
- `openspec status --change "<change-name>" --json` - inspect artifact completion.
- `openspec instructions proposal --change "<change-name>" --json` - get proposal guidance.
- `openspec instructions apply --change "<change-name>" --json` - get implementation guidance.
- `openspec archive "<change-name>"` - archive a completed change.
- `openspec list --json` - list active changes.

### Build / Lint / Test Status
- Build: configured in `frontend/` and `backend/`.
- Lint: configured in `frontend/` and `backend/`.
- Test: configured in `frontend/` and `backend/`.
- Single-test execution: supported via each app's test runner CLI arguments.

## Expected Commands Once the App Is Scaffolded
The app is now scaffolded. Use these commands unless local package scripts change.

### Frontend
- `npm install` - install frontend dependencies.
- `npm run dev` - run the Vite dev server.
- `npm run build` - create a production build.
- `npm run lint` - run frontend linting.
- `npm run test` - run frontend tests once.
- `npx vitest run src/App.test.tsx` - run a single frontend test file.

### Backend
- `npm install` - install backend dependencies.
- `npm run start:dev` - run NestJS in watch mode.
- `npm run build` - compile the backend.
- `npm run lint` - run backend linting.
- `npm run test` - run backend unit tests.
- `npx jest --config jest.config.ts --runInBand src/app.controller.spec.ts` - run one backend unit test file.
- `npm run test:e2e` - run backend end-to-end tests.

### Workspace
- There is no root workspace runner.
- Run frontend commands from `frontend/` and backend commands from `backend/`.
- Keep the apps independently runnable and avoid introducing root-only scripts unless the repository strategy changes.

## Single-Test Guidance
- Prefer the narrowest command that verifies the change.
- For Jest/NestJS, prefer `npx jest --config jest.config.ts --runInBand <path-to-spec>`.
- For Vitest/Vite, prefer `npx vitest run <path-to-test>`.
- For React Testing Library, run only the affected component test first.
- Run the related package suite before moving to both apps.

## Architecture Expectations From the PRD
- Backend modules should align with the PRD list: `auth`, `users`, `roles`, `students`, `parents`, `student-parent-maps`, `classes`, `academic-years`, `billing-types`, `billings`, `installments`, `payments`, `notifications`, `notification-templates`, `dashboard`, and `audit-logs`.
- API boundaries should follow the PRD endpoints unless a newer OpenSpec change updates them.
- Notifications should be event-driven and AI-friendly.
- Personal notifications belong in MVP; global notification and reminder scheduling are later-phase unless explicitly brought forward.

## Code Style Guidelines
### General
- Use TypeScript everywhere for both frontend and backend.
- Prefer small, focused modules over large multi-purpose files.
- Keep functions deterministic when possible.
- Avoid hidden coupling between dashboard logic and transactional billing/payment logic.
- Keep domain rules close to the service or entity that enforces them.

### Formatting
- Use the repository formatter if one is added; do not fight automated formatting.
- Default to 2-space indentation for frontend code and follow framework defaults elsewhere if established.
- Use semicolons consistently once a formatter or linter decides.
- Use trailing commas where the formatter adds them.
- Prefer one export style per file; do not mix default and named exports without a clear reason.

### Imports
- Group imports as: standard library, third-party, internal aliases, then relative imports.
- Keep type-only imports explicit with `import type`.
- Remove unused imports immediately.
- Prefer shallow relative imports; there are no shared cross-app aliases today.
- Do not create circular dependencies.

### Naming
- Use `PascalCase` for React components, NestJS classes, DTOs, entities, and interface-like object shapes.
- Use `camelCase` for variables, functions, methods, and object properties.
- Preserve snake_case only for database columns or external payloads that require it.
- Use `UPPER_SNAKE_CASE` for enum-like constants such as billing status codes.
- Use kebab-case for OpenSpec change names and filenames where framework conventions allow it.

### Types
- Prefer explicit domain types over `any`.
- Use enums or string unions for statuses like `UNPAID`, `PARTIALLY_PAID`, `PAID`, and `OVERDUE`.
- Model nullable and optional fields intentionally.
- Validate and narrow external input at the boundary.
- Share backend contract types with the frontend only when ownership and versioning are clear.

### Backend Conventions
- In NestJS, keep controllers thin and services responsible for business rules.
- Put request validation in DTOs or pipes and domain invariants in services or entities.
- Enforce PRD rules explicitly, such as `amount_paid <= remaining_amount` and installment eligibility checks.
- Keep persistence concerns in repositories or ORM mappings rather than controllers.
- Repositories are private to their owning module service; other modules must use exported services instead of accessing repositories directly.
- Record notification status changes as first-class data, not just logs.

### Frontend Conventions
- Build basic, role-appropriate UI first; prefer correctness and clarity over visual polish for MVP.
- Keep data fetching separate from presentational components.
- Use form validation for all writable financial actions.
- Reflect backend status values exactly; avoid inventing parallel frontend-only status semantics.
- Gate screens and actions by role in the UI, but never rely on UI gating alone for security.

### Error Handling
- Never swallow errors silently.
- Return structured, actionable backend errors.
- Include enough context for debugging without leaking secrets or sensitive personal data.
- For async workflows such as notifications, persist status transitions and failure reasons where appropriate.
- Fail fast on invalid input and impossible state transitions.

### Validation and Security
- Validate all request inputs.
- Hash passwords; never store or log raw credentials.
- Enforce role-based access on every protected endpoint.
- Treat payment, billing, and installment operations as auditable actions.
- Minimize exposure of parent and student personal data.

### Testing Expectations
- Add tests with every non-trivial business rule.
- Favor service-level tests for billing, installment, payment, and notification rules.
- Cover permission boundaries with authorization tests.
- Add integration or e2e coverage for critical financial flows once the backend exists.
- For dashboards, test aggregation logic separately from presentation.

## Practical Guidance for Agents
- Frontend and backend are intentionally separate apps; avoid runtime imports across `frontend/` and `backend/`.
- If you change package scripts in either app, update this file immediately.
- If you add ESLint, Prettier, or TypeScript path aliases beyond the current scaffold, update the style section to match reality.
- If local conventions emerge that conflict with this document, the codebase conventions win; revise `AGENTS.md` rather than ignoring drift.
