# Runbook Deploy: Perbaikan PPDB dan Handoff PPDB → KSS

Dokumen ini mencakup semua perubahan PPDB (poin 1–7) karena env, migrasi dan urutan deploy-nya saling bergantung. Semua migrasi aman dijalankan lebih dari sekali.

## 1. Branch dan urutan merge

Branch di tiap repo bertumpuk; merge dari atas ke bawah (atau set base PR ke branch sebelumnya).

| Repo | Urutan branch |
|---|---|
| `iqrolife-backend` | `fix/ppdb-access-control` → `fix/ppdb-password-setup` → `fix/ppdb-status-rules` → `feat/ppdb-server-pricing` → `feat/ppdb-kss-handoff` → `fix/users-activation-link` |
| `iqrolife` | `fix/ppdb-access-control` → `fix/ppdb-password-setup` → `fix/ppdb-status-rules` → `feat/ppdb-server-pricing` → `feat/ppdb-kss-handoff` → `fix/users-activation-link` |
| `iqrolife-notification-service` | `fix/ppdb-access-control` → `fix/ppdb-password-setup` → `fix/users-activation-link` |
| `kss-backend` | `feat/ppdb-enrollment-intake` |
| `kss-frontend` | `feat/ppdb-class-mappings` |
| ERP (root) | `docker-compose.yml` dan `.env.production.example` (belum di-commit, ada perubahan lain di file yang sama); OpenSpec di `feat/ppdb-kss-enrollment-handoff-spec` |

## 2. Sebelum deploy

1. **Cabut token GitHub yang tertanam di URL remote** `iqrolife-notification-service` dan `kss-backend` (Settings → Developer settings → Tokens), lalu ganti remote ke SSH.
2. **Cek akun non-parent yang tidak dikenal** (endpoint register sebelumnya menerima `role` bebas):
   ```sql
   -- db_iqrolife
   SELECT id, email, role, created_at FROM users WHERE role <> 'parent' ORDER BY created_at DESC;
   ```
3. **Cek status lama di luar aturan baru** (staff tetap bisa memindahkannya, parent tidak bisa mengedit formulir sampai diperbaiki):
   ```sql
   -- db_iqrolife
   SELECT 'registrations' AS tbl, status, COUNT(*) FROM registrations
   WHERE status NOT IN ('pending','reviewed','approved','rejected') GROUP BY status
   UNION ALL
   SELECT 'formulir_pendaftaran', status, COUNT(*) FROM formulir_pendaftaran
   WHERE status NOT IN ('pending','submitted','edit_required','reviewed','accepted','rejected') GROUP BY status;
   ```

## 3. Secret dan env

Isi di `.env` root (dibaca docker-compose). Buat nilai baru dengan `openssl rand -hex 32`; jangan pakai ulang `iqrolife.id`.

| Variabel root `.env` | Dipakai oleh | Wajib |
|---|---|---|
| `NOTIFICATION_API_KEY` | `iqrolife-notif` (`NOTIFICATION_API_KEY`), `iqrolife-web` (`EMAIL_SERVICE_API_KEY`), `iqrolife-backend` (`NOTIFICATION_API_KEY`) | Ya — `docker compose` berhenti bila kosong |
| `PPDB_INTEGRATION_API_KEY` | `kss-backend` (`PPDB_INTEGRATION_API_KEY`), `iqrolife-backend` (`KSS_INTEGRATION_API_KEY`) | Tidak — kosong berarti handoff ke KSS mati (lihat §7) |

Nilai tetap yang sudah ada di `docker-compose.yml` untuk `iqrolife-backend`: `NOTIFICATION_SERVICE_URL=http://iqrolife-notif:3000`, `APP_URL=https://iqrolife.id`, `KSS_API_URL=http://kss-backend:3000/api`.

Untuk menjalankan di luar docker, contoh nilai ada di `.env.example` masing-masing repo.

## 4. Migrasi database

Jalankan sebelum container baru dinyalakan.
Ganti `-U postgres` dengan nilai `POSTGRES_USER` bila di `.env` root diubah.

