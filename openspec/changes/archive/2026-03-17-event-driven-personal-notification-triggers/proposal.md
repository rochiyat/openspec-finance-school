# Proposal: Event-Driven Personal Notification Triggers

## Why
We recently introduced a Personal Notification Center (`parent-notification-inbox`) allowing parents to view personal notifications. However, notifications are not yet being triggered by real application events. To make the notification center useful and to keep parents informed of critical financial updates in real-time, the system needs to automatically generate personal notifications when specific actions occur (like payments being recorded or billings changing status).

## What Changes
- Introduce event-driven architecture (e.g., NestJS CQRS/EventEmitter) or simple service hooks to trigger notifications.
- Trigger a personal notification to the relevant parent when:
  - A payment is successfully recorded for their student.
  - A new billing or installment plan is created/assigned to their student (optional, focus on payment first).
- Connect the `PaymentsService` (or relevant module) to the `NotificationsService` to create a notification record seamlessly.

## Capabilities

### New Capabilities
- `event-driven-notifications`: System automatically dispatches internal personal notifications based on domain events.

### Modified Capabilities
- `payment-entry-and-settlement`: Extended to trigger a notification to the parent upon successful payment entry.

## Impact
- **Backend Services**: Modifications to `PaymentsService` (to emit events or call `NotificationsService` directly).
- **Architecture**: Potential introduction of `@nestjs/event-emitter` if not already present, for decoupling.
- **Testing**: Updates to service unit tests and E2E tests to verify notification creation upon payment.
