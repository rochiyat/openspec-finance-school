## Context

The Class Activity module needs a way for teachers and parents to upload photo, video, and document evidence. The system already has a working Cloudinary integration in `payment-proofs/cloudinary.service.ts` that handles image uploads and returns `secure_url` values. That service is tightly coupled to payment proof logic (hardcoded `payment-proofs` folder, image-only resource type).

The PRD defines an `EvidenceMedia` entity with polymorphic FK references — media can be attached to a `StudentDailyRecord`, a `StudentFocusEntry`, or a `ParentEvidence`. All files go to Cloudinary.

Key constraints:
- Max 10MB per upload
- Allowed formats: JPG, PNG, MP4, PDF
- Cloudinary credentials already configured via `CLOUDINARY_URL` env variable
- Mobile-first: teachers upload directly from phone cameras

## Goals / Non-Goals

**Goals:**
- Provide upload, retrieve, and delete REST endpoints for evidence media
- Create the `EvidenceMedia` TypeORM entity and database migration
- Generalise the Cloudinary upload logic to handle IMAGE, VIDEO, and DOCUMENT file types
- Enforce file size and type validation at the API boundary
- Provide a frontend API client for evidence media operations

**Non-Goals:**
- Refactoring or replacing the existing `payment-proofs` Cloudinary service (it continues to work as-is)
- Building the frontend upload UI (that belongs to `daily-class-report-core` and `parent-evidence-submission`)
- Image/video transcoding or thumbnail generation beyond what Cloudinary provides natively
- Parent evidence submission flow (separate capability)

## Decisions

### 1. Separate Cloudinary service rather than shared extraction

**Decision**: Create a new `EvidenceCloudinaryService` inside the `evidence-media` module rather than extracting a shared service from `payment-proofs`.

**Rationale**: The payment-proofs module is stable and deployed. Extracting a shared service would require modifying tested code for no immediate benefit. The two services have different folder paths, different allowed file types, and different size limits. A future refactor can consolidate them if needed.

**Alternative considered**: Extracting a generic `CloudinaryUploadService` into a `common/` or `shared/` module. Rejected because it introduces coupling between unrelated domains and the payment-proofs module has no planned changes.

### 2. Polymorphic FK approach (nullable columns)

**Decision**: Use three nullable FK columns (`student_daily_record_id`, `student_focus_entry_id`, `parent_evidence_id`) on the `evidence_media` table, matching the PRD domain model.

**Rationale**: Follows the PRD exactly. Simple to query (just filter by the relevant FK). A CHECK constraint ensures at least one FK is set. Avoids the complexity of a generic polymorphic `entity_type + entity_id` pattern that would lose referential integrity.

**Alternative considered**: Single `reference_type` + `reference_id` pattern. Rejected because it cannot enforce FK constraints and makes joins harder.

### 3. File type detection from MIME type

**Decision**: Derive `file_type` (IMAGE | VIDEO | DOCUMENT) from the uploaded file's MIME type at the controller level.

**Rationale**: MIME type is the most reliable signal available at upload time. The mapping is straightforward: `image/*` → IMAGE, `video/*` → VIDEO, `application/pdf` → DOCUMENT.

### 4. Cloudinary folder structure

**Decision**: Use `evidence-media/{contextType}/{contextId}` as the Cloudinary folder path (e.g., `evidence-media/student-focus-entry/abc-123`).

**Rationale**: Organises files by context for easy browsing in the Cloudinary dashboard. Avoids a flat dump of all evidence files.

### 5. Soft-delete via record removal, not status flag

**Decision**: DELETE endpoint removes the database record and deletes the file from Cloudinary. No soft-delete.

**Rationale**: Evidence media are subordinate to their parent records. If a teacher removes a photo, it should be gone. The parent record (StudentFocusEntry, etc.) maintains audit history. Orphaned Cloudinary files waste storage.

## Risks / Trade-offs

- **Cloudinary latency on upload** → Mitigated by keeping uploads synchronous for MVP (the PRD requires a progress indicator, which the frontend can implement with upload progress events). Async upload processing can be added later if needed.
- **10MB upload limit may hit NestJS/reverse-proxy body size limits** → Mitigated by explicitly configuring Multer `limits.fileSize` and documenting that Nginx/ALB must allow 10MB+ request bodies.
- **No thumbnail generation for videos** → Cloudinary auto-generates video thumbnails. We store the `thumbnail_url` from the Cloudinary response.
- **Polymorphic FK columns add nullable complexity** → Mitigated by a database CHECK constraint and DTO validation ensuring exactly one context reference is provided per upload.
