# Asesor API — Contract & Notes for Frontend

Semua endpoint Asesor wajib Bearer token + role `asesor`. Identitas asesor diambil otomatis dari JWT.

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Akun demo asesor:
- `account`: `demo_asesor_001`
- `password`: `demo123`
- email: `asesor.demo@lsp.id`
- t_users.id: 194330 / lsp275_users.id: 1428

---

## Status Implementasi Endpoint

| # | Metode | Endpoint | Status | Catatan |
|---|--------|----------|--------|---------|
| 1 | GET | `/api/asesor/dashboard` | ✅ Sudah ada (live) | Tidak diubah |
| 2 | GET | `/api/asesor/jadwal` | ✅ Sudah ada (live) | Tidak diubah |
| 3 | GET | `/api/asesor/jadwal/:id/detail` | ✅ Sudah ada (live) | Tidak diubah |
| 4 | GET | `/api/asesor/jadwal/:id/peserta` | ✅ Sudah ada (live) | Tidak diubah |
| 5 | GET | `/api/asesor/jadwal/:jadwal_id/peserta/:peserta_id` | ✅ Sudah ada (live) | Tidak diubah |
| 6 | GET | `/api/asesor/jadwal/:id/surat-tugas` | 🆕 DIPERBAIKI | Sebelumnya hardcode 404, sekarang ambil file dari DB |
| 7 | GET | `/api/asesor/laporan` | ✅ Sudah ada (live) | Tidak diubah |
| 8 | GET | `/api/asesor/laporan/:id` | 🆕 DIPERBAIKI | Field `ringkasan` (bukan kpi_pelaksanaan), field `nama_asesor` (bukan asesor), `dokumen` ambil dari DB |
| 9 | GET | `/api/asesor/skema-tuk` | ✅ Sudah ada (live) | Tidak diubah |
| 10 | POST | `/api/asesor/laporan/upload-lampiran` | ✅ Sudah ada (live) | Tidak diubah |
| 11 | POST | `/api/asesor/laporan` | ✅ Sudah ada (live) | Tidak diubah |
| 12 | GET | `/api/asesor/profile` | ✅ Sudah ada (live) | Tidak diubah |
| 13 | PUT | `/api/asesor/profile` | ✅ Sudah ada (live) | Tidak diubah |
| 14 | GET | `/api/asesor/honor` | 🆕 DIPERBAIKI | Response diperluas: status, metode_pembayaran, no_transfer, tanggal_pembayaran, jumlah_asesi, jenis_asesmen |
| 15 | GET | `/api/asesor/tiket` | 🆕 BARU | Pakai table `t_pesan` |
| 16 | GET | `/api/asesor/tiket/:id` | 🆕 BARU | Pakai table `t_pesan` |
| 17 | POST | `/api/asesor/tiket` | 🆕 BARU | Pakai table `t_pesan` |
| 18 | POST | `/api/asesor/tiket/:id/reply` | 🆕 BARU | Pakai table `t_pesan` |

**Ringkasan:**
- Endpoint 1-5, 7, 9-13: **sudah ada sebelumnya**, tidak diubah. FE bisa langsung pakai.
- Endpoint 6, 8, 14: **diperbaiki** — response berubah, FE perlu update parser.
- Endpoint 15-18: **baru ditambahkan** — sebelumnya FE pakai local state/mock, sekarang ada backend.

---

## 1. Dashboard — `GET /api/asesor/dashboard`

**(Sudah ada, tidak diubah)**

Query opsional `tanggal` (format `YYYY-MM-DD`). Default: hari ini.

