## Why

The school finance system can generate billing records, installment plans, and payment entries, but currently has no way to communicate financial events (payment reminders, overdue notices, payment receipts) to parents or students. Administrators need to define and manage reusable message templates with dynamic placeholders so the system can produce consistent, personalised notifications without hardcoding message text.

## What Changes

- Introduce a **Notification Template** entity with a name, channel type (e.g., EMAIL, WHATSAPP, SMS), subject, body with placeholder support, and active/inactive status.
- Allow `SUPERADMIN` users to create, list, view, update, and deactivate notification templates.
- Support a defined set of template variables (e.g., `{{student_name}}`, `{{billing_title}}`, `{{amount_due}}`, `{{due_date}}`, `{{payment_code}}`) that can be embedded in template bodies.
- Provide a basic frontend management interface for viewing and editing templates.

## Capabilities

### New Capabilities

- `notification-template-management`: CRUD operations for notification templates including channel type, subject, body, placeholder variables, and active status — restricted to `SUPERADMIN`.

### Modified Capabilities

*(none — no existing spec-level requirements change)*

## Impact

- **Backend**: New `notification-templates` module with controller, service, repository, and DTOs. New in-memory data store for templates.
- **Frontend**: New admin section on the `LoginPage` (or separate page) for `SUPERADMIN` to manage templates.
- **APIs**: `GET/POST /api/notification-templates`, `GET/PATCH /api/notification-templates/:id`.
- **No breaking changes** to existing billing, payment, or parent APIs.
