# Admin Honor Asesor API — Contract & Notes for Frontend

Semua endpoint Admin Honor Asesor wajib Bearer token + role `admin`. Jika role bukan `admin` → `403`.

```http
Authorization: Bearer <access_token>
Accept: application/json
```

---

## Status Implementasi Endpoint

| # | Metode | Endpoint | Status | Catatan |
|---|--------|----------|--------|---------|
| 1 | GET | `/api/admin/honor-asesor` | 🆕 BARU | Summary honor per Asesor |
| 2 | GET | `/api/admin/honor-asesor/:asesor_id/tugas` | 🆕 BARU | Info Asesor + daftar tugas honor |
| 3 | GET | `/api/admin/honor-asesor/tugas/:tugas_id` | 🆕 BARU | Detail rincian honor tugas |
| 4 | POST | `/api/admin/honor-asesor/tugas/:tugas_id` | 🆕 BARU | Update status & link bukti |
| 5 | PUT | `/api/admin/honor-asesor/tugas/:tugas_id` | 🆕 BARU | Alias POST (sama) |

> ⚠️ **Urutan route penting**: `/honor-asesor/tugas/:tugas_id` didaftarkan **sebelum** `/honor-asesor/:asesor_id/tugas` agar segment literal `tugas` tidak tertangkap sebagai `:asesor_id`.

---

## 1. Daftar Honor Asesor — `GET /api/admin/honor-asesor`

**🆕 BARU**

### Query Parameters

| Parameter | Contoh | Keterangan |
|---|---|---|
| `status` | `semua` / `menunggu` / `selesai` | Filter status pembayaran honor (default: `semua`) |
| `bulan` | `2026-07` / `semua` | Filter periode dari `tanggal` jadwal (default: **bulan berjalan**, `YYYY-MM`) |
| `search` | `Masriah` / `Auditor IT` / `Eduwork` | Pencarian `u.users`, `s.skema`, atau `j.jadual` |
| `limit` | `20` | Batas data per halaman (default 20, max 100) |
| `offset` | `0` | Offset pagination |

### Response `200 OK`

```json
{
  "status": "success",
  "data": [
    {
      "id": 1428,
      "nama_asesor": "Asesor Demo LSP",
      "tipe_asesor": "Asesor Internal",
      "judul_asesmen": "Sertifikasi Desainer Multimedia Muda",
      "skema": "Desainer Multimedia Madya",
      "honor": "Rp. 8.250.000",
      "total_honor_numeric": 8250000,
      "status": "Menunggu",
      "tanggal": "14 Juli 2026",
      "avatar_url": null
    }
  ],
  "meta": {
    "total_count": 1,
    "menunggu_count": 1,
    "selesai_count": 0,
    "selected_month": "Juli 2026"
  }
}
```

Backend notes:
- **1 baris = 1 Asesor** — agregasi `lsp275_mapping_asesor` (GROUP BY `id_asesor`).
- `honor` & `total_honor_numeric` = total honor seluruh tugas valid Asesor (parse teks → angka). Nilai non-numerik (`Langsung Dipotong Oleh TUK`) dan `0` **tidak dihitung**.
- `status` Asesor = `Menunggu` jika **ada minimal satu** tugas berstatus `0`, else `Selesai`.
- `judul_asesmen` & `skema` = dari tugas **terbaru** Asesor.
- `meta.menunggu_count` / `meta.selesai_count` dihitung dari set **tanpa** filter `status` (untuk badge tab), tapi tetap mengikuti filter `bulan` + `search`.
- `meta.selected_month` = `"Bulan Tahun"` dari param `bulan` (e.g. `2026-07` → `Juli 2026`), atau `"Semua Periode"` bila `bulan=semua`.
- `avatar_url` sering `null` (kolom `foto_user` banyak kosong).
- Hanya tugas pada jadwal valid: `status_jadwal IN ('1','4')`, `status_delete='1'`, `status_aktif='Y'`.

---

## 2. Detail Tugas Asesor — `GET /api/admin/honor-asesor/:asesor_id/tugas`

**🆕 BARU**

