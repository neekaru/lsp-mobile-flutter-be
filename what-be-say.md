# Asesi API — Contract & Notes for Frontend

Semua endpoint Asesi wajib Bearer token + role `asesi`. Identitas asesi diambil otomatis dari JWT (claim `sub` = `t_users.id` yang merujuk langsung ke `lsp275_asesi.id_users`).

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Akun demo asesi:
- `account`: `demo_asesi_001`
- `password`: `demo123`
- `email`: `asesi.demo@lsp.id`
- `t_users.id`: `194329` / `lsp275_asesi.id`: `251277` (registrasi utama)

---

## Status Implementasi Endpoint

| # | Metode | Endpoint | Status | Catatan |
|---|--------|----------|--------|---------|
| 1 | POST | `/api/auth/login` | ✅ Sudah ada (live) | Tidak diubah |
| 2 | POST | `/api/auth/logout` | ✅ Sudah ada (live) | Tidak diubah |
| 3 | GET | `/api/auth/current` | ✅ Sudah ada (live) | Tidak diubah |
| 4 | POST | `/api/auth/refresh` | ✅ Sudah ada (live) | Tidak diubah |
| 5 | GET | `/api/sessions` | ✅ Sudah ada (live) | Tidak diubah |
| 6 | DELETE | `/api/sessions/:id` | ✅ Sudah ada (live) | Tidak diubah |
| 7 | GET | `/api/asesi/dashboard` | 🆕 BARU | Gabungan summary + alert_banner + berita_terkini |
| 8 | GET | `/api/asesi/jadwal` | ✅ Sudah ada (live) | Tidak diubah |
| 9 | GET | `/api/berita` | ✅ Sudah ada (live) | Tidak diubah |
| 10 | GET | `/api/sertifikat/skema` | ✅ Sudah ada (live) | Tidak diubah |
| 11 | GET | `/api/sertifikat/skema/bidang` | ✅ Sudah ada (live) | Tidak diubah |
| 12 | GET | `/api/sertifikat/skema/:id` | ✅ Sudah ada (live) | Tidak diubah |
| 13 | GET | `/api/sertifikat/skema/:id/asesor` | ✅ Sudah ada (live) | Tidak diubah |
| 14 | POST | `/api/sertifikasi/daftar` | 🆕 BARU | Insert ke `lsp275_asesi` |
| 15 | GET | `/api/sertifikasi/status` | 🆕 BARU | Cek status pendaftaran aktif |
| 16 | GET | `/api/pra-asesmen/skema/:id/info` | ✅ Sudah ada (live) | Tidak diubah |
| 17 | GET | `/api/pra-asesmen/skema/:id/kompetensi` | ✅ Sudah ada (live) | Tidak diubah |
| 18 | POST | `/api/pra-asesmen/skema/:id/submit` | 🆕 BARU | Tandai pra-asesmen selesai |
| 19 | GET | `/api/sertifikasi/:id/portofolio` | 🆕 BARU | List dokumen dari `lsp275_skema_syarat` |
| 20 | POST | `/api/sertifikasi/:id/portofolio/upload` | 🆕 BARU | Simpan ke `storage/portofolio` + kolom `ch_portofolio` |
| 21 | GET | `/api/asesor/profile` | ✅ Sudah ada (live) | Shared asesor/asesi |
| 22 | PUT | `/api/asesor/profile` | ✅ Sudah ada (live) | Shared asesor/asesi |
| 23 | GET | `/api/asesi/instansi` | 🆕 BARU | Baca kolom `lsp275_asesi` |
| 24 | PUT | `/api/asesi/instansi` | 🆕 BARU | Tulis kolom `lsp275_asesi` |
| 25 | GET | `/api/asesi/sertifikat` | 🆕 BARU | Dari `lsp275_asesi` (terbitkan='on') |
| 26 | GET | `/api/asesi/sertifikat/:id` | 🆕 BARU | Detail sertifikat |
| 27 | POST | `/api/asesi/sertifikat/:id/upload-ttd` | 🆕 BARU | Simpan ke `storage/sertifikat/ttd` |
| 28 | GET | `/api/asesi/sertifikat/:id/download` | 🆕 BARU | Return URL PDF |
| 29 | POST | `/api/sertifikat/validate` | ✅ Sudah ada (live) | Tidak diubah |
| 30 | GET | `/api/sertifikat/search` | ✅ Sudah ada (live) | Tidak diubah |

