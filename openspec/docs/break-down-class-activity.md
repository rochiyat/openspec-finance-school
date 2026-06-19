# Breakdown — Class Activity Capabilities

Berikut urutan capability yang direkomendasikan, dikelompokkan berdasarkan prioritas dari PRD Class Activity. Setiap capability dirancang untuk bisa menjadi satu OpenSpec change.

---

## Phase 1 — Prioritas Biru (Sebelum POG)

1. `education-focus-management`
   - goal: menyediakan master data fokus pendidikan dan checklist yang dapat dikonfigurasi oleh admin.
   - scope: CRUD `EducationFocus`, CRUD `FocusChecklist`, seed data 4 fokus default, admin UI management.
   - dependencies: `auth-session-access`, `user-role-administration`
   - acceptance criteria: admin dapat menambah/edit/hapus fokus pendidikan; checklist items muncul dinamis berdasarkan fokus; display_order berfungsi; soft delete tersedia; seed data tersedia saat deploy; API tersedia di Swagger.
   - out of scope: hierarki fokus multi-level, versioning checklist.

2. `activity-type-management`
   - goal: menyediakan master data jenis aktivitas harian yang dapat dikonfigurasi oleh admin.
   - scope: CRUD `ActivityType`, seed data 8 aktivitas default, admin UI management.
   - dependencies: `auth-session-access`, `user-role-administration`
   - acceptance criteria: admin dapat menambah/edit/hapus jenis aktivitas; display_order berfungsi; soft delete tersedia; seed data tersedia saat deploy; API tersedia di Swagger.
   - out of scope: jadwal aktivitas per kelas, durasi per aktivitas.

3. `evidence-media-upload`
   - goal: menyediakan infrastruktur upload dan manajemen file media via Cloudinary.
   - scope: service Cloudinary, endpoint upload, validasi file (tipe, ukuran), thumbnail generation, `EvidenceMedia` entity, polymorphic reference.
   - dependencies: `auth-session-access`
   - acceptance criteria: upload file foto/video/dokumen berfungsi; validasi ukuran max 10MB; validasi tipe file (JPG, PNG, MP4, PDF); file tersimpan di Cloudinary; thumbnail URL tersedia; metadata file tersimpan di database; progress upload tersedia di frontend.
   - out of scope: batch upload, video transcoding, image editing.

4. `daily-class-report-core`
   - goal: memungkinkan guru/facilitator mencatat aktivitas harian kelas termasuk aktivitas, catatan, fokus pendidikan per siswa, dan evidence.
   - scope: `DailyClassReport`, `DailyActivitySelection`, `StudentDailyRecord`, `StudentFocusEntry`, `StudentFocusCheckResult`, form input harian (mobile-first), auto-populate daftar siswa dari kelas.
   - dependencies: `education-focus-management`, `activity-type-management`, `evidence-media-upload`, `academic-years-and-classes`, `student-directory`
   - acceptance criteria: guru dapat membuat laporan harian per kelas; unique constraint 1 laporan per kelas per hari; guru dapat memilih aktivitas yang dilakukan; guru dapat mencentang fokus per siswa; checklist muncul dinamis sesuai fokus terpilih; evidence text dan media bisa ditambahkan; laporan bisa DRAFT dan PUBLISHED; form mobile-friendly (< 5 menit input); auto-populate siswa dari data kelas.
   - out of scope: offline mode, multi-facilitator per laporan.

5. `parent-activity-view`
   - goal: memberi orang tua akses untuk melihat aktivitas harian anak termasuk evidence dan dokumentasi.
   - scope: endpoint `GET /students/:studentId/daily-activities`, timeline view di portal orang tua, filter per tanggal, tampilkan aktivitas + fokus + evidence + dokumentasi.
   - dependencies: `daily-class-report-core`, `student-parent-mapping`
   - acceptance criteria: orang tua hanya bisa melihat data anak yang terhubung via `StudentParentMap`; timeline menampilkan aktivitas per hari; detail hari menampilkan fokus, checklist, evidence, dan media; hanya laporan berstatus `PUBLISHED` yang tampil; mobile-friendly gallery untuk foto/video.
   - out of scope: push notification real-time, komentar per aktivitas.

