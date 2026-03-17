## ADDED Requirements

### Requirement: Authorized staff can manage payment records
The system SHALL allow authenticated `FINANCE` and `SUPERADMIN` users to create, list, and view payment records.

#### Scenario: Finance creates a payment
- **WHEN** an authenticated `FINANCE` user submits valid payment data
- **THEN** the system creates the payment record
- **AND** the response includes `payment_code`, `student_id`, `billing_id`, `installment_item_id`, `payment_date`, `amount_paid`, `payment_method`, `reference_no`, and `created_by`

#### Scenario: Authorized staff lists payments
- **WHEN** an authenticated `FINANCE` or `SUPERADMIN` user requests payment data
- **THEN** the system returns the managed payment records

#### Scenario: Authorized staff views a payment detail
- **WHEN** an authenticated `FINANCE` or `SUPERADMIN` user requests a specific payment by id
- **THEN** the system returns the payment record details

### Requirement: Payments must not exceed the remaining amount
The system MUST reject a payment when `amount_paid` would exceed the remaining balance on the targeted billing or installment item.

#### Scenario: Payment within remaining amount is accepted
- **WHEN** an authenticated authorized user submits a payment less than or equal to the remaining amount
- **THEN** the system accepts the payment record

#### Scenario: Overpayment is rejected
- **WHEN** an authenticated authorized user submits a payment greater than the remaining amount
- **THEN** the system rejects the request with validation or business-rule errors

### Requirement: Payments can target billings or installment items
The system SHALL support payments recorded against a billing directly or a specific installment item.

#### Scenario: Direct billing payment
- **WHEN** an authenticated authorized user submits a payment with `billing_id`
- **THEN** the system applies the payment to the billing balance

#### Scenario: Installment item payment
- **WHEN** an authenticated authorized user submits a payment with `installment_item_id`
- **THEN** the system applies the payment to that installment item and its parent billing balance

### Requirement: Billing statuses update from payment progress
The system MUST update billing statuses according to cumulative paid amount.

#### Scenario: Partial settlement
- **WHEN** cumulative payment amount is greater than zero and less than the billing total
- **THEN** the system stores the billing status as `PARTIALLY_PAID`

#### Scenario: Full settlement
- **WHEN** cumulative payment amount equals the billing total
- **THEN** the system stores the billing status as `PAID`

### Requirement: Installment items settle when fully paid
The system MUST mark installment items as `PAID` when installment-targeted payments fully settle their item amount.

#### Scenario: Installment item is paid
- **WHEN** cumulative payment amount for an installment item equals its amount
- **THEN** the system stores that installment item status as `PAID`

### Requirement: Payment management access is limited by role
The system MUST protect payment endpoints so only authenticated `FINANCE` and `SUPERADMIN` users can access them.

#### Scenario: Anonymous request is rejected
- **WHEN** an unauthenticated request targets a payment endpoint
- **THEN** the system rejects the request as unauthenticated

#### Scenario: Unauthorized role is rejected
- **WHEN** an authenticated user without `FINANCE` or `SUPERADMIN` role targets a payment endpoint
- **THEN** the system rejects the request as forbidden

### Requirement: MVP includes a basic payment management interface
The system SHALL provide a basic frontend administration interface for authorized staff to enter payments and view payment history.

#### Scenario: Authorized staff manages payments in the UI
- **WHEN** a `FINANCE` or `SUPERADMIN` user opens the payment management screen
- **THEN** the interface shows payment records
- **AND** the interface provides controls to create payments and view payment details

#### Scenario: Unauthorized role cannot use the payment UI
- **WHEN** a user without `FINANCE` or `SUPERADMIN` role reaches the payment management screen
- **THEN** the interface shows an unauthorized or unavailable state