**Ringkasan:**
- Endpoint 1-6, 8-13, 16-17, 21-22, 29-30: **sudah ada sebelumnya**, tidak diubah. FE bisa langsung pakai.
- Endpoint 7, 14, 15, 18, 19, 20, 23, 24, 25, 26, 27, 28: **baru ditambahkan** untuk role asesi.

---

## 1. Dashboard — `GET /api/asesi/dashboard`

**🆕 BARU**

```json
{
  "status": "success",
  "data": {
    "summary": {
      "skema_diikuti": 1,
      "sertifikat_aktif": 2
    },
    "alert_banner": {
      "has_alert": true,
      "title": "Pra-Asesmen Menunggu Pengisian",
      "subtitle": "Silakan selesaikan pengisian Pra-Asesmen untuk skema Digital Marketing Madya"
    },
    "berita_terkini": [
      {
        "id": 1,
        "title": "Sosialisasi LSP Digital Gelombang 2",
        "date": "15 Juli 2026",
        "summary": "Pendaftaran sertifikasi kompetensi gelombang kedua resmi dibuka...",
        "image_url": "https://host/storage/berita/1678doa.jpeg"
      }
    ]
  }
}
```

Backend notes:
- `summary.skema_diikuti` = `COUNT(DISTINCT jadwal_id)` di `lsp275_asesi` WHERE `id_users = :user`.
- `summary.sertifikat_aktif` = jumlah row `lsp275_asesi` WHERE `id_users = :user` AND `terbitkan_sertifikat = 'on'` AND `no_sertifikat IS NOT NULL`.
- `alert_banner.has_alert` = `true` jika ada registrasi dengan `pra_asesmen = '0'` (belum diisi). `subtitle` menyebutkan nama skema dari `lsp275_skema` jika diketahui.
- `berita_terkini` = 5 artikel terbaru dari `lsp275_artikel` (ORDER BY `tanggal_buat DESC`). `image_url` = `{baseURL}/storage/berita/{foto}`.

---

## 2. Daftar Jadwal — `GET /api/asesi/jadwal`

**(Sudah ada, tidak diubah)** — lihat `route.go` (handler `JadwalController.JadwalAsesi`).

---

## 3. Pendaftaran — `POST /api/sertifikasi/daftar`

**🆕 BARU**

Request:
```json
{ "skema_id": 1, "tuk_id": 2, "tanggal_rencana": "2026-08-10" }
```

Response `201`:
```json
{
  "status": "success",
  "message": "Pendaftaran berhasil disimpan",
  "data": { "sertifikasi_id": 251280, "status": "terdaftar" }
}
```

Backend notes:
- Insert ke `lsp275_asesi` dengan `id_users = :user`, `id_skema = skema_id`, `skema_sertifikasi = skema_id`.
- `jadwal_id` diisi dari jadwal existing (`lsp275_jadual_asesmen` WHERE `id_skema` & `id_tuk` & `status_aktif='1'`) bila ada, else `0`.
- `sertifikasi_id` = `lsp275_asesi.id` yang baru dibuat (== nomor registrasi asesi).
- Field wajib: `skema_id`, `tuk_id`.

---

## 4. Status Pendaftaran — `GET /api/sertifikasi/status`

**🆕 BARU**

Query opsional: `?skema_id=1`.

```json
{
  "status": "success",
  "data": {
    "terdaftar": true,
    "sertifikasi_id": 251280,
    "status_pendaftaran": "pra_asesmen_menunggu",
    "pra_asesmen_status": "0",
    "skema_sertifikasi": 1
  }
}
```

