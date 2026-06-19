## Why

The Class Activity module requires photo and video documentation for education evidence — both from teachers during daily class reports and from parents sharing home-based evidence. The existing Cloudinary integration in `payment-proofs` is purpose-built for payment receipts and cannot be reused for general media uploads. A dedicated evidence media upload capability is needed so that `daily-class-report-core` and `parent-evidence-submission` can attach media files to student records.

## What Changes

- Introduce a new `evidence-media` backend module with upload, retrieve, and delete endpoints.
- Create the `EvidenceMedia` entity (polymorphic FK references to `StudentDailyRecord`, `StudentFocusEntry`, and `ParentEvidence`).
- Extract Cloudinary integration into a shared media upload service, reusing the existing `CloudinaryService` pattern but generalised for evidence folders and multiple file types (IMAGE, VIDEO, DOCUMENT).
- Enforce business rules: max 10MB per upload, allowed formats (JPG, PNG, MP4, PDF), file-type validation at the boundary.
- Add a migration to create the `evidence_media` table.
- Add frontend API client functions for uploading, fetching, and deleting evidence media.

## Capabilities

### New Capabilities
- `evidence-media-upload`: Upload, retrieve, and delete photo/video/document evidence files via Cloudinary. Covers the backend module, entity, Cloudinary upload logic, REST API endpoints, and frontend API client.

### Modified Capabilities
_(none — no existing spec requirements change)_

## Impact

- **Backend**: New `evidence-media/` module under `src/modules/`. New TypeORM entity and migration. Shared Cloudinary service configuration (reuses existing `CLOUDINARY_URL` env variable).
- **Frontend**: New API client file `src/lib/evidence-media.ts` for upload/fetch/delete calls.
- **Dependencies**: Depends on `cloudinary` npm package (already installed). Will be consumed by future `daily-class-report-core` and `parent-evidence-submission` capabilities.
- **Database**: New `evidence_media` table with FK columns to `student_daily_records`, `student_focus_entries`, and `parent_evidences` (all nullable, polymorphic reference).
