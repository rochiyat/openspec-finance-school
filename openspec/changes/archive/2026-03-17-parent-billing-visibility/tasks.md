## 1. Authorization Support

- [x] 1.1 Create `IsParentOfStudentGuard` to verify that `req.user.id` is explicitly linked to the `:studentId` parameter via  `student-parent-mapping`.
- [x] 1.2 Write unit tests for `IsParentOfStudentGuard` covering linked and unlinked scenarios.

## 2. Parent-Facing API Endpoints

- [x] 2.1 Implement `GET /parents/students/:studentId/billings` that retrieves billing records for a linked student, protected by `IsParentOfStudentGuard`.
- [x] 2.2 Implement `GET /parents/students/:studentId/installments` that retrieves installment plans for a linked student, protected by `IsParentOfStudentGuard`.
- [x] 2.3 Implement `GET /parents/students/:studentId/payments` that retrieves payment histories for a linked student, protected by `IsParentOfStudentGuard`.

## 3. Frontend Parent Dashboard

- [x] 3.1 Create a frontend navigation route and module for the parent financial dashboard.
- [x] 3.2 Display a list of linked students on the dashboard for the authenticated parent.
- [x] 3.3 Implement views to display active billings, installment plans, and payment records for a selected student.
- [x] 3.4 Ensure the UI gracefully handles "no data" states and unauthorized states.

## 4. Verification

- [x] 4.1 Perform end-to-end testing of the fetching flows as a user with `PARENT` role.
- [x] 4.2 Verify that `PARENT` role lacks access to querying other students and lacks access to admin APIs.
- [x] 4.3 Update API documentation (Swagger) for the new parent endpoints.
