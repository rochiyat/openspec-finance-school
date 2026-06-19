## 1. Database Schema & Migrations

- [x] 1.1 Create TypeORM migration for `education_focuses` table (id uuid PK, name varchar unique, description text, display_order integer, is_active boolean default true, created_at timestamp, updated_at timestamp)
- [x] 1.2 Create TypeORM migration for `focus_checklists` table (id uuid PK, education_focus_id uuid FK, title varchar, description text, display_order integer, is_active boolean default true, created_at timestamp, updated_at timestamp)
- [x] 1.3 Create seed migration to insert 4 default education focuses (Pendidikan Iman, Pendidikan Ego & Individualitas, Pendidikan Bahasa, Psikomotor) using INSERT ON CONFLICT DO NOTHING

## 2. Backend Entities

- [x] 2.1 Create `EducationFocusEntity` in `src/modules/education-focuses/education-focus.entity.ts` with TypeORM decorators, `@PrimaryGeneratedColumn('uuid')`, and `@OneToMany` relation to `FocusChecklistEntity`
- [x] 2.2 Create `FocusChecklistEntity` in `src/modules/education-focuses/focus-checklist.entity.ts` with TypeORM decorators, `@PrimaryGeneratedColumn('uuid')`, and `@ManyToOne` relation to `EducationFocusEntity`

## 3. Backend DTOs

- [x] 3.1 Create `CreateEducationFocusDto` (name: required string, description: optional string, display_order: optional number)
- [x] 3.2 Create `UpdateEducationFocusDto` (all fields optional: name, description, display_order, is_active)
- [x] 3.3 Create `CreateFocusChecklistDto` (title: required string, description: optional string, display_order: optional number)
- [x] 3.4 Create `UpdateFocusChecklistDto` (all fields optional: title, description, display_order, is_active)
- [x] 3.5 Create response DTOs: `EducationFocusResponseDto`, `EducationFocusListResponseDto`, `FocusChecklistResponseDto`

## 4. Backend Repository

- [x] 4.1 Create `EducationFocusesRepository` with methods: findAll (with includeInactive filter), findById, findByName, save
- [x] 4.2 Create `FocusChecklistsRepository` with methods: findByFocusId (with includeInactive filter), findById, save

## 5. Backend Service

- [x] 5.1 Create `EducationFocusesService` with methods: listFocuses (includeInactive param), getFocusById, createFocus (with name uniqueness check), updateFocus (with name conflict check), softDeleteFocus (cascade deactivate checklists)
- [x] 5.2 Add checklist management methods to service: createChecklist (validate parent focus exists), updateChecklist (validate parent focus and checklist ownership), softDeleteChecklist

## 6. Backend Controller

- [x] 6.1 Create `EducationFocusesController` at `education-focuses` route with endpoints: GET `/`, GET `/:id`, POST `/`, PATCH `/:id`, DELETE `/:id`, POST `/:id/checklists`, PATCH `/:focusId/checklists/:checklistId`, DELETE `/:focusId/checklists/:checklistId` (all write endpoints protected by `SUPERADMIN` role)
- [x] 6.3 Add checklist endpoints: `POST /education-focuses/:id/checklists` (SUPERADMIN), `PATCH /education-focuses/:focusId/checklists/:checklistId` (SUPERADMIN), `DELETE /education-focuses/:focusId/checklists/:checklistId` (SUPERADMIN)
- [x] 6.4 Add Swagger decorators (ApiTags, ApiOperation, ApiResponse) to all endpoints

## 7. Backend Module & Registration

- [x] 7.1 Create `EducationFocusesModule` importing TypeOrmModule.forFeature for both entities, providing repository and service, exporting service
- [x] 7.2 Register `EducationFocusesModule` in `AppModule`

## 8. Frontend Admin Page

- [x] 8.1 Create API service functions in `src/lib/` for education focus CRUD and checklist CRUD
- [x] 8.2 Create `EducationFocusPage.tsx` under `src/pages/admin/` with list view of focuses ordered by display_order
- [x] 8.3 Add create/edit focus modal or inline form with name, description, display_order fields
- [x] 8.4 Add inline expandable checklist management per focus (add, edit, deactivate checklist items)
- [x] 8.5 Add soft-delete (deactivate) action with confirmation dialog for focuses and checklists
- [x] 8.6 Add route entry for `/admin/education-focuses` in the router configuration

## 9. Testing

- [x] 9.1 Write service-level unit tests for education focus CRUD (create, update, soft-delete, name uniqueness)
- [x] 9.2 Write service-level unit tests for checklist CRUD (create, update, soft-delete, parent validation)
- [x] 9.3 Write controller-level tests for role-based access (SUPERADMIN write, authenticated read, forbidden for wrong role)
- [x] 9.4 Verify seed migration runs successfully and is idempotent

## 10. Verification

- [x] 10.1 Run backend build (`npm run build` from backend/) and confirm no compilation errors
- [x] 10.2 Run backend tests (`npm run test` from backend/) and confirm all pass
- [x] 10.3 Run frontend build (`npm run build` from frontend/) and confirm no compilation errors (Note: Pre-existing TS errors unrelated to this feature are present in frontend)
- [x] 10.4 Run backend lint (`npm run lint` from backend/) and confirm no lint errors
