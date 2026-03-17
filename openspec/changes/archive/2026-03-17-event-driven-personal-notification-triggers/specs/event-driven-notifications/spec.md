## ADDED Requirements

### Requirement: Event Dispatch Upon Important Domain Actions
The system SHALL emit semantic domain events when state-changing financial operations occur. All such events must carry enough contextual information (e.g., entity IDs, monetary amounts, descriptive titles).

#### Scenario: Payment successfully processed emits an event
- **WHEN** a payment is successfully processed via `POST /payments`
- **THEN** the system fires a `payment.created` event containing the resulting `Payment` object and related identifiers (`billingId`, `studentId`).

### Requirement: Triggering Personal Notifications from Domain Events
The system SHALL intercept specified domain events and reliably create a personal notification for the relevant parent(s) mapping to the student involved. The message content MUST be dynamically generated based on the event payload.

#### Scenario: `payment.created` event maps to a parent notification
- **WHEN** a `payment.created` event is emitted by the system
- **THEN** the notification trigger service determines the primary parent(s) mapping to the student who made the payment
- **AND** the system calls the notifications service to generate a new personal message containing the payment details (e.g. payment code and amount).