```json
{
  "status": "success",
  "message": "Asesor dashboard data retrieved successfully",
  "data": {
    "summary": {
      "menunggu_verifikasi": 1,
      "asesmen_berlangsung": 0,
      "asesmen_selesai": 12,
      "menunggu_penugasan": 2
    },
    "alert_banner": {
      "has_alert": true,
      "title": "Verifikasi laporan tertunda",
      "subtitle": "Anda memiliki 1 laporan yang menunggu verifikasi"
    },
    "jadwal_hari_ini": [
      { "id_jadwal": 11152, "skema": "...", "tanggal": "2026-04-27", "waktu": "08:00", "tuk": "...", "status": "1" }
    ],
    "tugas_prioritas": [
      { "id_tugas": 28054, "title": "...", "subtitle": "...", "type": "menunggu_verifikasi" }
    ]
  }
}
```

Backend notes:
- `summary` menghitung jumlah jadwal per `status_jadwal` dari `lsp275_mapping_asesor` + `lsp275_jadual_asesmen`.
- `alert_banner` aktif jika `menunggu_verifikasi > 0`.

---

## 2. Daftar Jadwal — `GET /api/asesor/jadwal`

**(Sudah ada, tidak diubah)**

Query `status_jadwal` opsional, comma-separated. Nilai valid: `0,1,2,4`. Default `0`.

```json
{
  "status": "success",
  "message": "Asesor schedules retrieved successfully",
  "data": [
    {
      "id": 11152,
      "nama_jadwal": "Sertifikasi Junior Web Developer",
      "tanggal": "2026-07-24",
      "tanggal_akhir": "2026-07-27",
      "status_jadwal": "0",
      "tuk": "LPP Cahaya Borneo",
      "jumlah_peserta": 54,
      "asesor": ["Eko Setiabudi", "Andi Wijaya"]
    }
  ],
  "count": 1
}
```

---

## 3. Detail Jadwal — `GET /api/asesor/jadwal/:id/detail`

**(Sudah ada, tidak diubah)**

```json
{
  "status": "success",
  "message": "Assessor schedule detail retrieved successfully",
  "data": {
    "status_label": "Menunggu",
    "tanggal_asesmen": "2026-07-24",
    "waktu_asesmen": "09:00 - 12:00 WIB",
    "lokasi_asesmen": "Gedung A Lantai 2",
    "jumlah_peserta": 54,
    "lead_asesor": "",
    "nama_jadwal": "Sertifikasi Junior Web Developer",
    "tuk": "LPP Cahaya Borneo",
    "asesor": ["Eko Setiabudi", "Andi Wijaya"]
  }
}
```

Backend notes:
- `asesor` adalah array string nama (bukan array objek).
- `lead_asesor` saat ini kosong (DB tidak punya kolom lead).

---

## 4. Daftar Peserta — `GET /api/asesor/jadwal/:id/peserta`

**(Sudah ada, tidak diubah)**

```json
{
  "status": "success",
  "message": "Participants list retrieved successfully",
  "data": [
    { "id": 101, "nama_lengkap": "Andi Pratama", "hasil_rekomendasi": "K" }
  ],
  "meta": {
    "jadwal_id": 11152,
    "total_asesi": 3,
    "jumlah_kompeten": 1,
    "jumlah_belum_kompeten": 1,
    "jumlah_belum_dinilai": 1
  }
}
```

`hasil_rekomendasi`: `"K"` (Kompeten), `"BK"` (Belum Kompeten), `"-"` (belum dinilai).

---

## 5. Detail Peserta — `GET /api/asesor/jadwal/:jadwal_id/peserta/:peserta_id`

**(Sudah ada, tidak diubah)**

```json
{
  "status": "success",
  "message": "Participant detail retrieved successfully",
  "data": {
    "peserta_id": 101,
    "no_peserta": "PES-2026-001",
    "nama_lengkap": "Andi Pratama",
    "nik": "6253748567382",
    "tempat_lahir": "Yogyakarta",
    "tanggal_lahir": "1998-05-10",
    "skema_sertifikat": "UI/UX Design",
    "institusi": "LPP Jigja",
    "email": "andipratama@gmail.com",
    "no_telepon": "085678736521",
    "status_kelengkapan": {
      "portofolio": "Lengkap",
      "dokumen_pendukung": "Belum Lengkap",
      "persyaratan": "Belum Lengkap"
    },
    "status_assessment": {
      "kehadiran": "Belum tersedia",
      "tugas_asesmen": "Belum Dinilai",
      "laporan": "Belum Dibuat",
      "rekaman": "Belum Diunggah"
    }
  }
}
```

