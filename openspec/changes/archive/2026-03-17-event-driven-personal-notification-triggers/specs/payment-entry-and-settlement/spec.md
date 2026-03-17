## MODIFIED Requirements

### Requirement: Payment Processing Outcomes (Triggering Notifications)
The existing payment processing operation MUST fire a notification event. The core requirement is extended to mandate that successful persistence of a payment also results in notifying the parent.

#### Scenario: Submitting a valid payment entry generates a parent notification
- **WHEN** an authenticated user with `FINANCE` or `SUPERADMIN` role provides valid data for a new payment
- **THEN** the system stores the payment record
- **AND** updates the status of the related billing entity
- **AND** calculates the new total payment amount compared against the billing amount limits
- **AND** emits an event or directly calls a notification service hook to ensure the parent is alerted to this successful payment
- **AND** returns a `PaymentResponseDto`.
