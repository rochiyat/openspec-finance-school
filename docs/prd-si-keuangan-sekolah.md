# PRD — Sistem Informasi Keuangan Sekolah

## 1. Ringkasan Produk

Sistem Informasi Keuangan Sekolah adalah aplikasi web untuk mengelola seluruh proses administrasi keuangan sekolah, mulai dari pembayaran uang masuk, SPP, uang tahunan, cicilan, pencatatan tagihan, notifikasi ke orang tua, hingga dashboard operasional untuk guru, staf keuangan, dan superadmin.

Sistem ini dirancang agar:

- Mengurangi pencatatan manual
- Mempermudah monitoring pembayaran siswa
- Mengotomasi notifikasi ke orang tua
- Mendukung pengembangan menggunakan **AI Agent**

---

# 2. Tech Stack

## Frontend
- Vite
- React
- Tailwind CSS (disarankan)

## Backend
- NestJS

## Database
- PostgreSQL

## ORM
- TypeORM

## Integrasi
- Email: Gmail
- WhatsApp: Fonnte

---

# 3. User Roles

## Superadmin
Hak akses:

- Mengelola seluruh konfigurasi sistem
- Mengelola user dan role
- Mengelola jenis tagihan
- Mengelola template notifikasi
- Mengakses dashboard global
- Mengirim notifikasi global

---

## Finance (Staf Keuangan)

Hak akses:

- Membuat tagihan
- Mengelola cicilan
- Mencatat pembayaran
- Mengirim notifikasi personal
- Melihat laporan keuangan

---

## Guru

Hak akses:

- Melihat status pembayaran siswa di kelas
- Melihat notifikasi terkait administrasi

Guru **tidak memiliki akses perubahan transaksi keuangan**

---

## Orang Tua

Hak akses:

- Melihat tagihan anak
- Melihat riwayat pembayaran
- Menerima notifikasi email dan WhatsApp

---

# 4. Domain Model

## Student

```text
Student
- id
- nis
- full_name
- gender
- class_id
- academic_year_id
- status_active
- created_at
- updated_at
```

---

## Parent

```text
Parent
- id
- user_id
- full_name
- phone
- email
- address
```

---

## StudentParentMap

Mapping siswa ke orang tua

Relasi:

```text
Many Students -> One Parent
```

```text
StudentParentMap
- id
- student_id
- parent_id
- is_primary
```

Catatan:

- 1 parent dapat memiliki banyak anak
- 1 siswa minimal memiliki 1 parent utama

---

## Class

```text
Class
- id
- name
- homeroom_teacher_id
- academic_year_id
```

---

## AcademicYear

```text
AcademicYear
- id
- name
- start_date
- end_date
- is_active
```

---

# 5. Jenis Tagihan

Master jenis tagihan:

```text
BillingType
- id
- code
- name
- is_installment_allowed
- recurrence_type
```

Jenis utama:

| Code | Nama |
|-----|------|
| UANG_MASUK | Biaya pendaftaran |
| SPP | Bulanan |
| UANG_TAHUNAN | Tahunan |

---

# 6. Billing (Tagihan)

```text
Billing
- id
- student_id
- billing_type_id
- title
- total_amount
- due_date
- installment_allowed
- status
- created_by
- created_at
```

Status:

```text
UNPAID
PARTIALLY_PAID
PAID
OVERDUE
```

---

# 7. Cicilan

## InstallmentPlan

```text
InstallmentPlan
- id
- billing_id
- total_installments
- installment_amount
- start_date
```

---

## InstallmentItem

```text
InstallmentItem
- id
- installment_plan_id
- installment_no
- due_date
- amount
- status
```

Status:

```text
UNPAID
PAID
OVERDUE
```

---

# 8. Payment

Transaksi pembayaran

```text
Payment
- id
- payment_code
- student_id
- billing_id
- installment_item_id
- payment_date
- amount_paid
- payment_method
- reference_no
- created_by
```

Rules:

- pembayaran tidak boleh melebihi sisa tagihan
- jika total bayar = total tagihan -> status PAID
- jika sebagian -> PARTIALLY_PAID

---

# 9. Notification System

Sistem notifikasi harus **AI Friendly**.

Semua notifikasi berbasis **event driven architecture**.

---

# 10. Notification Entity

```text
Notification
- id
- type
- scope
- title
- message
- recipient_user_id
- recipient_parent_id
- channel
- status
- scheduled_at
- sent_at
- source_event
- metadata (jsonb)
```

---

## Notification Scope

### Personal

Contoh:

- Pengingat SPP anak
- Konfirmasi pembayaran
- Pengingat cicilan

---

### Global

Contoh:

- Pengumuman pembayaran tahunan
- Informasi perubahan biaya

---

# 11. Notification Channels

