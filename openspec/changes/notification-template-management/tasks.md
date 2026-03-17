## 1. Backend — Data Model & Repository

- [x] 1.1 Create `NotificationTemplate` interface/entity with fields: `id`, `name`, `channelType`, `subject`, `body`, `variables`, `isActive`, `createdBy`, `createdAt`.
- [x] 1.2 Implement `NotificationTemplatesRepository` with in-memory store and methods: `create`, `findAll`, `findById`, `update`.
- [x] 1.3 Write unit tests for `NotificationTemplatesRepository`.

## 2. Backend — DTOs & Validation

- [x] 2.1 Create `CreateNotificationTemplateDto` with validation: `name` (string, required), `channelType` (enum: EMAIL|WHATSAPP|SMS), `subject` (optional string), `body` (string, required), `variables` (optional string[]).
- [x] 2.2 Create `UpdateNotificationTemplateDto` (partial of Create + `isActive` boolean).
- [x] 2.3 Create `NotificationTemplateResponseDto` for consistent response shape.

## 3. Backend — Service & Controller

- [x] 3.1 Implement `NotificationTemplatesService` with methods: `create`, `findAll`, `findById`, `update`; enforce unique `name` constraint on create.
- [x] 3.2 Implement `NotificationTemplatesController` with routes: `POST /notification-templates`, `GET /notification-templates`, `GET /notification-templates/:id`, `PATCH /notification-templates/:id`; guarded by `BearerAuthGuard` + `RolesGuard(SUPERADMIN)`.
- [x] 3.3 Create `NotificationTemplatesModule` and register it in `AppModule`.
- [x] 3.4 Write unit tests for `NotificationTemplatesService`.

## 4. Backend — Verification

- [x] 4.1 Add E2E tests covering: create template, list templates, get template by id, update template, duplicate name rejection, unauthorized access rejection.

## 5. Frontend — Admin UI

- [x] 5.1 Add state and fetch functions in `auth.ts` for `fetchNotificationTemplates`, `createNotificationTemplate`, `updateNotificationTemplate`.
- [x] 5.2 Add a notification template management section in `LoginPage.tsx` for `SUPERADMIN`, showing a list of templates and a create form (name, channelType, subject, body).
- [x] 5.3 Ensure non-superadmin users do not see the notification template section.
