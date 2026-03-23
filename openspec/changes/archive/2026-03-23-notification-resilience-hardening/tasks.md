# Tasks: Notification Resilience Hardening

## 1. Backend: Data Model Update
- [x] 1.1 Update entity model `Notification`: tambahkan kolom `retryCount` (integer, default 0), `lastError` (text, nullable).
- [x] 1.2 Pastikan enum status notifikasi mendukung `FAILED` (jika belum ada).
- [x] 1.3 Update/generate migration database untuk kolom-kolom baru tersebut.

## 2. Backend: Idempotency Validation
- [x] 2.1 Update listener/trigger di dalam `NotificationsService` atau module event listener. Saat memproses event, cek di table Notification berdasarkan `source_event` (ataupun referensi unik ID transaksi).
- [x] 2.2 Jika notifikasi untuk event tujuan sudah direkam, jangan buat record baru (mengamankan sistem dari duplicate events).

## 3. Backend: Error Handling and Resiliency
- [x] 3.1 Pada logic dispatcher / provider email & WA, gunakan `try-catch` saat mengeksekusi koneksi external.
- [x] 3.2 Pada tangkapan `catch`, set status ke `FAILED`, `lastError` diset dengan message error, increment `retryCount` + 1.
- [x] 3.3 Pastikan jika status sukses, diset `SENT`.

## 4. Backend: Scheduler
- [x] 4.1 Buat Service baru `NotificationRetryScheduler` dan pastikan module schedule NestJS terdaftar.
- [x] 4.2 Tambahkan cron decorator `@Cron(CronExpression.EVERY_10_MINUTES)` atau interval relevan.
- [x] 4.3 Di dalam cron function: Fetch row notifikasi yang `status === FAILED` dan `retryCount < 3`.
- [x] 4.4 Loop dan jalankan function `dispatcher` untuk row notifikasi tersebut secara aman.

## 5. Verification & Testing
- [x] 5.1 Implementasikan unit test untuk memverifikasi idempotency: mock bahwa event dieksekusi 2 kali dengan unique source yang sama. Hanya boleh 1 row yang terbuat.
- [x] 5.2 Implementasikan test untuk memastikan incrementing `retryCount` bekerja ketika pengiriman third party digantikan dengan error thrower.
- [x] 5.3 Implementasikan test untuk `NotificationRetryScheduler` (fetching limit `retryCount`).
