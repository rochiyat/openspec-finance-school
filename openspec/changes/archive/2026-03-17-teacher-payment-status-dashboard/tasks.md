## 1. Backend: Dashboard Infrastructure & Class Lookup

- [x] 1.1 Create `TeacherDashboardModule` and `TeacherDashboardController`.
- [x] 1.2 Implement `ClassesRepository.findByHomeroomTeacherId(teacherId)` to retrieve the class managed by the authenticated teacher.
- [x] 1.3 Implement `GET /api/teacher-dashboard/overview` endpoint with `GURU` role protection.
- [x] 1.4 Write unit tests for class lookup logic.

## 2. Backend: Data Aggregation & Logic

- [x] 2.1 Implement `TeacherDashboardService.getOverview(teacherId)`:
  - Fetch class for teacher.
  - Fetch students in that class using `StudentsService`.
  - Fetch billings for each student using `BillingsService`.
- [x] 2.2 Calculate aggregate stats: `totalStudents`, `totalUnpaidCount`, `totalOverdueCount`.
- [x] 2.3 Map student data to includes their overall payment status (highest severity: Overdue > Unpaid > Partial > Paid).
- [x] 2.4 Write unit tests for status aggregation logic.

## 3. Frontend: Dashboard UI

- [x] 3.1 Create `TeacherDashboard` page component.
- [x] 3.2 Implement API service call to `GET /api/teacher-dashboard/overview`.
- [x] 3.3 Build summary stats section (3 cards).
- [x] 3.4 Build `StudentPaymentTable` displaying NIS, Name, and Overall Status.
- [x] 3.5 Ensure navigation links point to the new dashboard for users with the `GURU` role.

## 4. Verification & Testing

- [x] 4.1 Perform manual testing with a seeded `GURU` user.
- [x] 4.2 Verify that a teacher without a class sees a friendly empty state or error.
- [x] 4.3 Create an E2E test verifying a teacher can only see their class's students.
