# Proposal: Superadmin Global Dashboard

## Purpose
Build a high-level system overview dashboard for the `SUPERADMIN` role. This dashboard provides a bird's-eye view of the entire school's financial health, user activity, and notification status, helping administrators ensure the system is operating correctly across all departments.

## Motivation
While the `FINANCE` and `GURU` dashboards are operation-focused (managing specific payments or classes), the `SUPERADMIN` needs a broader "Global" view. Currently, there is no single place to see the total number of users, the success rate of notifications, or the high-level financial standing of the institution. 

## Target Persona
- **Superadmin**: Responsibility for system oversight, academic configuration, and overall financial monitoring.

## Scope of Change
- **Backend**:
  - Implement `GET /api/superadmin-dashboard/overview` (matching the `finance-dashboard` and `teacher-dashboard` conventions).
  - Aggregate system-wide statistics:
    - **User Stats**: Total Students, Total Parents, Total Teachers, Total Active Users.
    - **Academic Stats**: Active Academic Year, Total Classes.
    - **Financial Summary**: Grand total billed vs. collected (cross-referenced from `finance-dashboard` logic).
    - **Notification Stats**: Total notifications sent, success/failure counts.
  - Role-gating: Restricted to `SUPERADMIN` only.
- **Frontend**:
  - Create the `SuperadminDashboardPage.tsx` at `/dashboard-superadmin`.
  - Display four main sections:
    - **System Summary Cards**: Users, Classes, Active Academic Year.
    - **Global Financial Overview**: High-level Billed vs. Collected charts or summary.
    - **Notification Health**: Simple visual status of recent notification attempts.
    - **Activity Feed / Audit Logs Summary**: (Optional/MVP+) Show count of recent system actions.
  - Route registration and role-based redirecting.

## Affected Components
- `backend/src/modules/superadmin-dashboard/` (New)
- `backend/src/app.module.ts` (Registration)
- `frontend/src/pages/SuperadminDashboardPage.tsx` (New)
- `frontend/src/routes/AppRouter.tsx`
- `frontend/src/lib/auth.ts` (DTOs and API helper)

## Dependencies
- `users`, `students`, `parents`, `classes`, `academic-years` (for counts)
- `billings`, `payments` (for financial summary)
- `notifications` (for notification stats)

## Success Criteria
- [ ] Superadmin can access a comprehensive system overview in < 3 seconds.
- [ ] All metrics (Users, Finances, Notifications) accurately reflect the total system state.
- [ ] Users with `FINANCE`, `GURU`, or `PARENT` roles are strictly prohibited from accessing this view.
- [ ] Backend unit tests verify the aggregation of counts and totals across all modules.
