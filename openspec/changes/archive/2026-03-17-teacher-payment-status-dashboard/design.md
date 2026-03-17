# Design: Teacher Payment Status Dashboard

## Overview
The Teacher Dashboard provides homeroom teachers with a real-time overview of the payment statuses of students in their assigned class. This is a read-only view aimed at facilitating administrative follow-ups.

## Architecture

### Backend: `TeacherDashboardModule`
We will create a new module `TeacherDashboardModule` (or add to a general `DashboardModule` if preferred, but following the `ParentDashboardModule` pattern, a dedicated one is cleaner).

#### Controller: `TeacherDashboardController`
- `GET /api/teacher-dashboard/overview`
- **Guards**: `BearerAuthGuard`, `RolesGuard`.
- **Allowed Roles**: `GURU`.
- **Response**: `TeacherDashboardOverviewDto`.

#### Service: `TeacherDashboardService`
1. **Identify Class**: Query `ClassesService` or `ClassesRepository` to find the class where `homeroomTeacherId` matches the authenticated user's ID.
2. **Retrieve Students**: Get all students belonging to that `classId`.
3. **Aggregate Statuses**:
   - For each student, fetch their active billings.
   - Determine if a student is "Fully Paid", "Partially Paid", or has "Overdue" items.
4. **Data Aggregation**:
   - `totalStudents`: Count of students in class.
   - `totalUnpaid`: Count of students with at least one `UNPAID` or `PARTIALLY_PAID` billing.
   - `totalOverdue`: Count of students with at least one `OVERDUE` billing.
   - `studentList`: Array of student summary objects.

#### DTOs
- `TeacherDashboardOverviewDto`:
  - `classInfo`: `{ id, name }`
  - `stats`: `{ totalStudents, totalUnpaid, totalOverdue }`
  - `students`: `Array<{ id, nis, fullName, overallStatus, billingSummary }>`

### Frontend: Teacher Dashboard Page
- **Route**: `/dashboard-guru`
- **Components**:
  - `StatCard`: Used for displaying the 3 main metrics.
  - `StudentPaymentTable`: List view with NIS, Name, and Status Badge.
  - `StatusBadge`: Existing component representing `PAID`, `PARTIALLY_PAID`, `UNPAID`, `OVERDUE`.

## Database / Repository Queries
- `ClassesRepository.findByHomeroomTeacher(teacherId)`: Returns the class record.
- `StudentsRepository.findByClassId(classId)`: Returns students in that class.
- `BillingsRepository.findByStudentId(studentId)`: Returns billings for status check.

## Security Considerations
- Teachers must only see students in their class.
- The service must fetch the `classId` from the DB using the `userId` from the JWT, rather than accepting a `classId` from the request parameters (to prevent ID horizontal escalation).

## Risks / Trade-offs
- **Performance**: Fetching billings for every student in a class (e.g., 30+ students) in a single request might be slow if not optimized. We may need to use a join or a more efficient aggregation query in the repository.
- **Multiple Classes**: The PRD implies a homeroom teacher usually has one class. If a teacher can have multiple, the UI/API should handle a list of classes.
