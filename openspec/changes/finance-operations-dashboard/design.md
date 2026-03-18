# Design: Finance Operations Dashboard

## Overview
The Finance Dashboard aggregates system-wide financial data and exposes it through a single read-optimised API endpoint. The backend collects data from existing repositories (`BillingsRepository`, `PaymentsRepository`, `InstallmentsRepository`) and returns a flattened summary + delinquent-student list. The frontend renders this as stat cards plus a scrollable student table.

---

## Backend Architecture

### Module: `FinanceDashboardModule`
New module at `backend/src/modules/finance-dashboard/`.

Follows the same structural pattern as `TeacherDashboardModule` and `ParentDashboardModule`.

#### Controller: `FinanceDashboardController`
- **Endpoint**: `GET /api/finance-dashboard/overview`
- **Guards**: `BearerAuthGuard`, `RolesGuard`
- **Allowed Roles**: `FINANCE`, `SUPERADMIN`
- **Response**: `FinanceDashboardOverviewDto`

#### Service: `FinanceDashboardService`

Method: `getOverview(): Promise<FinanceDashboardOverviewDto>`

Steps:
1. Fetch all billings from `BillingsRepository.findAll()`.
2. Fetch all payments from `PaymentsRepository.findAll()`.
3. Fetch all installment items from `InstallmentsRepository.findAllItems()` (or equivalent).
4. Compute aggregates:
   - `totalBilled`: sum of `billing.totalAmount` for all billings.
   - `totalCollected`: sum of `payment.amountPaid` for all payments.
   - `outstandingReceivable`: `totalBilled - totalCollected`.
   - `overdueCount`: count of billings where `status === 'OVERDUE'`.
   - `unpaidCount`: count of billings where `status === 'UNPAID'`.
   - `activeInstallmentCount`: count of installment items where `status !== 'PAID'`.
5. Build `delinquentStudents`:
   - Group OVERDUE billings by `studentId`.
   - For each unique studentId, resolve student details via `StudentsService.getStudentById(studentId)`.
   - Return array: `{ studentId, nis, fullName, overdueCount }`.

#### DTOs
```typescript
// finance-dashboard-overview.dto.ts
export class FinanceDashboardOverviewDto {
  totalBilled: number;
  totalCollected: number;
  outstandingReceivable: number;
  overdueCount: number;
  unpaidCount: number;
  activeInstallmentCount: number;
  delinquentStudents: DelinquentStudentDto[];
}

export class DelinquentStudentDto {
  studentId: string;
  nis: string;
  fullName: string;
  overdueCount: number;
}
```

### Module Registration
Add `FinanceDashboardModule` to `AppModule` imports in `app.module.ts`.

### Module Dependencies
`FinanceDashboardModule` must import:
- `BillingsModule` (to access `BillingsRepository`)
- `PaymentsModule` (to access `PaymentsRepository`)
- `InstallmentsModule` (to access installment items)
- `StudentsModule` (to resolve student details)

---

## Frontend Architecture

### Page: `FinanceDashboardPage`
- **File**: `frontend/src/pages/FinanceDashboardPage.tsx`
- **Route**: `/dashboard-keuangan`
- **Role Gate**: Redirect to `/` if the authenticated user's role is not `FINANCE` or `SUPERADMIN`.

#### Layout
```
┌──────────────────────────────────────────────┐
│  Finance Dashboard            [Sign Out]      │
├────────────┬────────────┬────────────────────┤
│ Total Billed│ Collected  │  Outstanding        │
├────────────┴────────────┴────────────────────┤
│ Overdue │ Unpaid │ Active Installments         │
├──────────────────────────────────────────────┤
│  Delinquent Students                          │
│  NIS | Name | Overdue Count                   │
│  ...                                          │
└──────────────────────────────────────────────┘
```

#### API Helper (in `lib/auth.ts`)
```typescript
export async function fetchFinanceDashboardOverview(token: string) {
  const res = await fetch(`${API_BASE}/finance-dashboard/overview`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw await res.json();
  return res.json() as Promise<FinanceDashboardOverview>;
}
```

### Route Registration (`AppRouter.tsx`)
Add a new route for `/dashboard-keuangan` pointing to `FinanceDashboardPage`.

---

## Security Considerations
- The service aggregates **all** billing and payment records (school-wide). This is intentional for the `FINANCE` role.
- The controller must guard with both `BearerAuthGuard` and `RolesGuard(['FINANCE', 'SUPERADMIN'])`.
- No student PII beyond name and NIS is returned.

---

## Performance Considerations
- The overview aggregates across all billings and payments in memory. For the current in-memory store this is fine. When migrating to PostgreSQL, replace with SQL aggregation queries (SUM, COUNT GROUP BY).
- Target: response < 3 seconds (per NFR in PRD).

---

## Risks / Trade-offs
- **N+1 for delinquent list**: Resolving each delinquent student's name via `StudentsService` individually could be slow. Acceptable for now with the in-memory repository; flag for optimisation when switching to TypeORM.
- **Role name alignment**: The seeded role for finance staff uses string `FINANCE`. Verify this matches the JWT role claim used by `RolesGuard` before implementation.