## Email

Provider:

```text
Gmail SMTP
```

Support:

- subject
- html body

---

## WhatsApp

Provider:

```text
Fonnte API
```

Digunakan untuk:

- reminder pembayaran
- konfirmasi pembayaran

---

# 12. Event Driven Notification

Event domain:

```text
billing.created
billing.updated
billing.due_soon
billing.overdue
payment.created
payment.confirmed
installment.created
installment.due_soon
installment.overdue
notification.global.created
```

---

# 13. Event Payload Standard

Contoh payload:

```json
{
  "event_name": "payment.confirmed",
  "student_id": "uuid",
  "parent_id": "uuid",
  "billing_id": "uuid",
  "payment_id": "uuid",
  "channels": ["EMAIL", "WHATSAPP"],
  "context": {
    "student_name": "Budi",
    "parent_name": "Ibu Sari",
    "billing_title": "SPP Maret",
    "amount_paid": 500000,
    "remaining_amount": 0,
    "due_date": "2026-03-20"
  }
}
```

---

# 14. Notification Template

```text
NotificationTemplate
- id
- code
- name
- channel
- subject
- content
- variables
```

---

## Template Variables

```text
{{parent_name}}
{{student_name}}
{{billing_title}}
{{amount_due}}
{{amount_paid}}
{{remaining_amount}}
{{due_date}}
{{payment_date}}
{{school_name}}
```

---

# 15. Dashboard

## Guru Dashboard

Menampilkan:

- daftar siswa di kelas
- status pembayaran
- siswa menunggak

---

## Finance Dashboard

Menampilkan:

- total tagihan
- total pembayaran masuk
- outstanding receivable
- siswa menunggak
- cicilan aktif

---

## Superadmin Dashboard

Menampilkan:

- statistik pembayaran
- statistik notifikasi
- laporan global

---

# 16. Backend Module Structure (NestJS)

```text
src/modules

auth
users
roles
students
parents
student-parent-maps
classes
academic-years
billing-types
billings
installments
payments
notifications
notification-templates
dashboard
audit-logs
```

---

# 17. Notification Services

```text
notification-dispatcher.service.ts
template-renderer.service.ts
email-adapter.service.ts
whatsapp-adapter.service.ts
```

---

# 18. Frontend Pages

```text
Login
Dashboard Guru
Dashboard Keuangan
Dashboard Superadmin
Student Management
Parent Management
Billing Management
Installment Management
Payment Entry
Notification Center
Notification Templates
Reports
Settings
```

---

# 19. API Endpoints

## Auth

```text
POST /auth/login
GET /auth/me
```

---

## Students

```text
GET /students
POST /students
GET /students/:id
PATCH /students/:id
```

---

## Parents

```text
GET /parents
POST /parents
GET /parents/:id
```

---

## Student Parent Mapping

```text
POST /student-parent-maps
GET /students/:id/parents
GET /parents/:id/students
```

---

## Billings

```text
GET /billings
POST /billings
POST /billings/bulk-create
GET /billings/:id
```

---

## Installments

```text
POST /installments/plans
GET /installments/plans/:id
```

---

## Payments

```text
GET /payments
POST /payments
GET /payments/:id
```

---

## Notifications

```text
GET /notifications
POST /notifications/personal
POST /notifications/global
POST /notifications/:id/send
```

---

## Dashboard

```text
GET /dashboard/teacher
GET /dashboard/finance
GET /dashboard/superadmin
```

---

# 20. Business Rules

### Pembayaran

```text
amount_paid <= remaining_amount
```

Status billing:

```text
0 = UNPAID
>0 & < total = PARTIALLY_PAID
= total = PAID
```

---

### Cicilan

- cicilan hanya boleh jika billing_type mengizinkan
- semua cicilan lunas -> billing lunas

---

### Mapping Parent

- satu parent dapat memiliki banyak siswa
- satu siswa minimal memiliki satu parent utama

---

# 21. Non Functional Requirements

### Performance

- Dashboard load < 3 detik
- Pagination pada semua list API

---

### Security

- Password hashing
- Role based access
- Input validation
- Audit log transaksi

---

### Reliability

- Retry mechanism untuk notifikasi
- Idempotent event processing

---

# 22. MVP Scope

### Phase 1

- Auth & Role
- Master Data
- Billing
- Cicilan
- Payment
- Personal Notification
- Dashboard

---

### Phase 2

- Global Notification
- Reminder Scheduler
- Report Export
- Audit Log

---

# 23. Definition of Done

Fitur dianggap selesai jika:

- API tersedia di Swagger
- Validasi backend lengkap
- UI dasar tersedia
- Role access sesuai
- Audit log aktif
- Notifikasi tercatat statusnya
- Error handling tersedia
