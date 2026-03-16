## Why

Students and class-based teacher views depend on a stable academic structure before student records, dashboards, and billing assignment can work correctly. The PRD defines `AcademicYear` and `Class` as core domain models, so this capability needs to be in place now to support the rest of MVP master data.

## What Changes

- Add academic year management requirements, including active year handling.
- Add class management requirements, including homeroom teacher assignment and academic year linkage.
- Define superadmin administration flows for creating and maintaining academic years and classes.
- Add a basic frontend management UI for academic years and classes.

## Capabilities

### New Capabilities
- `academic-years-and-classes`: Manage academic year master data and class master data, including teacher homeroom assignment and active-year linkage.

### Modified Capabilities

## Impact

- APIs: adds academic year and class administration endpoints for master data setup.
- Backend modules: introduces or expands `academic-years` and `classes` modules.
- Frontend: adds basic management screens for academic years and classes.
- Delivery dependency: unblocks `student-directory`, teacher-facing data scoping, and later dashboard aggregation by active class/year context.
