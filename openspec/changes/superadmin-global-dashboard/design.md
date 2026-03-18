# Design: Superadmin Global Dashboard

## Overview
The Superadmin Global Dashboard provides a holistic view of the school management system. It aggregates metrics from user management, academic configuration, billing/finance, and notification status into a single operational interface.

---

## Backend Architecture

### Module: `SuperadminDashboardModule`
New module at `backend/src/modules/superadmin-dashboard/`.

#### Controller: `SuperadminDashboardController`
- **Endpoint**: `GET /api/superadmin-dashboard/overview`
- **Guards**: `BearerAuthGuard`, `RolesGuard`
- **Allowed Roles**: `SUPERADMIN`
- **Response**: `SuperadminDashboardOverviewDto`

#### Service: `SuperadminDashboardService`
Method: `getOverview(): Promise<SuperadminDashboardOverviewDto>`

**Aggregation Logic**:
1. **User Totals**:
   - `totalStudents`: Count from `StudentsService`.
   - `totalParents`: Count from `ParentsService`.
   - `totalTeachers`: Filter `UsersService.listUsers()` by role `GURU`.
2. **Academic Status**:
   - `activeAcademicYear`: Get current active year from `AcademicYearsService`.
   - `totalClasses`: Count from `ClassesService`.
3. **Financial Summary**:
   - `totalBilled`: Sum of all billings (re-use logic from `FinanceDashboardService`).
   - `totalCollected`: Sum of all payments.
   - `outstandingReceivable`: Total Billed - Total Collected.
4. **Notification Health**:
   - `totalNotifications`: All generated notifications.
   - `readRate`: Percentage of notifications that are `isRead === true`.

#### DTOs
```typescript
// superadmin-dashboard-overview.dto.ts
export interface SuperadminDashboardOverviewDto {
  userStats: {
    totalStudents: number;
    totalParents: number;
    totalTeachers: number;
    totalActiveUsers: number;
  };
  academicStats: {
    activeYearName: string;
    totalClasses: number;
  };
  financialStats: {
    totalBilled: number;
    totalCollected: number;
    outstandingReceivable: number;
  };
  notificationStats: {
    totalSent: number;
    readCount: number;
    readRate: number;
  };
}
```

### Module Registration
- Add to `AppModule`.
- Dependencies: `UsersModule`, `StudentsModule`, `ParentsModule`, `ClassesModule`, `AcademicYearsModule`, `BillingsModule`, `PaymentsModule`, `NotificationsModule`.

---

## Frontend Architecture

### Page: `SuperadminDashboardPage`
- **File**: `frontend/src/pages/SuperadminDashboardPage.tsx`
- **Route**: `/dashboard-superadmin`
- **Role Gate**: Strictly for `SUPERADMIN`. Redirect unauthorized users to index.

#### Layout
- **Hero**: "Welcome, Superadmin - Global System Overview".
- **Stat Grid (System)**: 4 cards showing system-wide counts (Students, Parents, Teachers, Classes).
- **Financial Spotlight**: Large summary of Billed vs. Collected with percentage indicators.
- **Engagement Insights**: Notification read rates and totals.

#### API Helper (in `lib/auth.ts`)
```typescript
export async function fetchSuperadminDashboardOverview(token: string) {
  const resp = await fetch(`${API_BASE}/superadmin-dashboard/overview`, {
    headers: { Authorization: `Bearer ${token}` }
  });
  return handleJsonResponse<SuperadminDashboardResponse>(resp);
}
```

---

## Security Considerations
- This endpoint exposes system-wide counts and financial data. It is the most sensitive overview in the system.
- Guarding with `RolesGuard(['SUPERADMIN'])` is mandatory at the backend level.

---

## Risks / Trade-offs
- **Performance**: Aggregating across ALL modules in one go could be slow if the dataset grows (e.g. 10k students). For the MVP, we rely on the memory-store's speed. In production, these counts could be cached (e.g. Redis) or use optimized SQL `COUNT` queries.
- **Service Dependency**: High coupling to almost all modules. This is expected for a "Global" dashboard.
