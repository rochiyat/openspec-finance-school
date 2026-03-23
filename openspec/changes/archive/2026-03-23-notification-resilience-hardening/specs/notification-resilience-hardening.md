# Spec: Notification Resilience Hardening

## Background
Sistem notifikasi memerlukan keandalan tinggi. Sesuai arsitektur *event-driven* pada PRD, ketika volume event meningkat, third-party provider (seperti Email/WA) bisa saja mengalami throttling atau downtime sesaat. Kita akan mengimplementasikan retry pattern secara otomatis tanpa duplikasi.

## Requirements

### Requirement: Idempotent Event Processing
- Listener (event trigger) harus mengecek apakah notifikasi dari suatu `source_event` (contoh: ID pembayaran) sudah diproses sebelumnya dan ada di database.
- Jika sudah ada (dan berstatus selain gagal yang bisa diretry), pembuatan notifikasi harus dilewati agar user tidak menerima SPAM notifikasi serupa.

### Requirement: Failure Tracking & Retry Counting
- Model `Notification` harus mendukung pelacakan: 
  - `retryCount` (angka retry, default `0`).
  - `lastError` (menyimpan pesan error provider terakhir, nullable).
- Status pengiriman notifikasi harus mendukung representasi kegagalan, misalnya `FAILED` atau `PENDING_RETRY`.

### Requirement: Retry Mechanism
- Maksimal retry `3` kali.
- Dispatcher harus catch error. Saat gagal: naikkan `retryCount`, isi `lastError`, dan set status ke `FAILED`.
- Sebuah scheduler otomatis (contoh cron) akan secara periodik menarik row `FAILED` dengan `retryCount < 3` lalu mengirimkannya ulang.
- Jika sudah 3x gagal, notifikasi dibiarkan `FAILED`.

## Technical Design

### Data Schema Changes
- Tambah field `retry_count` `int` default 0.
- Tambah field `last_error` `text` nullable.

### Logic Flow
#### Flow: Normal Error
- Event "PAYMENT_DONE" -> Notification dibuat (PENDING).
- Proses send WA -> Timeout -> Catch (error).
- Update status "FAILED", retry_count "1", last_error "Timeout from Fonnte API".

#### Flow: Retry Schedule
- Cron runs (setiap 5/15 menit).
- Select dari DB -> WHERE status = 'FAILED' AND retry_count < 3.
- Coba resend -> Sukses -> Update status "SENT".
