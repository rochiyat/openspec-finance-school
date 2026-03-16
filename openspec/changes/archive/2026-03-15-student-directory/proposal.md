## Why

Student records are the core link between academic structure, billing, payments, and parent relationships. Now that academic years and classes exist, the MVP needs a proper student directory so financial and classroom workflows can attach to real student data instead of placeholders.

## What Changes

- Add student directory requirements for creating, listing, viewing, and updating student records.
- Define superadmin administration flows for student master data using academic year and class references.
- Validate that student records are linked to valid classes and academic years.
- Add a basic frontend management UI for viewing and managing student records.

## Capabilities

### New Capabilities
- `student-directory`: Manage student master data, including class placement, academic year assignment, and active status.

### Modified Capabilities

## Impact

- APIs: adds `GET /students`, `POST /students`, `GET /students/:id`, and `PATCH /students/:id`.
- Backend modules: introduces or expands the `students` module and validates references to academic year and class master data.
- Frontend: adds a basic student management screen for superadmin or authorized administration flows.
- Delivery dependency: unblocks parent mapping, billing assignment, and teacher/student payment visibility using real student records.
