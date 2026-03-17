# Design: Event-Driven Personal Notification Triggers

## Context
The system now contains a robust `notifications` module that can store and retrieve personal messages for users. To create an active, engaging system, notifications must be generated automatically in response to business operations, specifically the `payment-entry-and-settlement` process.

## Goals / Non-Goals

**Goals:**
- Provide a scalable architectural pattern for domain events to trigger notifications.
- Implement an automated notification when a parent completes a payment.
- Keep the triggering logic decoupled from the core business logic using NestJS's standard libraries.

**Non-Goals:**
- Implement external message queueing (like RabbitMQ or Kafka). An in-memory event bus is sufficient for the current scale.
- Implement notifications for all possible entities (billing, installment). Focus solely on a successful Payment transaction as the proof-of-concept for the event-driven system.

## Decisions

### 1. Architecture: `@nestjs/event-emitter`
Use the official `@nestjs/event-emitter` package. It provides simple, in-memory publish-subscribe capabilities.
- Add `@nestjs/event-emitter` to the project dependencies.
- Register `EventEmitterModule.forRoot()` in `AppModule`.
- Emit a `payment.created` event from `PaymentsService.createPayment`.

### 2. Event Listener
Create an event listener (likely within the `NotificationsModule` or a new `NotificationTriggersModule`). The listener subscribes to domain events and translates them into notification records.
- **Listener Method**: `@OnEvent('payment.created') handlePaymentCreated(event: PaymentCreatedEvent)`
- **Action**: Looks up the student's primary parent (via `StudentsService` or `StudentParentMapsModule`) and creates a notification using `NotificationsService.createNotification` for that parent's `userId`.

### 3. Payload Definition
Define strongly typed event objects (e.g., `PaymentCreatedEvent`) containing at least the `payment` object and the associated `studentId` and `billingId`.
This payload ensures the listener has all the context needed to construct the semantic notification text.

## Risks / Trade-offs
- **In-Memory Volatility**: Since `@nestjs/event-emitter` uses a local in-memory bus, events are lost if the server crashes before processing them. Since the user state relies entirely on an in-memory repository right now, this is acceptable for consistency.
- **Error Handling**: Event listeners execute asynchronously by default. Uncaught exceptions inside the notification generation might not roll back the original transaction (which is arguably correct: a failure to notify shouldn't revert a successful payment).
