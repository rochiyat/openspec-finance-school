## 1. Backend Module Setup

- [x] 1.1 Create `student-daily-activities` module directory under `backend/src/modules/`
- [x] 1.2 Create `StudentDailyActivitiesModule` with imports of `DailyClassReportsModule` and `StudentParentMapsModule`
- [x] 1.3 Export `DailyClassReportsRepository` from `DailyClassReportsModule` so the new module can inject it

## 2. Backend Repository Extension

- [x] 2.1 Add `findPublishedByStudentWithSummary` method to `DailyClassReportsRepository` — queries published reports joined through `StudentDailyRecord` to filter by `studentId`, returns summary data (date, notes, activity types, focus count, media presence), supports date range and pagination
- [x] 2.2 Add `findPublishedByStudentAndDate` method to `DailyClassReportsRepository` — queries a single published report for a student on a specific date, with full nested joins (focus entries, checklist results, evidence media), scoped to the student's `StudentDailyRecord` only

## 3. Backend Service

- [x] 3.1 Create `StudentDailyActivitiesService` with injected `DailyClassReportsRepository`
- [x] 3.2 Implement `getTimeline(studentId, filter)` method — calls `findPublishedByStudentWithSummary`, returns paginated summary DTOs
- [x] 3.3 Implement `getDetail(studentId, date)` method — calls `findPublishedByStudentAndDate`, returns full detail DTO scoped to the student, returns 404 if no published report found

## 4. Backend Controller & DTOs

- [x] 4.1 Create response DTOs: `DailyActivitySummaryDto`, `DailyActivityDetailDto`, `FocusEntryDetailDto`, `CheckResultDetailDto`, `EvidenceMediaDto`
- [x] 4.2 Create query DTO: `ListDailyActivitiesQueryDto` with optional `startDate`, `endDate`, `limit`, `offset` fields
- [x] 4.3 Create `StudentDailyActivitiesController` at path `/parents/students/:studentId/daily-activities` with `IsParentOfStudentGuard`, `BearerAuthGuard`, `RolesGuard`, `@Roles('PARENT')`
- [x] 4.4 Implement `GET /` handler — list timeline endpoint with query filters
- [x] 4.5 Implement `GET /:date` handler — detail endpoint with date path param validation (`YYYY-MM-DD` format)

## 5. Backend Tests

- [x] 5.1 Write unit tests for `StudentDailyActivitiesService` — verify PUBLISHED-only filtering, student scoping, 404 on missing/DRAFT reports, pagination, date range filtering
- [x] 5.2 Register the new module in `AppModule`

## 6. Frontend API Layer

- [x] 6.1 Create `useStudentDailyActivities` hook — fetches timeline from `GET /parents/students/:studentId/daily-activities` with date/pagination params
- [x] 6.2 Create `useStudentDailyActivityDetail` hook — fetches detail from `GET /parents/students/:studentId/daily-activities/:date`
- [x] 6.3 Create `useParentLinkedStudents` hook — fetches linked students for the current parent user (reuse existing `StudentParentMapsService` endpoint)

## 7. Frontend Timeline Page

- [x] 7.1 Create `ChildActivityTimelinePage` component at `/parent/activities`
- [x] 7.2 Add student selector dropdown for parents with multiple linked children
- [x] 7.3 Implement date range filter (start/end date pickers)
- [x] 7.4 Render activity summary cards with: date, activity types badges, focus count, media indicator icon, notes preview
- [x] 7.5 Add pagination or infinite scroll for timeline
- [x] 7.6 Handle empty state with friendly message

## 8. Frontend Detail Page

- [x] 8.1 Create `ChildActivityDetailPage` component at `/parent/activities/:date`
- [x] 8.2 Display activity types as a horizontal badge row
- [x] 8.3 Display teacher daily notes section
- [x] 8.4 Render focus entry cards with: education focus name, evidence text, checklist items with check/uncheck indicators
- [x] 8.5 Implement media gallery with thumbnails and full-size lightbox view
- [x] 8.6 Handle 404 state with "Tidak ada aktivitas" message and back-to-timeline link

## 9. Frontend Routing & Navigation

- [x] 9.1 Add routes to `AppRouter.tsx`: `/parent/activities` and `/parent/activities/:date`
- [x] 9.2 Add "Aktivitas Anak" navigation item to parent sidebar/layout
- [x] 9.3 Add activity shortcut card/link to `ParentOverviewPage`
