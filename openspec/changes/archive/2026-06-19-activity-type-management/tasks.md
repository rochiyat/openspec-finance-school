## 1. Backend Entity & Repository

- [x] 1.1 Create `ActivityTypeEntity` in `backend/src/modules/activity-types/activity-type.entity.ts` with columns: id (uuid PK), name (varchar unique), description (text nullable), display_order (int default 0), is_active (boolean default true), created_at, updated_at
- [x] 1.2 Create `ActivityTypesRepository` in `backend/src/modules/activity-types/activity-types.repository.ts` with methods: findAll(includeInactive), findById(id), findByName(name), save(entity)

## 2. Backend DTOs

- [x] 2.1 Create `CreateActivityTypeDto` with name (required), description (optional), displayOrder (optional)
- [x] 2.2 Create `UpdateActivityTypeDto` with all fields optional (name, description, displayOrder, isActive)
- [x] 2.3 Create `ActivityTypeResponseDto` and `ActivityTypeListResponseDto` for Swagger documentation

## 3. Backend Service

- [x] 3.1 Create `ActivityTypesService` in `backend/src/modules/activity-types/activity-types.service.ts` with methods: listActivityTypes, getById, create, update, softDelete
- [x] 3.2 Implement unique-name validation with ConflictException and error code `ACTIVITY_TYPE_NAME_EXISTS`
- [x] 3.3 Implement not-found handling with NotFoundException and error code `ACTIVITY_TYPE_NOT_FOUND`
- [x] 3.4 Implement soft-delete (set isActive = false)

## 4. Backend Controller

- [x] 4.1 Create `ActivityTypesController` at `/activity-types` with CRUD endpoints (GET list, GET by id, POST, PATCH, DELETE)
- [x] 4.2 Add Swagger decorators (ApiTags, ApiOperation, ApiResponse)
- [x] 4.3 Add BearerAuthGuard + RolesGuard; restrict POST/PATCH/DELETE to SUPERADMIN role

## 5. Backend Module & Registration

- [x] 5.1 Create `ActivityTypesModule` importing TypeORM entity and providing repository, service, controller
- [x] 5.2 Register `ActivityTypesModule` in `AppModule`

## 6. Database Migration & Seed

- [x] 6.1 Create TypeORM migration for `activity_types` table
- [x] 6.2 Create seed migration inserting 8 default activity types (Pembukaan, Main Bebas, Circle Time, Multi Sensory, Kudapan Pagi, Read Aloud & Pembelajaran Al Quran, Tematic, Penutup) with idempotent insert

## 7. Backend Tests

- [x] 7.1 Write unit tests for `ActivityTypesService` covering: list, getById, create, create duplicate, update, update duplicate name, softDelete, delete not found

## 8. Frontend API Client

- [x] 8.1 Create `frontend/src/lib/activity-type.ts` with API functions: fetchActivityTypes, fetchActivityType, createActivityType, updateActivityType, deleteActivityType

## 9. Frontend Admin Page

- [x] 9.1 Create `ActivityTypePage.tsx` in `frontend/src/pages/admin/` with table listing activity types (name, description, order, status, actions)
- [x] 9.2 Implement create/edit modal with fields: name (required), description (optional), displayOrder (optional)
- [x] 9.3 Implement delete confirmation dialog with soft-delete
- [x] 9.4 Add toggle for showing/hiding inactive activity types

## 10. Frontend Routing

- [x] 10.1 Register the ActivityTypePage route in the admin section of the app router
- [x] 10.2 Add navigation link/menu item for "Jenis Aktivitas" in admin sidebar