`:asesor_id` = `lsp275_users.id` (id asesor, dari `data[].id` pada endpoint 1).

### Query Parameters

| Parameter | Contoh | Keterangan |
|---|---|---|
| `status` | `semua` / `selesai` / `menunggu` | Filter daftar tugas (default: `semua`) |

### Response `200 OK`

```json
{
  "status": "success",
  "data": {
    "asesor_info": {
      "id": 1428,
      "nama_asesor": "Asesor Demo LSP",
      "tipe_asesor": "Asesor Internal",
      "status_keaktifan": "Aktif",
      "total_honor": "Rp. 8.250.000",
      "total_honor_numeric": 8250000,
      "avatar_url": null
    },
    "counts": {
      "semua": 4,
      "selesai": 0,
      "menunggu": 4
    },
    "tugas": [
      {
        "id": 28375,
        "judul": "Sertifikasi Desainer Multimedia Muda",
        "tuk": "ITNY",
        "waktu": "14/07/2026 09:00 - 15:00 wib",
        "mode": "Offline",
        "honor": "Rp. 2.750.000",
        "status": "Menunggu"
      }
    ]
  }
}
```

Backend notes:
- `asesor_info.total_honor` dihitung dari **seluruh tugas valid** (tidak terpengaruh filter `status` pada daftar).
- `counts` = per-status seluruh tugas (tidak terpengaruh filter).
- `waktu` = `tanggal` (DD/MM/YYYY) + `waktu` jadwal + ` wib`.
- `mode` = `jw.jenis_uji`: `1`→`Online`, `2`→`Offline`.
- Asesor tidak ditemukan → `404`.

---

## 3. Detail Honor Asesor — `GET /api/admin/honor-asesor/tugas/:tugas_id`

**🆕 BARU**

`:tugas_id` = `lsp275_mapping_asesor.id` (`data[].tugas[].id` pada endpoint 2).

### Response `200 OK`

```json
{
  "status": "success",
  "data": {
    "tugas_id": 28372,
    "judul_asesmen": "Sertifikasi Pemasaran Digital - ITNY",
    "tuk": "ITNY",
    "waktu": "28/05/2026 09:00 - 16:00 wib",
    "mode": "Online",
    "status_pembayaran": "Menunggu Pembayaran",
    "rincian_honor": {
      "honor_asesmen": 2000000,
      "akomodasi": 0,
      "potongan_pph": 100000,
      "biaya_admin_transfer": 0,
      "total_honor": 1900000
    },
    "lampiran_bukti": {
      "file_name": "bukti_transfer",
      "file_url": "https://cloud.lspdigital.id/s/..."
    },
    "catatan": "-"
  }
}
```

Backend notes:
- `rincian_honor.total_honor` = `honor_asesmen − potongan_pph − biaya_admin_transfer` (**dihitung**, tidak tersimpan di DB). Jika negatif → `0`.
- `honor_asesmen` / `akomodasi` / `potongan_pph` adalah hasil parse teks → angka (`Rp. 100.000` → `100000`). Nilai non-numerik (mis. `Transport & Penginapan`) → `0`.
- `lampiran_bukti.file_url` = **satu URL teks** dari `ma.link_bukti_pembayaran` (Cloud/Drive), bukan file upload.
- `catatan` **selalu `"-"`** — tidak ada kolom catatan pembayaran di DB (lihat Catatan Keterbatasan).
- `status_pembayaran`: `"1"`→`Pembayaran Selesai`, `"0"`→`Menunggu Pembayaran`.
- Tugas tidak ditemukan → `404`.

---

## 4. Update Status & Bukti Honor — `POST /api/admin/honor-asesor/tugas/:tugas_id`

**🆕 BARU** — Content-Type: `application/json` (bukan multipart).

### Request Body

```json
{
  "status": "1",
  "link_bukti_pembayaran": "https://cloud.lspdigital.id/s/cRsd6FwsrJxnQiP"
}
```

| Key | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `status` | String | Ya | Nilai enum DB: `"1"` (Pembayaran Selesai) atau `"0"` (Menunggu Pembayaran) — **bukan label** |
| `link_bukti_pembayaran` | String | Tidak | URL bukti transfer (Cloud/Drive) |

