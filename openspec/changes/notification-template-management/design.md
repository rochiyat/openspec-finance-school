## Context

The system currently stores billing, payment, and installment data but does not support any outbound communication to parents or students. Administrators need a flexible way to define message content that can be referenced at notification-send time. This design covers the data model, API surface, and frontend integration for managing notification templates.

## Goals / Non-Goals

**Goals:**
- Allow `SUPERADMIN` users to create, list, view, update, and deactivate notification templates.
- Support a per-template channel type (`EMAIL`, `WHATSAPP`, `SMS`) to allow different body formats.
- Support named placeholder variables in template bodies (e.g., `{{student_name}}`, `{{billing_title}}`).
- Provide a frontend section for template management.

**Non-Goals:**
- Actual notification delivery (sending emails/WhatsApp messages) — out of scope for this change.
- Template versioning or approval workflows.
- Per-user or per-student template overrides.

## Decisions

### Data Model

A `NotificationTemplate` entity will be stored in-memory (consistent with other entities in this codebase that use a repository pattern with in-memory stores):

```
NotificationTemplate {
  id: string            // UUID
  name: string          // unique human-readable identifier, e.g. "payment-reminder"
  channelType: enum     // EMAIL | WHATSAPP | SMS
  subject: string       // used for EMAIL channel; optional for others
  body: string          // template body; supports {{variable}} placeholders
  variables: string[]   // list of supported placeholder names declared on the template
  isActive: boolean
  createdBy: string     // user ID of creator
  createdAt: string
}
```

### Supported Placeholder Variables (initial set)

| Variable | Description |
|---|---|
| `{{student_name}}` | Full name of the student |
| `{{billing_title}}` | Title of the billing record |
| `{{amount_due}}` | Total amount due |
| `{{due_date}}` | Due date of the billing |
| `{{payment_code}}` | Code of the payment receipt |
| `{{installment_no}}` | Installment number |
| `{{school_name}}` | School name (from env config) |

### API Design

```
POST   /api/notification-templates          → create template (SUPERADMIN only)
GET    /api/notification-templates          → list templates (SUPERADMIN only)
GET    /api/notification-templates/:id      → get template detail (SUPERADMIN only)
PATCH  /api/notification-templates/:id      → update template (SUPERADMIN only)
```

No DELETE — templates are deactivated via `isActive: false` on PATCH.

### Module Structure (NestJS)

- `NotificationTemplatesModule` (imports `AuthModule`)
- `NotificationTemplatesController` — guarded by `BearerAuthGuard` + `RolesGuard` (SUPERADMIN)
- `NotificationTemplatesService` — CRUD logic + validation
- `NotificationTemplatesRepository` — in-memory store, identical pattern to other repositories
- DTOs: `CreateNotificationTemplateDto`, `UpdateNotificationTemplateDto`, `NotificationTemplateResponseDto`

### Frontend

A new collapsible admin panel section is added to `LoginPage.tsx` for `SUPERADMIN` users, rendering the template list and a create form. This follows the existing page-level admin panel structure exactly.

## Risks / Trade-offs

- **In-memory storage** means templates do not persist across server restarts — accepted, consistent with current architecture.
- **No delivery integration** — templates are created but not yet wired to any send mechanism; this is intentional for this change.
- **`variables` field is informational** — the system does not validate that `{{placeholders}}` in the body match the declared `variables` list; enforcement can be added later.
