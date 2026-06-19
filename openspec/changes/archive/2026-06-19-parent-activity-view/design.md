## Context

The Iqrolife school system now has:
- **DailyClassReport** with full CRUD, publish workflow, student records, focus entries, and checklist results (from `daily-class-report-core`).
- **EvidenceMedia** with Cloudinary upload and polymorphic FK references (from `evidence-media-upload`).
- **StudentParentMap** with `IsParentOfStudentGuard` enforcing parent→student ownership (from `student-parent-mapping`).
- **ParentDashboardController** at `/parents/students/:studentId/...` providing billing visibility (from `parent-billing-visibility`).

Parents currently see only financial data. This change adds read-only access to published daily class reports so parents can follow their child's education activities.

## Goals / Non-Goals

**Goals:**
- Provide a read-only backend API for parents to view published daily activities for their linked students.
- Build a mobile-first frontend with timeline and detail views.
- Reuse existing `IsParentOfStudentGuard` and `DailyClassReportsRepository` patterns.
- Enforce strict data scoping: only PUBLISHED reports, only linked students.

**Non-Goals:**
- Parent write operations (handled by `parent-evidence-submission` change).
- Push notifications when reports are published (handled by `daily-report-notification` change).
- Commenting or feedback on activities (out of scope per breakdown).
- Offline/PWA caching.

## Decisions

### Decision 1: New `student-daily-activities` module (not extending `daily-class-reports`)

**Choice**: Create a dedicated `student-daily-activities` NestJS module with its own controller and service, rather than adding parent endpoints to the existing `daily-class-reports` module.

**Rationale**: The `daily-class-reports` module is teacher-facing with write operations and facilitator ownership checks. Parent-facing read-only queries have different authorization (parent guard, not facilitator check) and different response shapes (student-scoped, not class-scoped). Mixing these concerns would complicate both authorization and query logic.

**Alternative considered**: Adding parent endpoints to `DailyClassReportsController`. Rejected because the controller already uses facilitator-based authorization; adding parent routes with different guard logic would create confusing guard precedence.

### Decision 2: Controller path follows existing parent dashboard pattern

**Choice**: Mount endpoints at `GET /parents/students/:studentId/daily-activities` and `GET /parents/students/:studentId/daily-activities/:date`, following the same `/parents/students/:studentId/...` pattern used by `ParentDashboardController`.

**Rationale**: Consistent URL structure with existing parent billing endpoints. The `IsParentOfStudentGuard` already extracts and validates `studentId` from this path format.

**Alternative considered**: `GET /students/:studentId/daily-activities` without the `/parents/` prefix. Rejected because it would conflict with potential teacher/admin endpoints for the same data and doesn't trigger the parent guard naturally.

### Decision 3: Reuse DailyClassReportsRepository with new parent-optimized queries

**Choice**: Import `DailyClassReportsModule` and inject `DailyClassReportsRepository` into the new service. Add a new query method `findPublishedByStudentAndDateRange` optimized for parent views (filters by PUBLISHED status, joins through StudentDailyRecord to filter by studentId).

**Rationale**: The repository already has the entity mapping and join patterns. Adding a parent-specific query avoids duplicating entity definitions while providing an optimized read path. This follows the existing pattern where `ParentDashboardController` imports billing/payment modules for read access.

**Alternative considered**: Querying through the existing `DailyClassReportsService`. Rejected because that service enforces facilitator ownership, not parent ownership.

### Decision 4: Timeline API returns summary cards, detail API returns full data

**Choice**: The list endpoint returns lightweight summary objects (date, notes preview, activity types, student focus count) with pagination. The detail endpoint returns the full report with all nested focus entries, checklist results, evidence text, and media URLs — but scoped to only the parent's linked student.

**Rationale**: Parents viewing a timeline shouldn't load all student data for every report. The detail view for a specific date is where full data is needed, and it's scoped to one student (not the whole class roster).

### Decision 5: Frontend uses two pages with date-based navigation

**Choice**: 
- `/parent/activities` — ChildActivityTimelinePage with date range picker, paginated cards
- `/parent/activities/:date` — ChildActivityDetailPage with full day detail

**Rationale**: Simple URL scheme, bookmarkable, follows mobile-first navigation patterns. The date parameter uses `YYYY-MM-DD` format matching the backend `reportDate` field.

### Decision 6: Student selector for multi-child parents

**Choice**: Parents with multiple linked children see a student selector at the top of the timeline page. Selected student is stored in component state (or URL query param `?studentId=...`). Default to the first linked child.

**Rationale**: A parent may have multiple children in different classes. The API requires a `studentId` path parameter, so the frontend must select one.

## Risks / Trade-offs

- **Repository cross-module import**: The new module imports `DailyClassReportsModule` to access its repository. → Mitigation: `DailyClassReportsModule` exports the repository. This is read-only access; no writes from the parent module.

- **Large report detail response**: A day with many focus entries and media could produce a large response. → Mitigation: The response is scoped to one student only (not all students in class), and media URLs are lightweight (Cloudinary URLs, not base64).

- **No caching**: Timeline queries hit the database on every request. → Mitigation: Acceptable for MVP scale (small school, ~50 parents). Can add response caching later if needed.

- **Student might not have records for a given day**: If the parent navigates to a date where no report exists or the report is still DRAFT. → Mitigation: Return 404 with a clear message for detail endpoint; empty list for timeline endpoint.