### Response `200 OK`

```json
{
  "status": "success",
  "message": "Pembayaran Honor Asesor Telah Disimpan",
  "data": {
    "tugas_id": 28372,
    "status": "1",
    "link_bukti_pembayaran": "https://cloud.lspdigital.id/s/cRsd6FwsrJxnQiP",
    "updated_at": "2026-08-01T10:15:00Z"
  }
}
```

Backend notes:
- Tulis ke `lsp275_mapping_asesor`: `status_pembayaran_honor`, `link_bukti_pembayaran` (bila dikirim), `updated_when = NOW()`.
- `status` selain `"0"`/`"1"` → `400`.
- Tugas tidak ditemukan → `404` (tidak ada baris ter-update).

---

## Catatan Keterbatasan Database (Penting untuk FE/Backend)

1. **`honor` bertipe teks** (`VARCHAR`) dengan format tidak konsisten: `400000`, `750.000`, `1.000.000`, `Rp. 2.750.000`, `0`, bahkan `Langsung Dipotong Oleh TUK`. Backend mem-parse teks → angka (buang titik/koma/`Rp`) dan mengecualikan nilai non-numerik saat menghitung total.
2. **Bukti transfer = satu URL teks** (`link_bukti_pembayaran`), bukan penyimpanan file biner. Tidak ada kolom `file_name` terpisah.
3. **`tipe_asesor` (Internal/Eksternal) tidak tersimpan langsung** — diturunkan dari `instansi_asesor_external`: kosong/NULL atau mengandung `LSP TD`/`LSP Teknologi Digital` (atau `-`) → `Asesor Internal`; selain itu → `Asesor Eksternal`.
4. **Tidak ada kolom `catatan`** pembayaran honor pada tabel manapun yang terkait → field `catatan` selalu `"-"`.
5. **Nama skema hanya bisa diperoleh via `lsp275_mapping_skema → lsp275_skema`**, karena `lsp275_jadual_asesmen.id_skema` kosong pada data.
6. **`avatar_url` (`foto_user`) banyak NULL** → sering `null`.
7. **Filter `bulan` dihitung dari `tanggal` jadwal pelaksanaan**, bukan dari kolom pembayaran.
8. **Pembayaran mengikuti `status_pembayaran_honor`** (`0`/`1`). Jadwal yang dipakai hanya `status_jadwal` = `1` (Selesai) atau `4` (Pelaporan), `status_delete='1'`, `status_aktif='Y'`.
9. Field draft lama `uang_kendaraan`, `uang_makan`, `lainnya`, `file_name` **tidak ada** di DB. Yang tersedia: `honor`, `akomodasi`, `potongan_pph`, `biaya_admin_transfer`, `link_bukti_pembayaran`.

---

## Error Response (semua endpoint)

```json
{ "status": "error", "message": "Pesan deskripsi kesalahan" }
```

| Status | Penyebab |
|--------|----------|
| 400 | Param `status` tidak valid / bukan `0`/`1`, atau payload tidak lengkap |
| 401 | Token JWT tidak valid / kedaluwarsa |
| 403 | Role bukan `admin` |
| 404 | Asesor / tugas honor tidak ditemukan |
| 500 | Kegagalan database/server |

---

## HTTP Client Examples

```http
### Daftar Honor Asesor
GET /api/admin/honor-asesor?status=semua&bulan=2026-07
Authorization: Bearer {{token}}

### Detail Tugas Asesor
GET /api/admin/honor-asesor/1428/tugas?status=menunggu
Authorization: Bearer {{token}}

### Detail Honor Tugas
GET /api/admin/honor-asesor/tugas/28372
Authorization: Bearer {{token}}

### Update Status & Bukti
POST /api/admin/honor-asesor/tugas/28372
Authorization: Bearer {{token}}
Content-Type: application/json

{ "status": "1", "link_bukti_pembayaran": "https://cloud.lspdigital.id/s/cRsd6FwsrJxnQiP" }
```