Backend notes:
- `kehadiran` saat ini `"Belum tersedia"` (DB tidak track kehadiran per asesi).
- `tugas_asesmen`: dari `rekomendasi_asesor` (0=Belum Dinilai, 1=Kompeten, 2=Belum Kompeten).

---

## 6. Surat Tugas — `GET /api/asesor/jadwal/:id/surat-tugas`

**(🆕 DIPERBAIKI — sebelumnya hardcode 404)**

```json
{
  "status": "success",
  "message": "Surat tugas retrieved successfully",
  "data": {
    "file_url": "https://drive.google.com/drive/folders/1DMyfskWovLbKHMXLXcRgi3QNWhLL7RwV",
    "file_name": "1DMyfskWovLbKHMXLXcRgi3QNWhLL7RwV"
  }
}
```

Jika tidak ada file: `404` dengan `{ "status": "error", "message": "Surat tugas file is not available for this schedule" }`.

Backend notes:
- **Sumber file** (urutan prioritas, ambil yang pertama non-kosong):
  1. `lsp275_jadual_asesmen.link_ba`
  2. `lsp275_jadual_asesmen.dokumen_berita_acara`
  3. `lsp275_jadual_asesmen.file_jadual`
  4. `lsp275_jadual_asesmen.sk_lisensi`
- Nilai `"0"`, `"undefined"`, `"null"`, `""` dianggap kosong → skip ke sumber berikutnya.
- `file_name` diambil dari basename URL (segmen terakhir setelah `/`), **bukan** hardcode.
- Banyak jadwal tidak punya link file sama sekali → return 404.

---

## 7. Daftar Laporan — `GET /api/asesor/laporan`

**(Sudah ada, tidak diubah)**

```json
{
  "status": "success",
  "message": "Riwayat laporan tugas berhasil diambil",
  "data": [
    {
      "id": 8810,
      "kode_laporan": "LAP-2026-0724",
      "skema_sertifikasi": "Design UI/UX",
      "tanggal_pelaksanaan": "2026-07-24",
      "tuk": "LPP Cahaya Borneo",
      "nama_asesor": "Muhammad Hanafi",
      "status": "Terkonfirmasi"
    }
  ]
}
```

Backend notes:
- `id` = `lsp275_mapping_asesor.id`.
- `status`: `"Terkonfirmasi"` jika `ak06` tidak kosong, selain itu `"Draft"`.
- Hanya jadwal dengan `status_jadwal IN ('1','4')`.

---

## 8. Detail Laporan — `GET /api/asesor/laporan/:id`

**(🆕 DIPERBAIKI — response berubah)**

```json
{
  "status": "success",
  "message": "Detail laporan tugas berhasil diambil",
  "data": {
    "id": 8810,
    "kode_laporan": "LAP-2026-0724",
    "status": "Terkonfirmasi",
    "nama_asesor": "Muhammad Hanafi",
    "skema_sertifikasi": "Design UI/UX",
    "tanggal_pelaksanaan": "24 Juli 2026",
    "link_dokumentasi": "https://drive.google.com/...",
    "catatan": "Evaluasi pelaksanaan berjalan kondusif.",
    "ringkasan": {
      "total_peserta": 10,
      "hadir": 10,
      "absen": 0,
      "kompeten": 7,
      "belum_kompeten": 1
    },
    "dokumen": {
      "surat_tugas_name": "1DMyfskWovLbKHMXLXcRgi3QNWhLL7RwV",
      "surat_tugas_url": "https://drive.google.com/drive/folders/1DMyfskWovLbKHMXLXcRgi3QNWhLL7RwV"
    },
    "daftar_asesi_dinilai": [
      { "nama": "Ayu Putri Sri", "nim": "0897556789", "kehadiran": "Hadir", "penilaian": "K" },
      { "nama": "Bayu Nugrahan", "nim": "09769990862", "kehadiran": "Hadir", "penilaian": "TK" }
    ],
    "lampiran_pendukung": []
  }
}
```