Backend notes:
- `terdaftar`: ada row `lsp275_asesi` untuk user (filter `skema_sertifikasi` bila `skema_id` dikirim).
- `status_pendaftaran`: `belum_terdaftar` | `terdaftar` | `pra_asesmen_menunggu` (`pra_asesmen='0'`) | `pra_asesmen_selesai` (`pra_asesmen='1'`) | `pra_asesmen_perbaikan` (`pra_asesmen='2'`).

---

## 5. Pra-Asesmen Submit — `POST /api/pra-asesmen/skema/:id/submit`

**🆕 BARU**

Request:
```json
{ "evaluasi": [ { "id_elemen": 101, "nilai": "K" } ] }
```

Response `200`:
```json
{ "status": "success", "message": "Pra-Asesmen mandiri berhasil disimpan" }
```

Backend notes:
- `:id` = `id_skema`.
- Update row `lsp275_asesi` milik user (`skema_sertifikasi = :id`): set `pra_asesmen='1'`, `complete_praasesmen='1'`, `pra_asesmen_date=NOW()`, dan simpan array `evaluasi` ke kolom `validitas_dokumen_pra_asesmen` (JSON).
- Jika belum ada registrasi, ambil registrasi terakhir user. Bila tidak ada sama sekali → `404`.

---

## 6. Portofolio — `GET /api/sertifikasi/:id/portofolio`

**🆕 BARU**

`:id` = `sertifikasi_id` (`lsp275_asesi.id`).

```json
{
  "status": "success",
  "data": {
    "documents": [
      {
        "key": "pendidikan_minimal_sma_sederajat",
        "label": "Pendidikan minimal SMA/Sederajat;",
        "is_required": false,
        "status": "Belum Diunggah",
        "file_name": null,
        "comment": null
      }
    ]
  }
}
```

Backend notes:
- List dokumen diambil dari `lsp275_skema_syarat` WHERE `id_skema = registrasi.skema_sertifikasi`.
- `key` = slug (`lowercase`, spasi→`_`) dari `nama_persyaratan`. **FE harus mengirim `key` yang sama saat upload.**
- Status upload di-persist di kolom `lsp275_asesi.ch_portofolio` (JSON: `{ "<key>": { "file_name", "status", "comment" } }`).
- Status tiap dokumen: `"Belum Diunggah"` → `"Menunggu Verifikasi"` (setelah upload).

---

## 7. Upload Portofolio — `POST /api/sertifikasi/:id/portofolio/upload`

**🆕 BARU**

Content-Type: `multipart/form-data`. Field: `key` (string), `file` (PDF/PNG/JPG, max 2MB).

Response `200`:
```json
{
  "status": "success",
  "message": "Berkas berhasil diunggah",
  "data": { "file_name": "foto_terbaru_merah.jpg", "status": "Menunggu Verifikasi", "url": "https://host/storage/portofolio/uuid.jpg" }
}
```

Backend notes:
- File disimpan ke `storage/portofolio/{uuid}{ext}`.
- `key` + metadata disimpan ke `lsp275_asesi.ch_portofolio` (JSON, merge dengan existing).
- Validasi: `key` wajib, `file` wajib, max 2MB, ekstensi `.pdf/.png/.jpg/.jpeg`.

---

## 8. Instansi — `GET /api/asesi/instansi`

**🆕 BARU**

```json
{
  "status": "success",
  "data": {
    "tipe_instansi": "Mahasiswa",
    "data_instansi": {
      "nama_perguruan_tinggi": "Politeknik Sampit",
      "fakultas": "",
      "program_studi": "",
      "nim": "087685674568",
      "alamat": "Jl. Wengga Metropolitan"
    }
  }
}
```

Backend notes (⚠️ limitasi DB — tidak ada tabel instansi dedicated):
- `tipe_instansi`: `"Pekerja"` jika `id_pekerjaan > 0`, else `"Mahasiswa"`.
- `nama_perguruan_tinggi` ← kolom `id_sekolah`.
- `nim` ← kolom `kode_sekolah`.
- `alamat` ← kolom `alamat_company`.
- `fakultas` & `program_studi` **selalu `""`** (DB tidak punya kolom tersebut).

