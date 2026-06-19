## ADDED Requirements

### Requirement: Authenticated user can upload evidence media
The system SHALL provide `POST /evidence-media/upload` to upload a file (image, video, or document) to Cloudinary and persist an `EvidenceMedia` record. The request SHALL be a `multipart/form-data` request with a `file` field and JSON metadata fields. Only authenticated users with the `GURU` or `PARENT` role SHALL be permitted to upload.

#### Scenario: Teacher uploads a photo for a student focus entry
- **WHEN** an authenticated `GURU` sends a `POST /evidence-media/upload` request with a valid JPEG file (≤10MB) and `studentFocusEntryId` in the metadata
- **THEN** the system uploads the file to Cloudinary under the `evidence-media/student-focus-entry/{id}` folder
- **AND** creates an `EvidenceMedia` record with `file_type` set to `IMAGE`, `cloudinary_url` set to the returned `secure_url`, and `uploaded_by_user_id` set to the authenticated user
- **AND** returns the created record with HTTP 201

#### Scenario: Teacher uploads a video for a student daily record
- **WHEN** an authenticated `GURU` sends a `POST /evidence-media/upload` request with a valid MP4 file (≤10MB) and `studentDailyRecordId` in the metadata
- **THEN** the system uploads the file to Cloudinary with `resource_type: video`
- **AND** creates an `EvidenceMedia` record with `file_type` set to `VIDEO` and `thumbnail_url` populated from the Cloudinary response
- **AND** returns the created record with HTTP 201

#### Scenario: Parent uploads a document for a parent evidence
- **WHEN** an authenticated `PARENT` sends a `POST /evidence-media/upload` request with a valid PDF file (≤10MB) and `parentEvidenceId` in the metadata
- **THEN** the system uploads the file to Cloudinary with `resource_type: raw`
- **AND** creates an `EvidenceMedia` record with `file_type` set to `DOCUMENT`
- **AND** returns the created record with HTTP 201

#### Scenario: Upload rejected — file exceeds 10MB
- **WHEN** a user sends a `POST /evidence-media/upload` request with a file larger than 10MB
- **THEN** the system rejects the request with HTTP 400
- **AND** returns an error with `errorCode: FILE_TOO_LARGE`

#### Scenario: Upload rejected — unsupported file type
- **WHEN** a user sends a `POST /evidence-media/upload` request with a file whose MIME type is not `image/jpeg`, `image/png`, `video/mp4`, or `application/pdf`
- **THEN** the system rejects the request with HTTP 400
- **AND** returns an error with `errorCode: UNSUPPORTED_FILE_TYPE`

#### Scenario: Upload rejected — no context reference provided
- **WHEN** a user sends a `POST /evidence-media/upload` request without any of `studentDailyRecordId`, `studentFocusEntryId`, or `parentEvidenceId`
- **THEN** the system rejects the request with HTTP 400
- **AND** returns an error with `errorCode: MISSING_CONTEXT_REFERENCE`

#### Scenario: Upload rejected — Cloudinary not configured
- **WHEN** a user sends a `POST /evidence-media/upload` request but Cloudinary credentials are not configured
- **THEN** the system rejects the request with HTTP 500
- **AND** returns an error with `errorCode: CLOUDINARY_NOT_CONFIGURED`

#### Scenario: Upload rejected — unauthenticated request
- **WHEN** an unauthenticated request is sent to `POST /evidence-media/upload`
- **THEN** the system rejects the request with HTTP 401

---

### Requirement: Authenticated user can retrieve evidence media by ID
The system SHALL provide `GET /evidence-media/:id` to retrieve a single `EvidenceMedia` record by its UUID. All authenticated users SHALL be permitted.

#### Scenario: Media found
- **WHEN** an authenticated user sends a `GET /evidence-media/:id` request for an existing media record
- **THEN** the system returns the `EvidenceMedia` record including `id`, `cloudinaryUrl`, `thumbnailUrl`, `fileType`, `originalFilename`, `fileSizeBytes`, `caption`, `uploadedByUserId`, and `createdAt`

#### Scenario: Media not found
- **WHEN** an authenticated user sends a `GET /evidence-media/:id` request for a non-existent UUID
- **THEN** the system returns HTTP 404 with `errorCode: EVIDENCE_MEDIA_NOT_FOUND`

---

### Requirement: Authenticated user can list evidence media by context
The system SHALL provide query parameters on `GET /evidence-media` to filter media by their context reference. At least one of `studentDailyRecordId`, `studentFocusEntryId`, or `parentEvidenceId` SHALL be provided as a query parameter.

#### Scenario: List media by student focus entry
- **WHEN** an authenticated user sends a `GET /evidence-media?studentFocusEntryId={id}` request
- **THEN** the system returns all `EvidenceMedia` records linked to the specified `StudentFocusEntry`, ordered by `created_at` ascending