⚠️ **Perubahan dari draft awal FE (yang lama → yang baru):**
- ~~`kpi_pelaksanaan`~~ → `ringkasan`
- ~~`total_asesi`~~ → `total_peserta`
- ~~`tidak_kompeten`~~ → `belum_kompeten`
- ~~`asesor`~~ → `nama_asesor`
- ~~`dokumen.surat_tugas_name: "Surat tugas.pdf"` (hardcode)~~ → `file_name` diambil dari basename URL file di DB
- ~~`dokumen.surat_tugas_url: ""` (kosong)~~ → ambil dari `link_ba`/`dokumen_berita_acara`/`file_jadual`/`sk_lisensi`

Backend notes:
- `dokumen.surat_tugas_url` dan `surat_tugas_name` sama logikanya dengan endpoint surat-tugas (prioritas: link_ba → dokumen_berita_acara → file_jadual → sk_lisensi).
- `surat_tugas_name` = basename URL (segmen terakhir setelah `/`). Jika kosong, kedua field kosong.
- `ringkasan.hadir` = `total_peserta` (asumsi semua hadir, DB tidak track absensi).
- `ringkasan.absen` selalu `0`.
- `daftar_asesi_dinilai.kehadiran` saat ini selalu `"Hadir"`.
- `lampiran_pendukung` saat ini `[]` (tidak dipersist di mapping_asesor).

---

## 9. Skema & TUK — `GET /api/asesor/skema-tuk`

**(Sudah ada, tidak diubah)**

```json
{
  "status": "success",
  "message": "Daftar skema sertifikasi & TUK berhasil diambil",
  "data": [
    { "id": 1, "nama_skema": "Desaign UI/Ux", "tuk": "LPP Cahaya Borneo" }
  ]
}
```

---

## 10. Upload Lampiran — `POST /api/asesor/laporan/upload-lampiran`

**(Sudah ada, tidak diubah)**

Content-Type: `multipart/form-data`. Field `file`. Max 5MB. Ekstensi: `.pdf,.png,.jpg,.jpeg`.

```json
{
  "status": "success",
  "message": "Upload File Berhasil",
  "data": {
    "file_name": "Bukti_Pendukung_1.pdf",
    "file_url": "http://host/storage/attachments/uuid.pdf"
  }
}
```

---

## 11. Submit Laporan — `POST /api/asesor/laporan`

**(Sudah ada, tidak diubah)**

Content-Type: `application/json`.

```json
{
  "jadwal_id": 11152,
  "nama_asesor": "Muhammad Hanafi",
  "skema_id": 1,
  "tanggal_pelaksanaan": "2026-07-24",
  "surat_tugas_url": "https://...",
  "link_dokumentasi": "https://drive.google.com/...",
  "catatan": "Evaluasi pelaksanaan berjalan kondusif.",
  "daftar_peserta": [
    { "nim": "0897556789", "kehadiran": "Hadir", "is_kompeten": true },
    { "nim": "09769990862", "kehadiran": "Absen", "is_kompeten": false }
  ],
  "lampiran_pendukung": ["https://host/storage/attachments/temp.pdf"]
}
```

Response `201`:
```json
{
  "status": "success",
  "message": "Laporan tugas berhasil dibuat",
  "data": { "id": 8810, "kode_laporan": "LAP-2026-0724", "status": "Terkonfirmasi" }
}
```

