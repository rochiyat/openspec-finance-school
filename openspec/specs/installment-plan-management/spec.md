## ADDED Requirements

### Requirement: Authorized staff can create installment plans
The system SHALL allow authenticated `FINANCE` and `SUPERADMIN` users to create installment plans for eligible billing records.

#### Scenario: Finance creates an installment plan
- **WHEN** an authenticated `FINANCE` user submits valid installment plan data for an eligible billing
- **THEN** the system creates the installment plan
- **AND** the response includes `billing_id`, `total_installments`, `installment_amount`, and `start_date`

### Requirement: Installment plans generate installment items
The system MUST generate installment items for each created installment plan with sequence numbers, due dates, amounts, and statuses.

#### Scenario: Installment items are generated
- **WHEN** an authenticated authorized user creates an installment plan with `total_installments`
- **THEN** the system creates matching installment items with `installment_no`, `due_date`, `amount`, and `status`
- **AND** each new installment item starts with status `UNPAID`

### Requirement: Installments can only be created for installment-eligible billings
The system MUST reject installment plan creation when the linked billing does not allow installments.

#### Scenario: Eligible billing allows installments
- **WHEN** an authenticated authorized user creates an installment plan for a billing with `installment_allowed = true`
- **THEN** the system accepts the installment plan

#### Scenario: Ineligible billing is rejected
- **WHEN** an authenticated authorized user creates an installment plan for a billing with `installment_allowed = false`
- **THEN** the system rejects the request with validation or business-rule errors

### Requirement: Authorized staff can view installment plan details
The system SHALL allow authenticated `FINANCE` and `SUPERADMIN` users to retrieve installment plan details with generated installment items.

#### Scenario: Installment plan detail is returned
- **WHEN** an authenticated authorized user requests `GET /installments/plans/:id`
- **THEN** the system returns the installment plan details
- **AND** the response includes generated installment items for that plan

### Requirement: Installment management access is limited by role
The system MUST protect installment plan endpoints so only authenticated `FINANCE` and `SUPERADMIN` users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets an installment management endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Unauthorized role is rejected
- **WHEN** an authenticated user without `FINANCE` or `SUPERADMIN` role targets an installment management endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic installment management interface
The system SHALL provide a basic frontend administration interface for authorized staff to create and view installment plans.

#### Scenario: Authorized staff manages installments in the UI
- **WHEN** a `FINANCE` or `SUPERADMIN` user opens the installment management screen
- **THEN** the interface shows installment plans
- **AND** the interface provides controls to create installment plans and view generated installment items

#### Scenario: Unauthorized role cannot use the installment UI
- **WHEN** a user without `FINANCE` or `SUPERADMIN` role reaches the installment management screen
- **THEN** the interface shows an unauthorized or unavailable state
