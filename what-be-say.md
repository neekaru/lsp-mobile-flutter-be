# API Changes — Frontend Notes

**Last Updated:** 2026-08-08

---

## 🆕 NEW: Detail Asesor Kompetensi Teknis per Skema Sertifikasi

**Added:** 2026-08-08

### Endpoint: `GET /api/dashboard/kompetensi-teknis/{skema_id}/asesor`

Endpoint ini mengembalikan daftar nama-nama Asesor yang terdaftar/memiliki kompetensi dalam suatu Skema Sertifikasi. Digunakan ketika Admin/Pengelola menekan salah satu Skema Sertifikasi pada statistik Kompetensi Teknis.

#### Path Parameters

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| `skema_id` | String/Int | **Ya** | `379` atau `SKK-36-10/2024` | ID atau Kode Skema Sertifikasi |

#### Query Parameters

| Parameter | Type | Required | Example | Default | Description |
|---|---|---|---|---|---|
| `status` | String | Tidak | `semua` / `aktif` / `tenggang` / `expired` | `semua` | Filter status masa berlaku asesor dalam skema |
| `search` | String | Tidak | `Budi` / `MET.2024` / `Jakarta` | - | Pencarian nama asesor, nomor MET, domisili, email, atau no HP (case-insensitive) |
| `limit` | Integer | Tidak | `50` | `50` | Batas jumlah data per halaman (max: 1000) |
| `offset` | Integer | Tidak | `0` | `0` | Posisi offset pagination |

#### Example Requests

```http
### Get semua asesor skema Pemasaran Digital (skema_id=379)
GET /api/dashboard/kompetensi-teknis/379/asesor
Authorization: Bearer {{token}}

### Get asesor skema by kode_skema
GET /api/dashboard/kompetensi-teknis/SKK-36-10/2024/asesor
Authorization: Bearer {{token}}

### Filter status aktif only
GET /api/dashboard/kompetensi-teknis/379/asesor?status=aktif
Authorization: Bearer {{token}}

### Filter status tenggang (masa berlaku < 90 hari)
GET /api/dashboard/kompetensi-teknis/379/asesor?status=tenggang
Authorization: Bearer {{token}}

### Filter status expired
GET /api/dashboard/kompetensi-teknis/379/asesor?status=expired
Authorization: Bearer {{token}}

### Search asesor by name
GET /api/dashboard/kompetensi-teknis/379/asesor?search=Hasdar
Authorization: Bearer {{token}}

### Search asesor by provinsi
GET /api/dashboard/kompetensi-teknis/379/asesor?search=Sulawesi
Authorization: Bearer {{token}}

### Kombinasi filter + search + pagination
GET /api/dashboard/kompetensi-teknis/379/asesor?status=tenggang&search=Sulawesi&limit=20&offset=0
Authorization: Bearer {{token}}
```

#### Response `200 OK`

```json
{
  "status": "success",
  "message": "Data detail asesor kompetensi teknis berhasil diambil",
  "data": {
    "skema_id": 379,
    "kode_skema": "SKK-36-10/2024",
    "nama_skema": "Pemasaran Digital",
    "total_asesor": 73,
    "asesor_list": [
      {
        "id": "767",
        "nama_asesor": "Hasdar Hanafi",
        "no_met": "MET.000.007183.2023",
        "status_masa_berlaku": "Aktif",
        "tanggal_expired": "2027-03-22",
        "provinsi": "SULAWESI SELATAN",
        "kabupaten_kota": "KOTA MAKASSAR",
        "email": "ashaeducationcentre22@gmail.com",
        "no_hp": "085840200305",
        "tipe_asesor": "Internal"
      },
      {
        "id": "520",
        "nama_asesor": "Harson Kapoh",
        "no_met": "MET.000.001091 2019",
        "status_masa_berlaku": "Aktif",
        "tanggal_expired": "2028-04-22",
        "provinsi": "SULAWESI UTARA",
        "kabupaten_kota": "KABUPATEN MINAHASA",
        "email": "hvskapoh@gmail.com",
        "no_hp": "-",
        "tipe_asesor": "Internal"
      },
      {
        "id": "763",
        "nama_asesor": "Danang Santoso",
        "no_met": "MET.000.007179.2023",
        "status_masa_berlaku": "Tenggang",
        "tanggal_expired": "2026-09-22",
        "provinsi": "SULAWESI SELATAN",
        "kabupaten_kota": "KOTA MAKASSAR",
        "email": "danang@example.com",
        "no_hp": "081234567890",
        "tipe_asesor": "Internal"
      }
    ]
  },
  "meta": {
    "total_count": 73,
    "filtered_count": 3,
    "limit": 50,
    "offset": 0
  }
}
```

