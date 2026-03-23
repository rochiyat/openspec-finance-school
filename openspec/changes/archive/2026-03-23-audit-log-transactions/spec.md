# Spec: Audit Log Transactions

## Requirement: Core Engine & Routing

The system MUST save audit logs when core financial operations occur.

#### Scenario: User Creates Payment
- **GIVEN** a valid `SUPERADMIN` or `FINANCE` or `PARENT` user is making a payment.
- **WHEN** the `PaymentsService.createPayment` method executes successfully.
- **THEN** an `AuditLog` entity is created with `action='CREATE'`, `entityType='PAYMENT'`.
- **AND** the `actorId` matches the User ID performing the action.
- **AND** the payload contains the relevant payment data (e.g., amount, billingId).

#### Scenario: Admin Updates Billing
- **GIVEN** an admin successfully updates a billing.
- **WHEN** the `BillingsService` or `InstallmentsService` is updated.
- **THEN** an `AuditLog` entity is recorded reflecting the `entityType='BILLING'` or `'INSTALLMENT'`.

## Requirement: Read API

The system MUST expose a way for administrators to read audit logs.
- `GET /api/audit-logs`
- Available to `SUPERADMIN` and `FINANCE` only.

#### Scenario: Fetch Logs
- **GIVEN** a `SUPERADMIN` requests `/api/audit-logs`.
- **THEN** the server returns a list of audit logs ordered by `createdAt` descending.
