# Proposal: Notification Resilience Hardening

## 1. Goal
Memperkuat keandalan pipeline notifikasi saat volume dan kegagalan meningkat, memastikan pengiriman rute gagal (WA/Email) ditangani tanpa membebani sistem utama.

## 2. Scope & Boundaries
- **In Scope:** 
  - Retry mechanism berbasis status pengiriman tertunda/gagal menggunakan database scheduler.
  - Idempotent event processing untuk menghindari duplikasi trigger notifikasi.
  - Tracking status dan error detail pada tabel notifikasi.
- **Out of Scope:** 
  - Fitur UI Dead-letter dashboard.
  - Multi-provider failover.

## 3. Context & Dependencies
- **Dependencies:** `personal-notification-center`, `event-driven-personal-notification-triggers`
- **Reference:** `docs/prd-si-keuangan-sekolah.md` (Reliability - Retry mechanism & Idempotent event processing)

## 4. Key Decisions & Risks
- **Decisions:** 
  - Akan menambahkan `retryCount` (max 3 retry) dan `lastError` pada tabel Notification.
  - Scheduled Jobs NestJS akan memeriksa failed notifications dan mengulanginya.
  - Idempotency menggunakan pengecekan unik berdasarkan gabungan event dan source ID sebelum membuat row notifikasi baru.
- **Risks:** 
  - Adanya race condition ketika retry berjalan; akan dicegah melalui row / query limits atau simple lock mechanisms jika perlu.