#### Response Fields

| Field | Type | Description |
|---|---|---|
| `data.skema_id` | Integer | ID Skema Sertifikasi |
| `data.kode_skema` | String | Kode resmi skema sertifikasi (e.g., `"SKK-36-10/2024"`) |
| `data.nama_skema` | String | Judul/nama skema kompetensi teknis (e.g., `"Pemasaran Digital"`) |
| `data.total_asesor` | Integer | Total keseluruhan asesor pada skema tersebut (tanpa filter) |
| `data.asesor_list` | Array | Daftar asesor (dipengaruhi filter status + search) |
| `asesor_list[].id` | String | Unique ID record Asesor |
| `asesor_list[].nama_asesor` | String | Nama lengkap asesor beserta gelar |
| `asesor_list[].no_met` | String | Nomor MET / Registrasi Asesor |
| `asesor_list[].status_masa_berlaku` | String | `"Aktif"`, `"Tenggang"`, atau `"Expired"` |
| `asesor_list[].tanggal_expired` | String | Format tanggal `YYYY-MM-DD` |
| `asesor_list[].provinsi` | String | Nama provinsi domisili asesor (atau `""` jika kosong) |
| `asesor_list[].kabupaten_kota` | String | Nama kota/kabupaten domisili asesor (atau `""` jika kosong) |
| `asesor_list[].email` | String | Email kontak asesor (atau `""` jika kosong) |
| `asesor_list[].no_hp` | String | Nomor HP/Whatsapp asesor (atau `"-"` jika kosong) |
| `asesor_list[].tipe_asesor` | String | `"Internal"` atau `"External"` |
| `meta.total_count` | Integer | Total asesor di skema ini (tanpa filter search/status) |
| `meta.filtered_count` | Integer | Jumlah hasil setelah filter status + search |
| `meta.limit` | Integer | Limit yang diterapkan |
| `meta.offset` | Integer | Offset yang diterapkan |

#### Backend Implementation Notes

- **Path Parameter**: endpoint bisa menerima `skema_id` (numerik) atau `kode_skema` (string seperti `SKK-36-10/2024`)
- **Status Filter**:
  - `semua`: tanpa filter status (default)
  - `aktif`: `tgl_expired >= CURDATE()` AND `DATEDIFF(tgl_expired, CURDATE()) > 90`
  - `tenggang`: `tgl_expired >= CURDATE()` AND `DATEDIFF(tgl_expired, CURDATE()) <= 90`
  - `expired`: `tgl_expired IS NULL` OR `tgl_expired < CURDATE()`
- **Search**: berlaku pada `users` (nama asesor), `no_reg` (no MET), `email`, `hp`, `provinsi.name`, `kabupaten.name` (case-insensitive)
- **Ordering**: ASC by `users` (nama asesor)
- **Data Source**: join `t_teknis_asesor` ↔ `lsp275_users` ↔ `master_provinsi` ↔ `master_kabupaten`

#### Testing Results (READ-ONLY SQL Verification)

- **Skema 379 (Pemasaran Digital)**: 73 asesor total
  - Aktif: 58 asesor
  - Tenggang: 3 asesor
  - Expired: 12 asesor
- **Skema 335 (Network Administrator Muda)**: 20 asesor total
- **Search "hasdar"**: 1 result (Hasdar Hanafi)
- **Search "sulawesi"**: 5 results
- **Filter `status=tenggang` + Search "sulawesi"**: 2 results (Danang Santoso, Seftian Hidayat)
- **Pagination**: LIMIT 5 OFFSET 0 → Abdul Azis, Abdul Haris, Abdul Rahman, Aditya, Agus
- **Pagination**: LIMIT 5 OFFSET 5 → Ali Ridho, Andi Hasad, Andi Indra, ANDI RIZA, Anis

#### Error Responses

```json
// 404 - Skema tidak ditemukan
{
  "status": "error",
  "code": "RESOURCE_NOT_FOUND",
  "message": "Skema sertifikasi tidak ditemukan.",
  "errors": null
}

// 400 - Parameter tidak valid
{
  "status": "error",
  "code": "INVALID_REQUEST",
  "message": "limit must be between 1 and 1000",
  "errors": null
}
```

| Status | Penyebab |
|--------|----------|
| 400 | Parameter `limit` atau `offset` tidak valid |
| 401 | Token JWT tidak valid / expired |
| 404 | Skema ID/kode tidak ditemukan di database |
| 500 | Kegagalan database/server |

#### Use Case

