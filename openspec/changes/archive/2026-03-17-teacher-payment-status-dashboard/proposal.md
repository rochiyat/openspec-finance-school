# Proposal: Teacher Payment Status Dashboard

## Purpose
Create a dedicated dashboard for teachers (homeroom teachers) to monitor the financial standing of students within their assigned class. This visibility helps teachers cooperate with the finance staff in ensuring administrative requirements are met by parents/students.

## Motivation
Currently, teachers lack real-time visibility into which students in their class have outstanding billings. Providing this data directly to the homeroom teacher via a dashboard reduces the need for manual reports from the finance department and allows for proactive follow-up with students or parents.

## Scope
- **Backend**:
  - Implement `GET /api/dashboard/teacher` endpoint in the `DashboardModule`.
  - Logic to identify the class assigned to the currently authenticated teacher.
  - Aggregation of student data and billing statuses (Total Unpaid, Total Overdue, etc.) for that specific class.
- **Frontend**:
  - Implement the "Teacher Dashboard" page with a summary and a detailed student list.
  - Use status colors/badges consistent with the existing design system.
- **Security**:
  - Ensure only users with the `TEACHER` role can access their specific class data.
  - Role-based guarding on both API and UI.

## Affected Components
- `backend/src/modules/dashboard/dashboard.controller.ts`
- `backend/src/modules/dashboard/dashboard.service.ts`
- `frontend/src/pages/DashboardGuru.tsx` (or similar)
- `frontend/src/components/dashboard/...`

## Dependencies
- `students` module (for student listing)
- `classes` module (for homeroom teacher mapping)
- `billings`/`payments` modules (for status aggregation)

## Success Criteria
- [ ] Teachers can log in and see a summary of their class (Total Students, Active Billings).
- [ ] A list of students is visible with a clear indicator of their cumulative payment status (PAID, PARTIALLY_PAID, UNPAID, OVERDUE).
- [ ] The dashboard loads in under 3 seconds as per NFRs in the PRD.
- [ ] Teachers cannot see students from other classes.
