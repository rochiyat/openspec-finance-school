## 1. Database & Entity

- [x] 1.1 Create TypeORM migration to add `parent_evidences` table with all columns (`id`, `student_id`, `parent_id`, `date`, `evidence_text`, `created_at`, `updated_at`), indexes on `student_id`, `parent_id`, `date`, and FKs to `students` and `parents`
- [x] 1.2 In the same migration, add FK constraint from `evidence_media.parent_evidence_id` → `parent_evidences.id` with `ON DELETE SET NULL`
- [x] 1.3 Create `ParentEvidenceEntity` in `src/modules/parent-evidences/parent-evidence.entity.ts` with TypeORM decorators matching the migration schema

## 2. Backend Module Structure

- [x] 2.1 Create `ParentEvidencesModule` in `src/modules/parent-evidences/parent-evidences.module.ts` importing `TypeOrmModule.forFeature([ParentEvidenceEntity])`, `StudentParentMapsModule`, `ParentsModule`, and `EvidenceMediaModule`
- [x] 2.2 Register `ParentEvidencesModule` in `AppModule`

## 3. DTOs

- [x] 3.1 Create `CreateParentEvidenceDto` with `studentId` (UUID, required), `date` (YYYY-MM-DD string, required), and `evidenceText` (string, required) with class-validator decorators
- [x] 3.2 Create `UpdateParentEvidenceDto` with `evidenceText` (string, required)
- [x] 3.3 Create `ListParentEvidenceQueryDto` with `studentId` (required), `date` (optional), `startDate`/`endDate` (optional), `limit`/`offset` (optional)
- [x] 3.4 Create `ParentEvidenceResponseDto` and `ParentEvidenceListResponseDto` for Swagger documentation

## 4. Service

- [x] 4.1 Create `ParentEvidencesService` with `create(parentId, dto)` method that creates a `ParentEvidence` record
- [x] 4.2 Add `findAll(parentId, query)` method with filtering by `studentId`, `date`, `startDate`/`endDate`, and pagination via `limit`/`offset`
- [x] 4.3 Add `findOne(id)` method that returns the evidence with associated `EvidenceMedia` records (via `evidence_media.parent_evidence_id`)
- [x] 4.4 Add `update(id, parentId, dto)` method with ownership check (compare `parentEvidence.parentId` with requesting parent's ID)
- [x] 4.5 Add ownership guard logic: reject with 403 `ACCESS_DENIED` if the evidence belongs to a different parent

## 5. Controller

- [x] 5.1 Create `ParentEvidencesController` at route `/parent-evidences` with `@UseGuards(BearerAuthGuard, RolesGuard)` and `@Roles('PARENT')`
- [x] 5.2 Implement `POST /parent-evidences` endpoint — resolve parent ID from authenticated user, validate student linkage, call service create
- [x] 5.3 Implement `GET /parent-evidences` endpoint — validate `studentId` query param required, validate student linkage, call service findAll
- [x] 5.4 Implement `GET /parent-evidences/:id` endpoint — call service findOne with ownership check
- [x] 5.5 Implement `PATCH /parent-evidences/:id` endpoint — call service update with ownership check

## 6. Student Linkage Validation

- [x] 6.1 Add a service-level method or reuse `StudentParentMapsService` to validate that the authenticated parent is linked to the specified `studentId` — throw 403 `UNLINKED_STUDENT` if not linked

## 7. Backend Tests

- [x] 7.1 Write unit tests for `ParentEvidencesService` covering: create, findAll with filters, findOne with media, update, ownership rejection
- [x] 7.2 Write controller-level tests verifying correct HTTP status codes for all scenarios (201 create, 200 list/detail/update, 400 validation, 403 unlinked/ownership, 404 not found)

## 8. Frontend API Client

- [x] 8.1 Create `src/lib/parent-evidence.ts` with `createParentEvidence(token, payload)`, `listParentEvidence(token, filter)`, `getParentEvidence(token, id)`, `updateParentEvidence(token, id, payload)` functions
- [x] 8.2 Define `ParentEvidence` and related TypeScript interfaces matching the backend response shape

## 9. Frontend Pages

- [x] 9.1 Create `ParentSubmitEvidencePage` component at `/parent/evidence/submit` with child selector, date picker (default today), evidence text textarea, and media upload zone using existing `uploadEvidenceMedia` client
- [x] 9.2 Create `ParentEvidenceListPage` component at `/parent/evidence` with child selector, date filter, paginated evidence card list, and empty state with CTA
- [x] 9.3 Add evidence detail view (inline or sub-route) showing full evidence text and media gallery
- [x] 9.4 Add routes to the parent section of the router configuration

## 10. Integration## Phase 10: Verification
- [x] 10.1 Run backend build (`npm run build`) to verify compilation
- [x] 10.2 Run backend tests (`npm run test`) to verify all tests pass
- [x] 10.3 Run backend lint (`npm run lint`) to verify code quality
- [x] 10.4 Run frontend build (`npm run build`) to verify compilation
- [x] 10.5 Run frontend lint (`npm run lint`) to verify code quality
