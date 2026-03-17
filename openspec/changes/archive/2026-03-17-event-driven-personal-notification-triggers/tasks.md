## 1. Setup `@nestjs/event-emitter`

- [x] 1.1 Add `@nestjs/event-emitter` as a dependency (`npm run build` after adding via package manager if needed, or if already available, verify module works).
- [x] 1.2 Import and register `EventEmitterModule.forRoot()` in `app.module.ts`.

## 2. Emitting Domain Events

- [x] 2.1 Define strongly typed event payloads (e.g. `export class PaymentCreatedEvent { constructor(public readonly payment: Payment, public readonly studentId: string, public readonly billingId: string) {} }`) in a new `modules/events` or within `modules/payments/events`.
- [x] 2.2 Inject `EventEmitter2` into `PaymentsService`.
- [x] 2.3 Emit `payment.created` event from `PaymentsService.createPayment` method, ensuring it fires only upon successful save.
- [x] 2.4 Update `PaymentsService` unit tests to verify `EventEmitter2` is injected.

## 3. Event Listeners & Notification Integration

- [x] 3.1 Create `NotificationListeners` class in `NotificationsModule`.
- [x] 3.2 Ensure `NotificationListeners` inherits dependencies `NotificationsService` and `StudentParentMapsService` (to find the parent `userId`). (May require `StudentParentMapsModule` to be injected into `NotificationsModule` or `AppModule` providing an exported service).
- [x] 3.3 Create `@OnEvent('payment.created') handlePaymentCreatedEvent(event: PaymentCreatedEvent)` method.
- [x] 3.4 Inside the handler: find primary parent associated with the student, generate semantic title/body, and call `NotificationsService.createNotification` for that parent's user ID.
- [x] 3.5 Write unit tests for `NotificationListeners`.

## 4. E2E Verification

- [x] 4.1 Create an E2E test verifying that a POST to `/api/payments` correctly results in a new notification accessible via GET `/api/notifications` by the relevant parent user.