Backend notes:
- Update `lsp275_mapping_asesor` (link_rekaman, rekomendasi_peningkatan, is_complete='1').
- `daftar_peserta.nim` dipetakan ke `no_registrasi` di `lsp275_asesi`/`lsp275_asesi_2024`.
- `lampiran_pendukung` dan `surat_tugas_url` tidak dipersist (tidak ada kolom).

---

## 12. Profil — `GET /api/asesor/profile`

**(Sudah ada, tidak diubah)**

```json
{
  "status": "success",
  "message": "Profil asesor berhasil diambil",
  "data": {
    "id_asesor": "MET.DEMO.000001.2026",
    "nama_lengkap": "Muhammad Hanafi",
    "status_aktif": "Aktif",
    "nik": "",
    "email": "muhammadhanafi_12@gmail.com",
    "no_telepon": "0858978655634",
    "foto_profil_url": "",
    "instansi": "Politeknik Negeri Sampit",
    "alamat": "Jl. Pramuka km 4,5 No 34"
  }
}
```

Backend notes:
- `nik` selalu kosong (DB tidak punya kolom nik untuk asesor).
- `id_asesor` = `no_reg`.

---

## 13. Update Profil — `PUT /api/asesor/profile`

**(Sudah ada, tidak diubah)**

```json
{
  "no_telepon": "0858978655634",
  "alamat": "Jl. Pramuka km 4,5 No 34",
  "instansi": "Politeknik Negeri Sampit",
  "foto_profil_url": "https://host/storage/profiles/hanafi.jpg"
}
```

Response 200 mengembalikan data terbaru. Semua field opsional — jika tidak dikirim, tidak diubah.

---

## 14. Honor — `GET /api/asesor/honor?periode=Juli+2026`

**(🆕 DIPERBAIKI — response diperluas)**

Query `periode` opsional format `NamaBulan Tahun` (contoh: `Juli 2026`). Jika kosong → semua periode + field tambahan `available_months`.

```json
{
  "status": "success",
  "message": "Daftar honor berhasil diambil",
  "data": {
    "periode": "Juli 2026",
    "total_honor": "Rp. 2.500.000",
    "jumlah_asesmen_selesai": "4 Asesmen selesai",
    "rincian": [
      {
        "id_detail": 501,
        "judul_asesmen": "Uji Kompetensi: Junior Web Programmer",
        "tanggal": "12 Juli 2026",
        "tuk": "Politeknik Sampit",
        "honor": "Rp. 625.000",
        "status": "Complete",
        "jumlah_asesmen": 1,
        "metode_pembayaran": "Transfer Bank",
        "tanggal_pembayaran": "12 Juli 2026",
        "no_transfer": "PAY-20260712-501",
        "jumlah_asesi": 12,
        "jenis_asesmen": "Asesmen Mandiri / Praktik"
      }
    ],
    "available_months": ["Juli 2026", "Juni 2026"]
  }
}
```

⚠️ **Field baru yang ditambahkan (sebelumnya tidak ada):**
- `status` (`"Complete"` / `"Menunggu"`)
- `jumlah_asesmen` (selalu `1` per rincian)
- `metode_pembayaran` (selalu `"Transfer Bank"`)
- `tanggal_pembayaran` (`"-"` jika belum bayar)
- `no_transfer` (`"-"` jika belum bayar, format `PAY-YYYYMMDD-{id_detail}` jika sudah)
- `jumlah_asesi` (dari `mapping_asesor.jumlah_asesi`)
- `jenis_asesmen` (dari enum `jenis_asesmen`, label Indonesia)
- `judul_asesmen` sekarang prefix `"Uji Kompetensi: "`
- `available_months` (hanya jika `periode` kosong)

