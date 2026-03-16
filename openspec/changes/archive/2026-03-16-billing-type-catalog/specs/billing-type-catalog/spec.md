## ADDED Requirements

### Requirement: Superadmin can manage billing types
The system SHALL allow an authenticated superadmin to create, list, view, and update billing types.

#### Scenario: Superadmin creates a billing type
- **WHEN** an authenticated superadmin submits valid billing type data
- **THEN** the system creates the billing type record
- **AND** the response includes `code`, `name`, `is_installment_allowed`, and `recurrence_type`

#### Scenario: Superadmin lists billing types
- **WHEN** an authenticated superadmin requests billing type data
- **THEN** the system returns the managed billing type records

#### Scenario: Superadmin views a billing type detail
- **WHEN** an authenticated superadmin requests a specific billing type by id
- **THEN** the system returns the billing type record details

#### Scenario: Superadmin updates a billing type
- **WHEN** an authenticated superadmin submits a valid update for a billing type
- **THEN** the system updates the billing type record

### Requirement: Billing type codes are unique and carry billing behavior metadata
The system MUST enforce unique billing type codes and persist whether installments are allowed plus the defined recurrence type.

#### Scenario: Duplicate billing type code is rejected
- **WHEN** an authenticated superadmin submits a billing type using a code that already exists
- **THEN** the system rejects the request with validation or business-rule errors

#### Scenario: Installment and recurrence fields are stored
- **WHEN** an authenticated superadmin creates or updates a billing type
- **THEN** the system stores `is_installment_allowed` and `recurrence_type` as part of the billing type definition

### Requirement: MVP billing type catalog includes the standard core types
The system SHALL provide the standard MVP billing types `UANG_MASUK`, `SPP`, and `UANG_TAHUNAN` for downstream billing workflows.

#### Scenario: Standard catalog is available
- **WHEN** an authenticated superadmin accesses the billing type catalog in a freshly initialized environment
- **THEN** the system provides `UANG_MASUK`, `SPP`, and `UANG_TAHUNAN` as available billing types

### Requirement: Billing type administration is superadmin-only
The system MUST protect billing type management endpoints so only authenticated superadmin users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets a billing type administration endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Non-superadmin request is rejected
- **WHEN** an authenticated non-superadmin request targets a billing type administration endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic billing type management interface
The system SHALL provide a basic frontend administration interface for superadmin to view and manage billing types.

#### Scenario: Superadmin manages billing types in the UI
- **WHEN** a superadmin opens the billing type management screen
- **THEN** the interface shows billing type records
- **AND** the interface provides controls to create and update billing types

#### Scenario: Non-superadmin cannot use the billing type UI
- **WHEN** a non-superadmin session reaches the billing type management screen
- **THEN** the interface shows an unauthorized or unavailable state
