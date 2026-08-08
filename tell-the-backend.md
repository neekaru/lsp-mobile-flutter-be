# Kontrak Backend LSP Mobile: Detail Asesor Kompetensi Teknis & Detail Masa Berlaku Asesor

Dokumen ini **menggantikan secara total (override)** seluruh isi kontrak sebelumnya. Dokumen ini khusus mengatur spesifikasi backend untuk fitur **Detail Asesor Kompetensi Teknis (Berdasarkan Skema)** dan **Detail Masa Berlaku Asesor**.

---

## 1. Aturan Bisnis & Alur Kerja

| ID | Aturan |
|---|---|
| BR-01 | Pengguna (Admin / Pengelola Dashboard) dapat melihat statistik Kompetensi Teknis berdasarkan daftar skema sertifikasi. |
| BR-02 | Ketika pengguna menekan salah satu **Skema Sertifikasi** pada statistik Kompetensi Teknis, aplikasi membuka screen detail yang menampilkan siapa saja Asesor yang terdaftar/memiliki kompetensi dalam skema tersebut. |
| BR-03 | Screen detail Kompetensi Teknis wajib memiliki **Searchbar di bagian atas** untuk pencarian nama asesor, nomor MET, email, kota/kabupaten, dan provinsi. |
| BR-04 | Screen detail Kompetensi Teknis mendukung filter status masa berlaku (`semua`, `aktif`, `tenggang`, `expired`). |
| BR-05 | Backend wajib menyediakan endpoint `GET /api/dashboard/kompetensi-teknis/{skema_id}/asesor` dengan query parameter `search`, `status`, `limit`, dan `offset`. |
| BR-06 | Ketika pengguna menekan card **Masa Tenggang** atau **Expired** pada Masa Berlaku Asesor, aplikasi membuka screen detail berisi daftar nama-nama Asesor terkait via `GET /api/dashboard/masa-berlaku-asesor/detail`. |

---

## 2. Autentikasi dan Header Request

```http
Authorization: Bearer <access_token>
Accept: application/json
```

---

## 3. Spesifikasi Endpoint API

