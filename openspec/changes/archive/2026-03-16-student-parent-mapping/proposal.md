## Why

Student and parent records now exist independently, but the MVP still cannot answer which parent belongs to which student. The PRD requires this mapping before parent billing visibility, notification targeting, and family-based access can work correctly, especially because one parent can own multiple students while each student must have one primary parent.

## What Changes

- Add mapping requirements for linking students to parents.
- Define rules for one parent owning many students and each student having at least one primary parent.
- Add endpoints to create mappings and list parents by student or students by parent.
- Add a basic frontend management UI for linking students and parents.

## Capabilities

### New Capabilities
- `student-parent-mapping`: Manage links between student records and parent records, including primary-parent designation.

### Modified Capabilities

## Impact

- APIs: adds `POST /student-parent-maps`, `GET /students/:id/parents`, and `GET /parents/:id/students`.
- Backend modules: introduces or expands `student-parent-maps` and validates references to existing student and parent records.
- Frontend: adds a basic linking screen for student-parent relationships.
- Delivery dependency: unblocks parent-facing student access, personal notification targeting, and billing visibility by family relationship.