6. `parent-evidence-submission`
   - goal: memungkinkan orang tua menambahkan evidence/informasi tambahan tentang anak dari rumah.
   - scope: `ParentEvidence` entity, form submit evidence + upload media, endpoint CRUD parent evidence.
   - dependencies: `evidence-media-upload`, `student-parent-mapping`
   - acceptance criteria: orang tua bisa submit evidence text dan upload foto; evidence terhubung ke student dan tanggal; orang tua hanya bisa submit untuk anak sendiri; evidence orang tua terpisah dari data guru; form mobile-friendly dengan upload kamera langsung.
   - out of scope: approval workflow oleh guru, threading/reply.

---

## Phase 2 — Prioritas Hijau (Maks September)

7. `student-report-generation`
   - goal: menyediakan fondasi generate report pencapaian siswa per kuarter/semester.
   - scope: `StudentReport` entity, `StudentReportPortfolio` entity, context builder yang mengumpulkan data dari fokus entries, checklist results, evidence, dan portofolio selama periode.
   - dependencies: `daily-class-report-core`, `parent-evidence-submission`
   - acceptance criteria: report bisa dibuat untuk periode 3 bulanan atau 6 bulanan; context builder mengumpulkan semua data relevan dari periode; report memiliki status DRAFT/REVIEW/PUBLISHED; portofolio/hasil karya bisa dilampirkan.
   - out of scope: auto-scheduling report generation, comparison report antar periode.

8. `ai-report-narration`
   - goal: mengintegrasikan Gemini REST API untuk generate narasi report pencapaian berdasarkan data yang terkumpul.
   - scope: `AIReportConfig` entity, service integrasi Gemini REST API (`generativelanguage.googleapis.com`), prompt template dengan konteks pendidikan fitrah & holistic Iqrolife, async generation dengan status polling.
   - dependencies: `student-report-generation`
   - acceptance criteria: AI generate narasi berdasarkan data checklist, evidence, dan portofolio; narasi sesuai konteks pedagogis Iqrolife (4 fokus pendidikan); panggilan ke Gemini via REST API langsung (bukan SDK); konfigurasi model, system prompt, dan parameter bisa diubah admin; proses generate async (10-30 detik) dengan status indicator; generated content bersifat editable.
   - out of scope: multi-provider (OpenAI dll), fine-tuning model, multi-language, real-time streaming response.

9. `report-edit-and-publish`
   - goal: memungkinkan guru edit narasi dan langsung publish report pencapaian.
   - scope: rich text editor untuk edit generated content, workflow DRAFT → PUBLISHED (tanpa tahap review terpisah), notifikasi ke orang tua saat publish.
   - dependencies: `ai-report-narration`, `personal-notification-center`
   - acceptance criteria: guru bisa mengedit narasi AI-generated; preview report tersedia; workflow status DRAFT → PUBLISHED berjalan langsung; notifikasi terkirim ke orang tua saat publish; template report bisa dikonfigurasi admin.
   - out of scope: multi-reviewer approval, versioning edits.

10. `report-pdf-download`
    - goal: menghasilkan file PDF report pencapaian yang bisa di-download orang tua.
    - scope: PDF generation dari report content, upload PDF ke Cloudinary, endpoint download, link di portal orang tua.
    - dependencies: `report-edit-and-publish`
    - acceptance criteria: PDF di-generate dari report content dengan template yang sudah ditentukan; PDF tersimpan di Cloudinary; orang tua bisa download PDF dari portal; report hanya bisa diakses jika status `PUBLISHED`; orang tua bisa pilih kuarter untuk download.
    - out of scope: custom PDF design editor, batch PDF generation.

11. `student-portfolio-collection`
    - goal: mengelola kumpulan karya/portofolio siswa yang disertakan dalam report pencapaian.
    - scope: CRUD `StudentReportPortfolio`, upload media, display order, integrasi dengan report generation.
    - dependencies: `student-report-generation`, `evidence-media-upload`
    - acceptance criteria: guru bisa menambah/mengurutkan portofolio items per report; portofolio mendukung image/video/document; portofolio muncul dalam PDF report; portofolio muncul di portal orang tua.
    - out of scope: portofolio sharing antar siswa, gallery publik.

---

## Phase 3 — Prioritas Ungu (Nice to Have, Paralel)

