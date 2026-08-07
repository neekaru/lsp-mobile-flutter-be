# Kontrak Backend LSP Mobile: Detail Masa Berlaku Asesor (Daftar Asesor Masa Tenggang & Expired)

Dokumen ini **menggantikan secara total (override)** seluruh isi kontrak sebelumnya. Dokumen ini khusus mengatur spesifikasi backend untuk fitur **Detail Masa Berlaku Asesor**, di mana ketika Admin/Pengelola menekan card **Masa Tenggang** atau **Expired** pada statistik Masa Berlaku Asesor, aplikasi akan membuka screen detail berisi daftar nama-nama Asesor yang masuk dalam kategori status tersebut lengkap dengan Searchbar di bagian atas.

---

## 1. Aturan Bisnis & Alur Kerja

| ID | Aturan |
|---|---|
| BR-01 | Pengguna (Admin / Pengelola Dashboard) dapat melihat ringkasan status Masa Berlaku Asesor (Aktif, Masa Tenggang, Expired). |
| BR-02 | Ketika pengguna menekan card **Masa Tenggang**, aplikasi membuka screen detail yang menampilkan daftar nama-nama Asesor dalam status Tenggang. |
| BR-03 | Ketika pengguna menekan card **Expired / Kadaluarsa**, aplikasi membuka screen detail yang menampilkan daftar nama-nama Asesor dalam status Expired. |
| BR-04 | Card **Sertifikat Aktif** bersifat read-only dan tidak perlu membuka screen detail list. |
| BR-05 | Screen detail wajib memiliki **Searchbar di bagian atas** untuk memfilter pencarian berdasarkan nama asesor, nomor MET/Registrasi, skema keahlian, atau kota/kabupaten. |
| BR-06 | Backend wajib menyediakan endpoint `GET /api/dashboard/masa-berlaku-asesor/detail` dengan query parameter `status` (`tenggang` atau `expired`), `search`, `limit`, dan `offset`. |

---

## 2. Autentikasi dan Header Request

```http
Authorization: Bearer <access_token>
Accept: application/json
```

---

## 3. Spesifikasi Endpoint API

### 3.1. Daftar Asesor berdasarkan Masa Berlaku (`tenggang` / `expired`)

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/dashboard/masa-berlaku-asesor/detail` | Bearer Token | Mengambil daftar nama-nama Asesor yang berada dalam Masa Tenggang atau Expired |

#### Query Parameters:

| Parameter | Tipe | Wajib | Contoh | Default | Keterangan |
|---|---|---|---|---|---|
| `status` | String | Ya | `tenggang` / `expired` | - | Kategori status masa berlaku (`tenggang` = kurang dari 3 bulan, `expired` = telah habis masa berlaku) |
| `search` | String | Tidak | `Budi` / `MET.2024` | - | Filter pencarian nama asesor, nomor MET, skema keahlian, atau kota/kabupaten (case-insensitive) |
| `limit` | Integer | Tidak | `50` | `50` | Batas jumlah data per halaman |
| `offset` | Integer | Tidak | `0` | `0` | Posisi offset pagination |

---

### 3.2. Contoh Response Berhasil (`200 OK`)

#### Contoh 1: Status `tenggang`
```json
{
  "status": "success",
  "message": "Data asesor masa tenggang berhasil diambil",
  "data": {
    "status_filter": "tenggang",
    "total_count": 12,
    "asesor_list": [
      {
        "id": "101",
        "nama_asesor": "Dr. Ir. Budi Santoso, M.Kom",
        "no_met": "MET.000.003871.2018",
        "status_masa_berlaku": "Tenggang",
        "tanggal_expired": "2026-08-25",
        "sisa_hari": 18,
        "skema_keahlian": "Software Development / Web Programmer",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Selatan",
        "email": "budi.santoso@lsp.or.id",
        "no_hp": "081234567890"
      }
    ]
  },
  "meta": {
    "total_count": 12,
    "filtered_count": 1,
    "limit": 50,
    "offset": 0
  }
}
```

#### Contoh 2: Status `expired`
```json
{
  "status": "success",
  "message": "Data asesor expired berhasil diambil",
  "data": {
    "status_filter": "expired",
    "total_count": 8,
    "asesor_list": [
      {
        "id": "205",
        "nama_asesor": "Suroso, S.T.",
        "no_met": "MET.000.0008690.2016",
        "status_masa_berlaku": "Expired",
        "tanggal_expired": "2026-07-10",
        "sisa_hari": -28,
        "skema_keahlian": "Network Administrator",
        "provinsi": "Jawa Barat",
        "kabupaten_kota": "Kota Bandung",
        "email": "suroso@gmail.com",
        "no_hp": "08170200777"
      }
    ]
  },
  "meta": {
    "total_count": 8,
    "filtered_count": 1,
    "limit": 50,
    "offset": 0
  }
}
```

---

### 3.3. Deskripsi Schema Fields

| Field Data | Tipe | Keterangan |
|---|---|---|
| `data.status_filter` | String | Kategori filter (`"tenggang"` / `"expired"`) |
| `data.total_count` | Integer | Total asesor pada kategori tersebut |
| `asesor_list[].id` | String | Unique ID record Asesor |
| `asesor_list[].nama_asesor` | String | Nama lengkap asesor beserta gelar |
| `asesor_list[].no_met` | String | Nomor MET / Registrasi Asesor |
| `asesor_list[].status_masa_berlaku` | String | `"Tenggang"` atau `"Expired"` |
| `asesor_list[].tanggal_expired` | String | Format tanggal `YYYY-MM-DD` atau `DD-MM-YYYY` |
| `asesor_list[].sisa_hari` | Integer | Selisih hari menuju expired (>0 = sisa hari, <0 = telah lewat N hari) |
| `asesor_list[].skema_keahlian` | String | Skema kompetensi/keahlian asesor |
| `asesor_list[].provinsi` | String | Nama provinsi domisili asesor |
| `asesor_list[].kabupaten_kota` | String | Nama kota/kabupaten domisili asesor |
| `asesor_list[].email` | String | Email kontak asesor |
| `asesor_list[].no_hp` | String | Nomor HP/Whatsapp asesor |

---

## 4. Format Error Standard

```json
{
  "status": "error",
  "code": "INVALID_PARAMETER",
  "message": "Parameter status wajib diisi dengan tenggang atau expired.",
  "errors": null
}
```

| HTTP Status | Keterangan |
|---:|---|
| `400` | Parameter `status` tidak valid atau kosong |
| `401` | Unauthorized - Token JWT tidak valid atau expired |
| `500` | Internal Server Error - Server gagal memproses request |

---

## 5. Kriteria Penerimaan Backend (Acceptance Criteria)

| ID | Kriteria |
|---|---|
| AC-01 | Endpoint `GET /api/dashboard/masa-berlaku-asesor/detail?status=tenggang` hanya mengembalikan asesor dengan status masa tenggang (< 3 bulan menuju expired). |
| AC-02 | Endpoint `GET /api/dashboard/masa-berlaku-asesor/detail?status=expired` hanya mengembalikan asesor yang sudah habis masa berlakunya. |
| AC-03 | Parameter `search` mendukung pencarian case-insensitive pada nama asesor, nomor MET, skema keahlian, dan kabupaten/kota. |
| AC-04 | Nilai `sisa_hari` dihitung berdasarkan tanggal kalender (Midnight `00:00:00`). |