Frontend dapat mengimplementasikan:
1. **Detail Screen** setelah user tap salah satu card Skema pada statistik Kompetensi Teknis
2. **Header Info** menampilkan: `kode_skema`, `nama_skema`, dan `total_asesor`
3. **Searchbar** di bagian atas untuk real-time search nama/MET/email/domisili
4. **Filter Tabs/Chips** untuk status: Semua (default), Aktif, Tenggang, Expired
5. **List Items** menampilkan detail lengkap setiap asesor dengan badge status
6. **Badge Visual**:
   - Aktif: success/green color
   - Tenggang: warning/orange color (masa berlaku < 90 hari)
   - Expired: danger/red color
7. **Pagination** (load more / infinite scroll) menggunakan `limit` + `offset`
8. **Empty State** untuk filter yang tidak ada data

---

## HTTP Client Examples

```http
### Get all asesor for skema 379
GET /api/dashboard/kompetensi-teknis/379/asesor
Authorization: Bearer {{token}}

### Get asesor by kode skema
GET /api/dashboard/kompetensi-teknis/SKK-36-10/2024/asesor
Authorization: Bearer {{token}}

### Filter aktif only
GET /api/dashboard/kompetensi-teknis/379/asesor?status=aktif
Authorization: Bearer {{token}}

### Filter tenggang only
GET /api/dashboard/kompetensi-teknis/379/asesor?status=tenggang
Authorization: Bearer {{token}}

### Search by name
GET /api/dashboard/kompetensi-teknis/379/asesor?search=Hasdar
Authorization: Bearer {{token}}

### Search by province
GET /api/dashboard/kompetensi-teknis/379/asesor?search=Sulawesi
Authorization: Bearer {{token}}

### Combine filter + search + pagination
GET /api/dashboard/kompetensi-teknis/379/asesor?status=tenggang&search=Sulawesi&limit=20&offset=0
Authorization: Bearer {{token}}

### Pagination - page 2
GET /api/dashboard/kompetensi-teknis/379/asesor?limit=20&offset=20
Authorization: Bearer {{token}}
```

---

## Integration Checklist untuk Frontend

- [ ] Implement `KompetensiTeknisDetailScreen` dengan Searchbar dan Filter Tabs
- [ ] Integrate API call `GET /api/dashboard/kompetensi-teknis/{skema_id}/asesor`
- [ ] Handle **required** path param `skema_id` (bisa ID numerik atau kode string)
- [ ] Handle optional query params: `status`, `search`, `limit`, `offset`
- [ ] Display header info: `kode_skema`, `nama_skema`, `total_asesor` (KPI)
- [ ] Implement filter tabs/chips: Semua (default), Aktif, Tenggang, Expired
- [ ] Implement real-time searchbar (debounced search on nama/MET/domisili/email/hp)
- [ ] Render list items dengan seluruh field asesor
- [ ] Display badge `status_masa_berlaku` dengan visual indicator:
  - **Aktif**: success/green color
  - **Tenggang**: warning/orange color
  - **Expired**: danger/red color
- [ ] Display contact info: email (link to mailto), no_hp (link to WhatsApp if not "-")
- [ ] Display domisili: `kabupaten_kota, provinsi`
- [ ] Handle pagination (load more / infinite scroll)
- [ ] Handle empty state ketika `filtered_count = 0`
- [ ] Handle error responses (400, 401, 404, 500)
- [ ] Validate `skema_id` path param before API call
- [ ] Show loading state during API call
- [ ] Cache response per skema_id untuk performa (optional)

---

## Backend Files Created/Modified

**Created:**
1. `internal/entity/kompetensi_teknis_entity.go`
2. `internal/model/kompetensi_teknis_model.go`
3. `internal/repository/kompetensi_teknis_repository.go`
4. `internal/usecase/kompetensi_teknis_usecase.go`
5. `internal/delivery/http/kompetensi_teknis_controller.go`

**Modified:**
1. `internal/config/app.go` - registrasi repository, usecase, controller
2. `internal/delivery/http/route/route.go` - route baru

**Database Tables Used (READ-ONLY):**
- `t_teknis_asesor` - relasi asesor ↔ skema
- `lsp275_users` - data asesor
- `lsp275_skema` - data skema
- `master_provinsi` - data provinsi
- `master_kabupaten` - data kabupaten/kota

---

**Notes untuk Frontend Developer:**
- Endpoint ini **tidak mengubah database** (READ-ONLY operation)
- Response sudah diuji dengan data real: skema 379 memiliki 73 asesor (58 aktif, 3 tenggang, 12 expired)
- Search case-insensitive dan mendukung partial match
- Pagination dengan kombinasi `limit` + `offset`
- Filter status dan search bisa dikombinasikan
