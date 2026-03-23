## 1. Backend: Scaffold the Audit Logs Module

- [x] 1.1 Create `AuditLogRecord` type and `AuditLogsRepository` that writes to `data/audit_logs.json`.
- [x] 1.2 Create `AuditLogsService` with `registerEvent()` and `getRecentLogs()` methods.
- [x] 1.3 Create `AuditLogsController` with `GET /api/audit-logs` endpoint (restricted to `SUPERADMIN`, `FINANCE`).
- [x] 1.4 Export `AuditLogsService` from `AuditLogsModule` and register `AuditLogsModule` in `AppModule`.

## 2. Backend: Integration with Operations

- [x] 2.1 Inject `AuditLogsService` into `PaymentsService`. Trigger `registerEvent` on successful `createPayment`.
- [x] 2.2 Inject `AuditLogsService` into `BillingsService`. Trigger `registerEvent` on successful `createBilling`.

## 3. Frontend: Integration

- [x] 3.1 Create `fetchAuditLogs` helper in `frontend/src/lib/auth.ts`.
- [x] 3.2 Update `SuperadminDashboardPage.tsx` or `FinanceDashboardPage.tsx` to include an "Audit Trail" or "Transaction Logs" panel that displays recent events.

## 4. Testing & Verification

- [ ] 4.1 Write a test for `AuditLogsService`.
- [x] 4.2 Verify frontend successfully displays the trails after a manual creation of billing or payment.

