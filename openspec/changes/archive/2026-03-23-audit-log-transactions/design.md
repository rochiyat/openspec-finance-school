# Design: Audit Log Transactions

## Architecture Overview
The system captures events during service mutations and routes them to a new dedicated `AuditLogsService` which persists them tracking the timeline of financial integrity.

### Data Model: `AuditLog`
- `id`: string
- `entityType`: `BILLING` | `PAYMENT` | `INSTALLMENT`
- `entityId`: string
- `action`: `CREATE` | `UPDATE` | `DELETE`
- `actorId`: string (userId or system)
- `metadata`: any (JSON details)
- `createdAt`: string

### Interception & Dispatch
Instead of building a complex PubSub interceptor, we will do explicit service-level logging in the core mutating methods of:
- `PaymentsService.createPayment`
- `BillingsService.createBilling`, `updateBillingStatus`
- `InstallmentsService.updateInstallmentItemStatus`

### Backend Module: `AuditLogsModule`
- `AuditLogsRepository`: Handles storage to `data/audit_logs.json`.
- `AuditLogsService`: Offers `logEvent(payload)` and `fetchLogs(filters)`.
- `AuditLogsController`: 
  - `GET /api/audit-logs`: Fetches paginated or recent logs. Role-gated to `SUPERADMIN` and `FINANCE`.

### Frontend
- Create a new tab or section in the **Finance Operations Dashboard** (or Superadmin Dashboard) called "Audit Trail" that fetches `/api/audit-logs` and renders them in a styled data table with an expandable view for the raw JSON metadata.