---

## 9. Update Instansi — `PUT /api/asesi/instansi`

**🆕 BARU**

```json
{
  "tipe_instansi": "Mahasiswa",
  "data_instansi": { "nama_perguruan_tinggi": "Politeknik Sampit", "nim": "087685674568", "alamat": "Jl. Wengga Metropolitan" }
}
```

Response `200`:
```json
{ "status": "success", "message": "Data instansi berhasil disimpan" }
```

Backend notes:
- Tulis ke kolom `lsp275_asesi`: `id_sekolah`, `kode_sekolah`, `alamat_company`, `id_pekerjaan` (1 jika `tipe_instansi="Pekerja"`).
- Bila user belum punya row `lsp275_asesi`, dibuatkan row minimal.
- `fakultas`/`program_studi` tidak dipersist (tidak ada kolom).

---

## 10. List Sertifikat — `GET /api/asesi/sertifikat`

**🆕 BARU**

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "skema": "Digital Marketing Madya",
      "pemegang": "Muhammad Hanafi",
      "nomor_sertifikat": "FR-APR-02",
      "tanggal_terbit": "2026-04-20",
      "tanggal_berlaku": "2028-04-20",
      "status": "aktif",
      "kategori": "Digital Marketing",
      "institusi": "LSP Digital Marketing",
      "nomor_registrasi": "REG-55431-2026",
      "nomor_blanko": "BLANKO-778811",
      "nomor_seri": "BLANKO-778811",
      "tempat_uji": "TUK LSP Digital Utama",
      "nama_asesor": "Dr. Ir. Ahmad Yani, M.Kom"
    }
  ]
}
```

Backend notes:
- Sumber: `lsp275_asesi` WHERE `id_users = :user` AND `terbitkan_sertifikat='on'` AND `no_sertifikat IS NOT NULL`.
- Join: `lsp275_skema` (nama/kategori), `lsp275_jadual_asesmen`→`lsp275_tuk` (tempat_uji), `lsp275_mapping_asesor`→`lsp275_users` (nama_asesor).
- **`nomor_blanko` diambil dari kolom `no_seri`** (sesuai instruksi pemilik project). `nomor_seri` juga dari `no_seri`.
- `tanggal_berlaku` = `tanggal_terbit + 2 tahun` (konvensi berlaku 2 tahun).
- `institusi` saat ini diisi dari `tempat_uji` (TUK) karena tidak ada kolom institusi terpisah.

---

## 11. Detail Sertifikat — `GET /api/asesi/sertifikat/:id`

**🆕 BARU** — struktur `data` sama dengan item di list (lihat section 10). `:id` harus milik user login, else `404`.

---

## 12. Upload Foto & TTD — `POST /api/asesi/sertifikat/:id/upload-ttd`

**🆕 BARU**

Content-Type: `multipart/form-data`. Field `file` (bisa multi-file, PDF/PNG/JPG, max 5MB).

```json
{
  "status": "success",
  "message": "Berkas foto & tanda tangan berhasil disimpan",
  "data": {
    "uploaded_files": [ { "name": "ttd_hanafi.png", "url": "https://host/storage/sertifikat/ttd/1_uuid.png" } ]
  }
}
```

Backend notes:
- File disimpan ke `storage/sertifikat/ttd/{sertifikat_id}_{uuid}{ext}`.
- Tidak dipersist ke DB (seperti lampiran asesor).

---

## 13. Download Sertifikat — `GET /api/asesi/sertifikat/:id/download`

**🆕 BARU**

```json
{ "status": "success", "data": { "download_url": "https://host/storage/sertifikat/pdf/sertifikat_1.pdf" } }
```

Backend notes:
- Mengembalikan URL konstruksi ke `storage/sertifikat/pdf/sertifikat_{id}.pdf`.
- Validasi kepemilikan: `:id` harus `lsp275_asesi` milik user dengan `terbitkan_sertifikat='on'`, else `404`.

---

## Catatan Penting untuk Frontend

1. **Endpoint 1-6, 8-13, 16-17, 21-22, 29-30 sudah ada** — FE yang sudah integrate tidak perlu ubah.
2. **Endpoint 7, 14, 15, 18, 19, 20, 23, 24, 25, 26, 27, 28 baru** — tambahan untuk role asesi.
3. **`nomor_blanko` = kolom `no_seri`** di `lsp275_asesi` (instruksi pemilik project). `no_seri` di DB banyak yang `NULL`, jadi field bisa kosong.
4. **Portofolio `key`** = slug dari `nama_persyaratan` skema (spasi→`_`), mis. `"Pendidikan minimal SMA/Sederajat;"` → `"pendidikan_minimal_sma_sederajat"`. FE wajib pakai `key` yang sama saat upload agar status overlay benar di GET.
5. **Instansi** dipetakan ke kolom existing `lsp275_asesi` (`id_sekolah`, `kode_sekolah`, `alamat_company`, `id_pekerjaan`) — tidak ada tabel instansi dedicated, sehingga `fakultas` & `program_studi` selalu `""`.
6. **`tanggal_berlaku` sertifikat** = `tanggal_terbit + 2 tahun`.
7. **Upload file** (portofolio/ttd) disimpan di folder `storage/` lokal; `url` mengandung `host` request — pastikan FE memakai base URL yang konsisten.
8. Semua endpoint di atas (selain auth) memerlukan **role `asesi`**; request dengan role lain → `403`.

---

## Error Response (semua endpoint)

```json
{ "status": "error", "message": "Pesan deskripsi kesalahan" }
```

| Status | Penyebab |
|--------|----------|
| 400 | Payload tidak lengkap, format salah, atau ukuran berkas melebihi batas |
| 401 | Token JWT tidak valid / kedaluwarsa |
| 403 | Role bukan `asesi`, atau akses resource milik asesi lain |
| 404 | Data skema, pendaftaran, portofolio, atau sertifikat tidak ditemukan |
| 500 | Kegagalan database/server |

---

## HTTP Client Examples

```http
### Dashboard Asesi
GET /api/asesi/dashboard
Authorization: Bearer {{token}}

