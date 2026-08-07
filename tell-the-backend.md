# Kontrak Backend LSP Mobile: Detail Domisili Asesor (Daftar Nama-Nama Asesor per Provinsi)

Dokumen ini **menggantikan secara total (override)** seluruh isi kontrak sebelumnya. Dokumen ini khusus mengatur spesifikasi backend untuk fitur **Detail Domisili Asesor** di mana pengguna menekan salah satu card provinsi domisili pada Dashboard / Statistik, kemudian menampilkan screen berisi daftar nama-nama Asesor berdomisili di provinsi tersebut lengkap dengan Searchbar di bagian atas.

---

## 1. Aturan Bisnis & Alur Kerja

| ID | Aturan |
|---|---|
| BR-01 | Pengguna (Admin / Pengelola / User Dashboard) dapat melihat statistik sebaran domisili asesor per provinsi. |
| BR-02 | Ketika pengguna memilih/menekan salah satu card provinsi domisili, sistem membuka screen tambahan (**Detail Domisili Asesor**). |
| BR-03 | Screen detail wajib menyediakan fitur **Searchbar di bagian atas** untuk mencari nama asesor, nomor MET/Registrasi, skema keahlian, atau kota/kabupaten secara real-time. |
| BR-04 | Backend wajib menyediakan endpoint khusus untuk mengambil daftar nama-nama asesor berdasarkan `provinsi_id` beserta filter pencarian (`search`) dan tipe asesor (`tipe`: `semua`, `internal`, `external`). |
| BR-05 | Setiap item asesor wajib mengembalikan data lengkap: Nama lengkap, Nomor MET/Reg, Tipe Asesor (Internal/External), Kota/Kabupaten, Provinsi, Email, No. HP/WA, Skema Keahlian, dan Status Keaktifan. |

---

## 2. Autentikasi dan Header Request

Endpoint ini membutuhkan autentikasi pengguna:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

---

## 3. Spesifikasi Endpoint API

### 3.1. Daftar Asesor per Provinsi Domisili

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/dashboard/domisili-asesor/:provinsi_id/asesor` | Bearer Token | Mengambil daftar nama-nama asesor berdomisili di provinsi tertentu |

#### Path Parameter:
| Parameter | Tipe | Contoh | Keterangan |
|---|---|---|---|
| `provinsi_id` | String / Integer | `31` | ID unik provinsi domisili |

#### Query Parameters (Opsional):
| Parameter | Tipe | Contoh | Keterangan |
|---|---|---|---|
| `search` | String | `Budi` / `MET.2024` | Filter pencarian berdasarkan nama asesor, nomor MET, skema keahlian, atau kota/kabupaten |
| `tipe` | String | `semua` / `internal` / `external` | Filter tipe keanggotaan asesor (default: `semua`) |
| `limit` | Integer | `50` | Batas jumlah data per halaman (default: `50`) |
| `offset` | Integer | `0` | Posisi offset pagination (default: `0`) |

---

### 3.2. Contoh Response Berhasil (`200 OK`)

```json
{
  "status": "success",
  "message": "Data asesor domisili berhasil diambil",
  "data": {
    "provinsi_id": "31",
    "provinsi_nama": "DKI Jakarta",
    "total_asesor": 15,
    "total_internal": 10,
    "total_external": 5,
    "asesor_list": [
      {
        "id": "1",
        "nama_asesor": "Dr. Ir. Budi Santoso, M.Kom",
        "no_met": "MET.2024.000192",
        "tipe_asesor": "Internal",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Selatan",
        "email": "budi.santoso@lsp.or.id",
        "no_hp": "081234567890",
        "skema_keahlian": "Software Development / Web Programmer",
        "status": "Aktif"
      },
      {
        "id": "2",
        "nama_asesor": "Siti Rahmawati, S.T., M.T.",
        "no_met": "MET.2023.005112",
        "tipe_asesor": "External",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Barat",
        "email": "siti.rahma@gmail.com",
        "no_hp": "081987654321",
        "skema_keahlian": "Digital Marketing Specialist",
        "status": "Aktif"
      }
    ]
  },
  "meta": {
    "total_count": 15,
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
| `provinsi_id` | String | ID Provinsi |
| `provinsi_nama` | String | Nama resmi Provinsi |
| `total_asesor` | Integer | Total jumlah asesor di provinsi tersebut |
| `total_internal` | Integer | Jumlah asesor bertipe Internal |
| `total_external` | Integer | Jumlah asesor bertipe External/Eksternal |
| `asesor_list[].id` | String | Unique ID record asesor |
| `asesor_list[].nama_asesor` | String | Nama lengkap asesor beserta gelar |
| `asesor_list[].no_met` | String | Nomor MET / Nomor Registrasi Asesor |
| `asesor_list[].tipe_asesor` | String | Tipe asesor: `"Internal"` atau `"External"` |
| `asesor_list[].provinsi` | String | Nama provinsi domisili |
| `asesor_list[].kabupaten_kota` | String | Nama kota/kabupaten domisili |
| `asesor_list[].email` | String | Email aktif asesor |
| `asesor_list[].no_hp` | String | Nomor HP/Whatsapp aktif asesor |
| `asesor_list[].skema_keahlian` | String | Bidang / Skema kompetensi keahlian asesor |
| `asesor_list[].status` | String | Status keaktifan asesor (`"Aktif"` / `"Inaktif"`) |

---

## 4. Format Error Standard

```json
{
  "status": "error",
  "code": "RESOURCE_NOT_FOUND",
  "message": "Data provinsi atau asesor tidak ditemukan.",
  "errors": null
}
```

| HTTP Status | Keterangan |
|---:|---|
| `401` | Unauthorized - Token JWT tidak valid atau expired |
| `404` | Not Found - `provinsi_id` tidak ditemukan |
| `500` | Internal Server Error - Server gagal memproses request |

---

## 5. Kriteria Penerimaan Backend (Acceptance Criteria)

| ID | Kriteria |
|---|---|
| AC-01 | Endpoint `GET /api/dashboard/domisili-asesor/:provinsi_id/asesor` mengembalikan daftar nama-nama asesor secara akurat berdasarkan `provinsi_id`. |
| AC-02 | Query parameter `search` mampu melakukan pencarian (case-insensitive) pada field `nama_asesor`, `no_met`, `skema_keahlian`, dan `kabupaten_kota`. |
| AC-03 | Query parameter `tipe` mampu menyaring asesor berdasarkan tipe `internal` atau `external`. |
| AC-04 | Response menyertakan ringkasan `total_asesor`, `total_internal`, dan `total_external` untuk kebutuhan tampilan KPI pada header screen. |