12. `academic-calendar-module`
    - goal: menyediakan kalender akademik yang bisa dikelola admin dan ditampilkan di portal guru & orang tua.
    - scope: CRUD `AcademicCalendar`, calendar grid view (admin), read-only calendar (guru & orang tua), filter per tahun ajaran & tipe event.
    - dependencies: `academic-years-and-classes`, `auth-session-access`
    - acceptance criteria: admin dapat mengelola event kalender; event terhubung ke tahun ajaran aktif; guru dan orang tua bisa melihat kalender (read-only); filter berdasarkan bulan, tipe event; calendar grid view responsive.
    - out of scope: sinkronisasi Google Calendar, recurring events otomatis.

13. `daily-report-notification`
    - goal: mengotomasi notifikasi ke orang tua saat laporan harian kelas dipublish.
    - scope: event `daily_report.published`, create notification per orang tua yang terhubung, kirim via Email/WhatsApp.
    - dependencies: `daily-class-report-core`, `personal-notification-center`, `event-driven-personal-notification-triggers`
    - acceptance criteria: notifikasi otomatis saat laporan dipublish; notifikasi dikirim ke semua orang tua siswa di kelas; channel email dan WhatsApp didukung; orang tua bisa langsung klik link ke portal.
    - out of scope: preferensi opt-out per parent, digest notification.

14. `parent-child-growth-tracking`
    - goal: memberikan visualisasi progress tumbuh kembang anak berdasarkan data 4 fokus pendidikan.
    - scope: agregasi data checklist per fokus per periode, chart/grafik progress, perbandingan antar periode.
    - dependencies: `daily-class-report-core`, `student-report-generation`
    - acceptance criteria: orang tua melihat progress per fokus pendidikan; visualisasi trend (naik/turun/stabil); perbandingan antar kuarter tersedia; data hanya dari laporan berstatus PUBLISHED.
    - out of scope: benchmark antar siswa, prediktif analytics.

15. `parent-feedback-channel`
    - goal: menyediakan jalur komunikasi dan feedback dari orang tua ke sekolah.
    - scope: link WhatsApp ke facilitator/wali kelas, form feedback sederhana, integrasi deep link WA.
    - dependencies: `student-parent-mapping`
    - acceptance criteria: orang tua bisa mengirim feedback; deep link WhatsApp berfungsi ke guru yang tepat; histori feedback tersimpan (jika via form).
    - out of scope: in-app chat, ticketing system, video call.

16. `facilitator-learning-space`
    - goal: menyediakan ruang belajar digital untuk guru (sharing, mentoring).
    - scope: TBD — butuh eksplorasi lebih lanjut. Mungkin berupa content management sederhana, forum, atau link ke resource eksternal.
    - dependencies: `auth-session-access`
    - acceptance criteria: TBD
    - out of scope: LMS penuh, video conferencing, certification.

17. `parent-learning-space`
    - goal: menyediakan ruang belajar digital untuk orang tua (sharing, mentoring).
    - scope: TBD — butuh eksplorasi lebih lanjut. Mungkin berupa content management sederhana, artikel, atau link ke resource eksternal.
    - dependencies: `auth-session-access`
    - acceptance criteria: TBD
    - out of scope: LMS penuh, community forum kompleks, marketplace.

---

## Urutan Implementasi yang Direkomendasikan

```
Phase 1 (Sebelum POG):
  [1] education-focus-management ─┐
  [2] activity-type-management ───┤
  [3] evidence-media-upload ──────┼──→ [4] daily-class-report-core ──→ [5] parent-activity-view
                                  │                                    [6] parent-evidence-submission
                                  │
Phase 2 (Maks September):         │
  [4] ────────────────────────────┼──→ [7] student-report-generation ──→ [8] ai-report-narration
  [6] ────────────────────────────┘                                      [9] report-edit-and-publish
                                                                         [10] report-pdf-download
                                       [7] ──→ [11] student-portfolio-collection

Phase 3 (Paralel):
  [12] academic-calendar-module (bisa dikerjakan kapan saja)
  [13] daily-report-notification (setelah [4])
  [14] parent-child-growth-tracking (setelah [7])
  [15] parent-feedback-channel (minimal)
  [16-17] learning spaces (TBD)
```