### Daftar Sertifikasi
POST /api/sertifikasi/daftar
Authorization: Bearer {{token}}
Content-Type: application/json

{ "skema_id": 383, "tuk_id": 7, "tanggal_rencana": "2026-08-10" }

### Status Pendaftaran
GET /api/sertifikasi/status?skema_id=383
Authorization: Bearer {{token}}

### Submit Pra-Asesmen
POST /api/pra-asesmen/skema/383/submit
Authorization: Bearer {{token}}
Content-Type: application/json

{ "evaluasi": [ { "id_elemen": 101, "nilai": "K" } ] }

### List Portofolio
GET /api/sertifikasi/251277/portofolio
Authorization: Bearer {{token}}

### Upload Portofolio
POST /api/sertifikasi/251277/portofolio/upload
Authorization: Bearer {{token}}
Content-Type: multipart/form-data

key=ktp
file=@/path/ktp.jpg

### Instansi
GET /api/asesi/instansi
Authorization: Bearer {{token}}

PUT /api/asesi/instansi
Authorization: Bearer {{token}}
Content-Type: application/json

{ "tipe_instansi": "Mahasiswa", "data_instansi": { "nama_perguruan_tinggi": "Politeknik Sampit", "nim": "087685674568" } }

### List Sertifikat
GET /api/asesi/sertifikat
Authorization: Bearer {{token}}

### Detail Sertifikat
GET /api/asesi/sertifikat/251277
Authorization: Bearer {{token}}

### Upload TTD
POST /api/asesi/sertifikat/251277/upload-ttd
Authorization: Bearer {{token}}
Content-Type: multipart/form-data

file=@/path/ttd.png

### Download Sertifikat
GET /api/asesi/sertifikat/251277/download
Authorization: Bearer {{token}}
```
