## 1. Database & Entity

- [x] 1.1 Create `EvidenceMedia` TypeORM entity at `backend/src/modules/evidence-media/evidence-media.entity.ts` with all columns matching the spec (id, polymorphic FK columns, Cloudinary fields, file_type enum, metadata)
- [x] 1.2 Create TypeORM migration to add the `evidence_media` table with columns, indexes on FK columns, and CHECK constraint ensuring at least one context FK is NOT NULL

## 2. Cloudinary Service

- [x] 2.1 Create `EvidenceCloudinaryService` at `backend/src/modules/evidence-media/evidence-cloudinary.service.ts` that reuses `CLOUDINARY_URL` config, supports IMAGE/VIDEO/DOCUMENT resource types, and uploads to `evidence-media/{contextType}/{contextId}` folders
- [x] 2.2 Add Cloudinary delete support to `EvidenceCloudinaryService` (delete by `public_id`)

## 3. Backend Service & Repository

- [x] 3.1 Create `EvidenceMediaRepository` at `backend/src/modules/evidence-media/evidence-media.repository.ts` with save, findById, findByContext (filter by each FK), and remove methods
- [x] 3.2 Create `EvidenceMediaService` at `backend/src/modules/evidence-media/evidence-media.service.ts` with upload (validate context, upload to Cloudinary, persist record), getById, listByContext, and delete (ownership check, Cloudinary delete, remove record) methods

## 4. DTOs & Validation

- [x] 4.1 Create `UploadEvidenceMediaDto` with file metadata fields (`studentDailyRecordId`, `studentFocusEntryId`, `parentEvidenceId`, `caption`) and validation (at least one context FK required)
- [x] 4.2 Create `EvidenceMediaResponseDto` with all response fields
- [x] 4.3 Create `ListEvidenceMediaQueryDto` with query parameter validation (at least one context filter required)

## 5. Controller & Module

- [x] 5.1 Create `EvidenceMediaController` at `backend/src/modules/evidence-media/evidence-media.controller.ts` with `POST /evidence-media/upload` (multipart, 10MB limit, file type filter), `GET /evidence-media/:id`, `GET /evidence-media` (list with query filters), and `DELETE /evidence-media/:id` endpoints
- [x] 5.2 Create `EvidenceMediaModule` registering entity, repository, services, and controller; import ConfigModule and TypeOrmModule
- [x] 5.3 Register `EvidenceMediaModule` in `AppModule`

## 6. Frontend API Client

- [x] 6.1 Create `frontend/src/lib/evidence-media.ts` with `uploadEvidenceMedia`, `getEvidenceMedia`, `listEvidenceMedia`, and `deleteEvidenceMedia` functions using the existing API client pattern
- [x] 6.2 Add TypeScript types/interfaces for `EvidenceMedia`, `UploadEvidenceMediaPayload`, and `ListEvidenceMediaFilter`

## 7. Testing

- [x] 7.1 Write unit tests for `EvidenceMediaService` covering upload success, file type rejection, size rejection, missing context rejection, delete ownership check, and SUPERADMIN delete override
- [x] 7.2 Write unit tests for `EvidenceCloudinaryService` covering upload and delete operations with mocked Cloudinary client
- [x] 7.3 Verify backend builds and lint passes