Backend notes:
- `status`: dari `status_pembayaran_honor` ('1'=Complete, '0'=Menunggu).
- `metode_pembayaran`: selalu `"Transfer Bank"` (DB tidak punya kolom metode).
- `jumlah_asesmen`: selalu `1` (1 mapping = 1 asesmen).
- `tanggal_pembayaran`: pakai `tanggal` jadwal (DB tidak track tanggal real pembayaran).
- Source: `lsp275_mapping_asesor` JOIN `lsp275_jadual_asesmen` (filter `status_jadwal='1'`).

---

## 15. Daftar Tiket — `GET /api/asesor/tiket`

**(🆕 BARU — sebelumnya FE pakai local state/mock)**

```json
{
  "status": "success",
  "message": "Daftar tiket bantuan berhasil diambil",
  "data": [
    {
      "id": "TK-28495",
      "title": "Jadwal Tidak Dapat Dibuka",
      "date": "20 Juli 2026, 13:00",
      "category": "Jadwal",
      "status": "Proses",
      "messages": [
        { "sender": "Asesor", "time": "20 Juli 2026 13:00", "text": "Saya tidak bisa membuka detail jadwal..." },
        { "sender": "LSP Admin", "time": "20 Juli 2026 13:15", "text": "Halo Pak, mohon pastikan koneksi internet stabil..." }
      ]
    }
  ]
}
```

Backend notes:
- Source: `t_pesan` WHERE `parent_id=0` AND (`sender_id` OR `reciepent_id` = t_users.id dari JWT).
- `id` format `TK-{t_pesan.id}`.
- `sender`: `"Asesor"` jika sender_id = user login, `"LSP Admin"` jika bukan.
- `status`: selalu `"Proses"` (DB `status_ticket` enum hanya `0/1`, semua data existing = `1`).
- `category`: auto-detected dari `title` (keyword match: jadwal→Jadwal, surat→Surat Tugas, honor→Honor, akun/login→Akun, else→Lainnya).
- `messages` include parent message + semua reply (`parent_id=ticket.id`).

---

## 16. Detail Tiket — `GET /api/asesor/tiket/:id`

**(🆕 BARU)**

`:id` bisa format `TK-123` atau `123` (plain int).

```json
{
  "status": "success",
  "message": "Detail tiket bantuan berhasil diambil",
  "data": {
    "id": "TK-28495",
    "title": "Jadwal Tidak Dapat Dibuka",
    "date": "20 Juli 2026, 13:00",
    "category": "Jadwal",
    "status": "Proses",
    "messages": [
      { "sender": "Asesor", "time": "20 Juli 2026 13:00", "text": "..." },
      { "sender": "LSP Admin", "time": "20 Juli 2026 13:15", "text": "..." }
    ]
  }
}
```

---

## 17. Buat Tiket Baru — `POST /api/asesor/tiket`

**(🆕 BARU)**

Content-Type: `application/json`.

```json
{
  "nama_lengkap": "Muhammad Hanafi",
  "judul": "Jadwal Tidak Dapat Dibuka",
  "pesan": "Saya tidak bisa membuka detail jadwal asesmen...",
  "dokumentasi_url": "https://host/storage/attachments/screenshot.png"
}
```

Response `201`:
```json
{
  "status": "success",
  "message": "Tiket bantuan berhasil dibuat",
  "data": {
    "id": "TK-28496",
    "title": "Jadwal Tidak Dapat Dibuka",
    "category": "Jadwal",
    "status": "Proses",
    "date": "Hari ini"
  }
}
```

Backend notes:
- Insert ke `t_pesan`: `sender_id=user`, `reciepent_id=1` (admin), `parent_id=0`, `status_ticket='1'`.
- `nama_lengkap` opsional (ambil dari `t_users.nama_user` jika kosong).
- `dokumentasi_url` opsional (disimpan di `attachment`).
- `judul` dan `pesan` wajib.

---

## 18. Reply Tiket — `POST /api/asesor/tiket/:id/reply`

**(🆕 BARU)**

Content-Type: `application/json`.

