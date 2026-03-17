## ADDED Requirements

### Requirement: Authorized staff can manage billing records
The system SHALL allow authenticated `FINANCE` and `SUPERADMIN` users to create, list, view, and bulk-create billing records.

#### Scenario: Finance creates a billing
- **WHEN** an authenticated `FINANCE` user submits valid billing data
- **THEN** the system creates the billing record
- **AND** the response includes `student_id`, `billing_type_id`, `title`, `total_amount`, `due_date`, `installment_allowed`, `status`, `created_by`, and `created_at`

#### Scenario: Authorized staff lists billings
- **WHEN** an authenticated `FINANCE` or `SUPERADMIN` user requests billing data
- **THEN** the system returns the managed billing records

#### Scenario: Authorized staff views a billing detail
- **WHEN** an authenticated `FINANCE` or `SUPERADMIN` user requests a specific billing by id
- **THEN** the system returns the billing record details

#### Scenario: Authorized staff bulk-creates billings
- **WHEN** an authenticated `FINANCE` or `SUPERADMIN` user submits valid bulk billing input
- **THEN** the system creates billing records for the provided items

### Requirement: Billing records must reference valid students and billing types
The system MUST validate that each billing references an existing student and an existing billing type.

#### Scenario: Valid billing references are accepted
- **WHEN** an authenticated authorized user submits a billing linked to an existing student and billing type
- **THEN** the system accepts the billing record

#### Scenario: Invalid student or billing type is rejected
- **WHEN** an authenticated authorized user submits a billing linked to a missing student or missing billing type
- **THEN** the system rejects the request with validation or business-rule errors

### Requirement: Billing installment eligibility comes from the billing type definition
The system MUST derive `installment_allowed` from the selected billing type definition.

#### Scenario: Installment-allowed type creates installment-allowed billing
- **WHEN** an authenticated authorized user creates a billing using a billing type with `is_installment_allowed = true`
- **THEN** the created billing stores `installment_allowed = true`

#### Scenario: Non-installment type creates non-installment billing
- **WHEN** an authenticated authorized user creates a billing using a billing type with `is_installment_allowed = false`
- **THEN** the created billing stores `installment_allowed = false`

### Requirement: New billings start with an unpaid status
The system SHALL initialize newly created billing records with status `UNPAID` until later payment or overdue flows change them.

#### Scenario: Initial billing status
- **WHEN** an authenticated authorized user creates a billing record
- **THEN** the system stores the initial billing `status` as `UNPAID`

### Requirement: Billing management access is limited by role
The system MUST protect billing record endpoints so only authenticated `FINANCE` and `SUPERADMIN` users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets a billing management endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Unauthorized role is rejected
- **WHEN** an authenticated user without `FINANCE` or `SUPERADMIN` role targets a billing management endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic billing management interface
The system SHALL provide a basic frontend administration interface for authorized staff to view and create billing records.

#### Scenario: Authorized staff manages billings in the UI
- **WHEN** a `FINANCE` or `SUPERADMIN` user opens the billing management screen
- **THEN** the interface shows billing records
- **AND** the interface provides controls to create billings and bulk-create billings

#### Scenario: Unauthorized role cannot use the billing UI
- **WHEN** a user without `FINANCE` or `SUPERADMIN` role reaches the billing management screen
- **THEN** the interface shows an unauthorized or unavailable state

### Requirement: Parents can query billing records for linked children
The system SHALL expose an endpoint allowing authenticated `PARENT` users to fetch billing records for specific students.

#### Scenario: Parent queries valid linked student
- **WHEN** an authenticated `PARENT` requests billing records for a `studentId` they are linked to
- **THEN** the system returns the billing records for that student

#### Scenario: Parent queries unlinked student
- **WHEN** an authenticated `PARENT` requests billing records for a `studentId` they are NOT linked to
- **THEN** the system rejects the request as forbidden