### 3.1. Detail Asesor Berdasarkan Skema Kompetensi Teknis

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/dashboard/kompetensi-teknis/{skema_id}/asesor` | Bearer Token | Mengambil daftar nama-nama Asesor yang terdaftar dalam suatu Skema Kompetensi Teknis |

#### Path & Query Parameters:

| Parameter | Posisi | Tipe | Wajib | Contoh | Default | Keterangan |
|---|---|---|---|---|---|---|
| `skema_id` | Path | String/Int | Ya | `36` atau `SKK-36` | - | ID atau Kode Skema Sertifikasi |
| `status` | Query | String | Tidak | `semua` / `aktif` / `tenggang` / `expired` | `semua` | Filter status masa berlaku asesor dalam skema |
| `search` | Query | String | Tidak | `Budi` / `MET.2024` / `Jakarta` | - | Filter pencarian nama asesor, nomor MET, domisili, email, atau no HP |
| `limit` | Query | Integer | Tidak | `50` | `50` | Batas jumlah data per halaman |
| `offset` | Query | Integer | Tidak | `0` | `0` | Posisi offset pagination |

---

### 3.2. Contoh Response Berhasil (`200 OK`)

#### `GET /api/dashboard/kompetensi-teknis/36/asesor?status=semua&search=budi`

```json
{
  "status": "success",
  "message": "Data detail asesor kompetensi teknis berhasil diambil",
  "data": {
    "skema_id": 36,
    "kode_skema": "SKK-36-10/2024",
    "nama_skema": "Pemasaran Digital",
    "total_asesor": 86,
    "asesor_list": [
      {
        "id": "101",
        "nama_asesor": "Dr. Ir. Budi Santoso, M.Kom",
        "no_met": "MET.000.003871.2018",
        "status_masa_berlaku": "Aktif",
        "tanggal_expired": "2027-11-15",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Selatan",
        "email": "budi.santoso@lsp.or.id",
        "no_hp": "081234567890",
        "tipe_asesor": "Internal"
      },
      {
        "id": "102",
        "nama_asesor": "Ahmad Rizal, S.Kom., M.T.",
        "no_met": "MET.000.004120.2019",
        "status_masa_berlaku": "Tenggang",
        "tanggal_expired": "2026-08-30",
        "provinsi": "Jawa Barat",
        "kabupaten_kota": "Kota Bandung",
        "email": "ahmad.rizal@lsp.or.id",
        "no_hp": "081398765432",
        "tipe_asesor": "Internal"
      }
    ]
  },
  "meta": {
    "total_count": 86,
    "filtered_count": 2,
    "limit": 50,
    "offset": 0
  }
}
```

---

### 3.3. Deskripsi Schema Fields

| Field Data | Tipe | Keterangan |
|---|---|---|
| `data.skema_id` | String/Int | ID Skema Sertifikasi |
| `data.kode_skema` | String | Kode resmi skema sertifikasi |
| `data.nama_skema` | String | Judul/nama skema kompetensi teknis |
| `data.total_asesor` | Integer | Total keseluruhan asesor pada skema tersebut |
| `asesor_list[].id` | String | Unique ID record Asesor |
| `asesor_list[].nama_asesor` | String | Nama lengkap asesor beserta gelar |
| `asesor_list[].no_met` | String | Nomor MET / Registrasi Asesor |
| `asesor_list[].status_masa_berlaku` | String | `"Aktif"`, `"Tenggang"`, atau `"Expired"` |
| `asesor_list[].tanggal_expired` | String | Format tanggal `YYYY-MM-DD` |
| `asesor_list[].provinsi` | String | Nama provinsi domisili asesor |
| `asesor_list[].kabupaten_kota` | String | Nama kota/kabupaten domisili asesor |
| `asesor_list[].email` | String | Email kontak asesor |
| `asesor_list[].no_hp` | String | Nomor HP/Whatsapp asesor |
| `asesor_list[].tipe_asesor` | String | `"Internal"` atau `"External"` |

---

### 3.4. Detail Masa Berlaku Asesor (`tenggang` / `expired`)

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/dashboard/masa-berlaku-asesor/detail` | Bearer Token | Mengambil daftar nama-nama Asesor yang berada dalam Masa Tenggang atau Expired |

#### Query Parameters:

| Parameter | Tipe | Wajib | Contoh | Default | Keterangan |
|---|---|---|---|---|---|
| `status` | String | Ya | `tenggang` / `expired` | - | Kategori status masa berlaku |
| `search` | String | Tidak | `Budi` / `MET.2024` | - | Filter pencarian nama, MET, skema, domisili |
| `limit` | Integer | Tidak | `50` | `50` | Batas jumlah data per halaman |
| `offset` | Integer | Tidak | `0` | `0` | Posisi offset pagination |

---

## 4. Format Error Standard

```json
{
  "status": "error",
  "code": "RESOURCE_NOT_FOUND",
  "message": "Skema sertifikasi tidak ditemukan.",
  "errors": null
}
```

| HTTP Status | Keterangan |
|---:|---|
| `400` | Parameter request tidak valid |
| `401` | Unauthorized - Token JWT tidak valid atau expired |
| `404` | Skema tidak ditemukan |
| `500` | Internal Server Error |

---

## 5. Kriteria Penerimaan Backend (Acceptance Criteria)

| ID | Kriteria |
|---|---|
| AC-01 | Endpoint `GET /api/dashboard/kompetensi-teknis/{skema_id}/asesor` mengembalikan daftar asesor yang memiliki unit/skema kompetensi terkait. |
| AC-02 | Parameter `search` mendukung pencarian case-insensitive pada nama asesor, nomor MET, email, no HP, kota/kabupaten, dan provinsi. |
| AC-03 | Parameter `status` mampu memfilter asesor dengan status `aktif`, `tenggang` (< 3 bulan menuju expired), atau `expired`. |
| AC-04 | Endpoint `GET /api/dashboard/masa-berlaku-asesor/detail?status=tenggang` / `expired` menyajikan data asesor tenggang & expired secara akurat. |