#### Scenario: List media by student daily record
- **WHEN** an authenticated user sends a `GET /evidence-media?studentDailyRecordId={id}` request
- **THEN** the system returns all `EvidenceMedia` records linked to the specified `StudentDailyRecord`, ordered by `created_at` ascending

#### Scenario: List media by parent evidence
- **WHEN** an authenticated user sends a `GET /evidence-media?parentEvidenceId={id}` request
- **THEN** the system returns all `EvidenceMedia` records linked to the specified `ParentEvidence`, ordered by `created_at` ascending

#### Scenario: No filter provided
- **WHEN** an authenticated user sends a `GET /evidence-media` request without any context filter
- **THEN** the system rejects the request with HTTP 400 and `errorCode: MISSING_CONTEXT_FILTER`

---

### Requirement: Uploader can delete their own evidence media
The system SHALL provide `DELETE /evidence-media/:id` to permanently remove an `EvidenceMedia` record and its associated Cloudinary file. Only the user who originally uploaded the media SHALL be permitted to delete it, unless the user has the `SUPERADMIN` role.

#### Scenario: Uploader deletes their own media
- **WHEN** an authenticated user sends a `DELETE /evidence-media/:id` request for a media record they uploaded
- **THEN** the system deletes the file from Cloudinary using the stored `cloudinary_public_id`
- **AND** removes the `EvidenceMedia` record from the database
- **AND** returns HTTP 200 with a success message

#### Scenario: Non-uploader attempts to delete
- **WHEN** an authenticated user (non-SUPERADMIN) sends a `DELETE /evidence-media/:id` request for a media record uploaded by a different user
- **THEN** the system rejects the request with HTTP 403

#### Scenario: SUPERADMIN can delete any media
- **WHEN** an authenticated `SUPERADMIN` sends a `DELETE /evidence-media/:id` request for any media record
- **THEN** the system deletes the file from Cloudinary and removes the database record
- **AND** returns HTTP 200

#### Scenario: Media not found on delete
- **WHEN** an authenticated user sends a `DELETE /evidence-media/:id` request for a non-existent UUID
- **THEN** the system returns HTTP 404 with `errorCode: EVIDENCE_MEDIA_NOT_FOUND`

---

### Requirement: EvidenceMedia entity stores Cloudinary metadata
The system SHALL persist `EvidenceMedia` records in the `evidence_media` database table with the following schema:
- `id` (UUID, primary key)
- `student_daily_record_id` (UUID, FK → nullable)
- `student_focus_entry_id` (UUID, FK → nullable)
- `parent_evidence_id` (UUID, FK → nullable)
- `uploaded_by_user_id` (UUID, FK → users, NOT NULL)
- `cloudinary_public_id` (varchar, NOT NULL)
- `cloudinary_url` (varchar, NOT NULL)
- `thumbnail_url` (varchar, nullable)
- `file_type` (enum: IMAGE, VIDEO, DOCUMENT, NOT NULL)
- `original_filename` (varchar, NOT NULL)
- `file_size_bytes` (integer, NOT NULL)
- `caption` (varchar, nullable)
- `created_at` (timestamp, NOT NULL)

A database CHECK constraint SHALL ensure that at least one of `student_daily_record_id`, `student_focus_entry_id`, or `parent_evidence_id` is NOT NULL.

#### Scenario: Migration creates the evidence_media table
- **WHEN** the database migration for this capability runs
- **THEN** the `evidence_media` table is created with all columns and constraints as specified
- **AND** indexes are created on `student_daily_record_id`, `student_focus_entry_id`, `parent_evidence_id`, and `uploaded_by_user_id`

#### Scenario: CHECK constraint prevents orphan records
- **WHEN** an attempt is made to insert an `evidence_media` record with all three context FK columns set to NULL
- **THEN** the database rejects the insert with a constraint violation

---

### Requirement: Frontend API client for evidence media operations
The system SHALL provide a frontend API client module at `src/lib/evidence-media.ts` with functions for uploading, listing, fetching, and deleting evidence media.

#### Scenario: Frontend uploads a file
- **WHEN** the frontend calls `uploadEvidenceMedia(file, metadata)` with a `File` object and context metadata
- **THEN** the function sends a `POST /evidence-media/upload` multipart request
- **AND** returns the created `EvidenceMedia` record from the response

#### Scenario: Frontend lists media by context
- **WHEN** the frontend calls `listEvidenceMedia(filter)` with a context filter object
- **THEN** the function sends a `GET /evidence-media` request with query parameters
- **AND** returns the array of `EvidenceMedia` records

#### Scenario: Frontend deletes media
- **WHEN** the frontend calls `deleteEvidenceMedia(id)` with a media UUID
- **THEN** the function sends a `DELETE /evidence-media/:id` request
- **AND** returns the success response