```bash
# db_iqrolife — harga & kupon (poin 6), lalu tabel handoff (poin 7)
docker exec -i iqrolife-db psql -v ON_ERROR_STOP=1 -U postgres -d db_iqrolife < iqrolife-backend/src/migrations/003_add_registration_pricing.sql
docker exec -i iqrolife-db psql -v ON_ERROR_STOP=1 -U postgres -d db_iqrolife < iqrolife-backend/src/migrations/004_add_kss_handoffs.sql

# db_kss — tabel intake dan pemetaan kelas (juga dicatat di tabel migrations TypeORM)
docker exec -i iqrolife-db psql -v ON_ERROR_STOP=1 -U postgres -d db_kss < kss-backend/sql/1800000000022-create-ppdb-integration-tables.sql
```

Setelah notification service baru menyala, masukkan template email `account-setup` dan `account-activation`:

```bash
docker exec iqrolife-notif npm run seed
```

## 5. Urutan deploy

`iqrolife-notif`, `iqrolife-backend` dan `iqrolife-web` harus naik bersamaan: key notifikasi berubah di ketiganya sekaligus.

1. Migrasi §4 (kecuali seed).
2. `docker compose up -d --build iqrolife-notif iqrolife-backend iqrolife-web` lalu seed template.
3. `docker compose up -d --build kss-backend kss-frontend`.
4. Login KSS sebagai superadmin → menu **Pemetaan Kelas PPDB** → petakan setiap level PPDB (mis. `KSS A`, `KSS B`, `KSS C`) untuk tahun ajaran berjalan. Nama tahun ajaran di KSS harus sama persis dengan PPDB (mis. `2026/2027`).
5. Isi `PPDB_INTEGRATION_API_KEY`, lalu `docker compose up -d kss-backend iqrolife-backend`.
6. **Backfill:** di PPDB → Formulir Review, klik **Kirim ke KSS** pada setiap formulir berstatus *Diterima* yang bertanda "Belum dikirim ke KSS".

## 6. Verifikasi setelah deploy

- [ ] Akun parent tidak bisa me-review/menghapus registrasi (403) dan tidak bisa membuka formulir anak lain (404).
- [ ] `POST /api/emails/send` tanpa login → 401.
- [ ] "Lupa password" mengirim email dari backend; respons tidak berisi token.
- [ ] Admin membuat user dari registrasi `approved` → orang tua menerima email *Aktivasi Akun Dashboard Iqrolife* (tanpa password).
- [ ] Superadmin menambah user di halaman **Users** → user menerima email *Aktivasi Akun Dashboard Iqrolife* berisi link buat password; akun non-superadmin mendapat 403 di `/api/users`.
- [ ] Form pendaftaran menampilkan biaya dari Settings dan potongan kupon yang benar; kupon tidak valid menampilkan alasannya.
- [ ] Menerima formulir yang sudah direview → pesan "…sudah dikirim ke KSS (NIS …)", siswa dan orang tua muncul di KSS, orang tua menerima link aktivasi KSS.
- [ ] Level tanpa pemetaan → formulir tetap diterima, status KSS "Gagal dikirim ke KSS" dengan alasan `PPDB_CLASS_MAPPING_MISSING`; setelah dipetakan, **Kirim ulang ke KSS** berhasil.

## 7. Rollback

- **Matikan handoff ke KSS saja:** kosongkan `PPDB_INTEGRATION_API_KEY` dan restart `kss-backend` + `iqrolife-backend`. Penerimaan formulir tetap jalan; handoff tercatat gagal dengan alasan dan bisa dikirim ulang nanti.
- **Kembalikan aplikasi:** deploy ulang image sebelumnya. Kolom dan tabel baru (`original_amount`, `discount_amount`, `expected_amount`, `ppdb_kss_handoffs`, `ppdb_enrollments`, `ppdb_class_mappings`) tidak mengganggu versi lama dan boleh dibiarkan.
- **Catatan:** token reset password kini disimpan sebagai hash; link reset yang dibuat sebelum deploy tidak berlaku lagi (maks. 1 jam).