```json
{ "text": "Baik, saya coba restart aplikasinya dahulu." }
```

Response `200`:
```json
{
  "status": "success",
  "message": "Tanggapan berhasil dikirim",
  "data": {
    "sender": "Asesor",
    "time": "Hari ini",
    "text": "Baik, saya coba restart aplikasinya dahulu."
  }
}
```

Backend notes:
- Insert ke `t_pesan`: `parent_id=:id`, `sender_id=user`, `reciepent_id` = lawan dari parent ticket.
- Verifikasi parent ticket milik user (sender/reciepent).

---

## Error Response (semua endpoint)

```json
{ "status": "error", "message": "Pesan deskripsi kesalahan" }
```

| Status | Penyebab |
|--------|----------|
| 400 | Payload tidak lengkap, format salah |
| 401 | Token JWT tidak valid / kedaluwarsa |
| 403 | Role bukan asesor, atau akses resource milik asesor lain |
| 404 | Data tidak ditemukan |
| 500 | Kegagalan database/server |

---

## Catatan Penting untuk Frontend

1. **Endpoint 1-5, 7, 9-13 sudah ada sebelumnya** — FE yang sudah integrate tidak perlu ubah.
2. **Endpoint 6 (surat-tugas) diperbaiki** — sebelumnya selalu 404, sekarang ambil file dari DB (`link_ba`/`dokumen_berita_acara`/`file_jadual`/`sk_lisensi`).
3. **Endpoint 8 (detail laporan) response berubah** — field `ringkasan` (bukan `kpi_pelaksanaan`), `nama_asesor` (bukan `asesor`), `dokumen.surat_tugas_name` dari basename URL.
4. **Endpoint 14 (honor) response diperluas** — banyak field baru (status, metode_pembayaran, no_transfer, dll).
5. **Endpoint 15-18 (tiket) baru** — sebelumnya FE pakai local state/mock, sekarang ada backend persistence.
6. **`:id` tiket** menerima format `TK-123` atau `123` — backend handle keduanya.
7. **`asesor` di detail jadwal** adalah array string (nama), bukan array objek.
8. **`nik` profil** selalu kosong (DB tidak punya kolom nik untuk asesor).
9. **`kehadiran`** di daftar_asesi_dinilai dan detail peserta saat ini placeholder — DB tidak track kehadiran per asesi.
10. **`lampiran_pendukung`** di laporan tidak dipersist di DB (selalu `[]`).
11. **Tiket `status`** selalu `"Proses"` — DB `t_pesan.status_ticket` hanya enum `0/1`, semua existing data = `1`.
12. **`metode_pembayaran`** honor selalu `"Transfer Bank"` (DB tidak punya kolom metode).
13. **`lead_asesor`** di detail jadwal saat ini kosong (DB tidak punya kolom lead).
14. **Honor `tanggal_pembayaran`** menggunakan `tanggal` jadwal (bukan tanggal real pembayaran — DB tidak track).
15. **`file_name`** di surat-tugas & detail laporan diambil dari basename URL (segmen terakhir setelah `/`), bukan hardcode.

---

## HTTP Client Examples

Lihat:
- `api/jadwal_asesor_detail.http`
- `api/jadwal_asesi.http`

Untuk tiket, contoh request:

```http
### List Tiket
GET /api/asesor/tiket
Authorization: Bearer {{token}}

### Detail Tiket
GET /api/asesor/tiket/TK-28495
Authorization: Bearer {{token}}

### Buat Tiket Baru
POST /api/asesor/tiket
Authorization: Bearer {{token}}
Content-Type: application/json

{ "judul": "Jadwal error", "pesan": "Jadwal tidak muncul", "dokumentasi_url": "" }

### Reply Tiket
POST /api/asesor/tiket/TK-28495/reply
Authorization: Bearer {{token}}
Content-Type: application/json

{ "text": "Baik, terima kasih." }
```
