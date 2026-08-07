# API Changes — Frontend Notes

**Last Updated:** 2026-08-07

---

## 🆕 NEW: Detail Domisili Asesor — Daftar Nama-Nama Asesor per Provinsi

**Added:** 2026-08-07

### Endpoint: `GET /api/dashboard/domisili-asesor/:provinsi_id/asesor`

Endpoint ini mengembalikan daftar nama-nama lengkap Asesor yang berdomisili di suatu provinsi tertentu. Digunakan ketika user menekan salah satu card provinsi di Dashboard Domisili Asesor.

#### Path Parameter

| Parameter | Type | Required | Example | Description |
|---|---|---|---|---|
| `provinsi_id` | String | Ya | `31` | ID provinsi (dari `master_provinsi.id`) |

#### Query Parameters

| Parameter | Type | Example | Default | Description |
|---|---|---|---|---|
| `search` | String | `Budi` / `MET.2024` | - | Pencarian nama asesor, nomor MET, skema keahlian, atau kota/kabupaten (case-insensitive) |
| `tipe` | String | `semua` / `internal` / `external` | `semua` | Filter tipe asesor |
| `limit` | Integer | `50` | `50` | Batas jumlah data per halaman (max: 200) |
| `offset` | Integer | `0` | `0` | Posisi offset pagination |

#### Example Request

```http
GET /api/dashboard/domisili-asesor/31/asesor?search=Budi&tipe=internal&limit=50&offset=0
Authorization: Bearer {{token}}
```

#### Response `200 OK`

```json
{
  "status": "success",
  "message": "Data asesor domisili berhasil diambil",
  "data": {
    "provinsi_id": "31",
    "provinsi_nama": "DKI Jakarta",
    "total_asesor": 60,
    "total_internal": 44,
    "total_external": 16,
    "asesor_list": [
      {
        "id": "9",
        "nama_asesor": "Toto Parwono",
        "no_met": "MET.000.003871.2018",
        "tipe_asesor": "Internal",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Timur",
        "email": "totoparwono@gmail.com",
        "no_hp": "081802728279",
        "skema_keahlian": "-",
        "status": "Aktif"
      },
      {
        "id": "25",
        "nama_asesor": "Suroso",
        "no_met": "MET.000.0008690.2016",
        "tipe_asesor": "External",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Selatan",
        "email": "asesorsuroso@gmail.com",
        "no_hp": "0817-0200-777",
        "skema_keahlian": "-",
        "status": "Aktif"
      }
    ]
  },
  "meta": {
    "total_count": 60,
    "filtered_count": 2,
    "limit": 50,
    "offset": 0
  }
}
```

#### Response Fields

| Field | Type | Description |
|---|---|---|
| `data.provinsi_id` | String | ID provinsi |
| `data.provinsi_nama` | String | Nama provinsi |
| `data.total_asesor` | Integer | Total asesor di provinsi (tanpa filter search/tipe) |
| `data.total_internal` | Integer | Total asesor Internal di provinsi |
| `data.total_external` | Integer | Total asesor External di provinsi |
| `data.asesor_list` | Array | Daftar asesor (dipengaruhi filter search & tipe) |
| `asesor_list[].id` | String | ID unik asesor |
| `asesor_list[].nama_asesor` | String | Nama lengkap asesor beserta gelar |
| `asesor_list[].no_met` | String | Nomor MET/Registrasi asesor |
| `asesor_list[].tipe_asesor` | String | `"Internal"` atau `"External"` |
| `asesor_list[].provinsi` | String | Nama provinsi domisili |
| `asesor_list[].kabupaten_kota` | String | Nama kota/kabupaten domisili |
| `asesor_list[].email` | String | Email asesor (atau `"-"` jika kosong) |
| `asesor_list[].no_hp` | String | Nomor HP/WA asesor (atau `"-"` jika kosong) |
| `asesor_list[].skema_keahlian` | String | Bidang/skema kompetensi asesor (atau `"-"` jika kosong) |
| `asesor_list[].status` | String | `"Aktif"` atau `"Inaktif"` |
| `meta.total_count` | Integer | Total asesor di provinsi (tanpa filter) |
| `meta.filtered_count` | Integer | Jumlah hasil setelah filter search & tipe |
| `meta.limit` | Integer | Limit yang diterapkan |
| `meta.offset` | Integer | Offset yang diterapkan |

#### Backend Implementation Notes

- **Tipe Asesor** ditentukan dari field `instansi_asesor_external`:
  - `Internal`: jika `instansi_asesor_external` kosong, NULL, atau mengandung `"LSP Teknologi Digital"` / `"LSP TD"` / `"LSPTD"` / `"Teknologi Digital"`
  - `External`: selain kondisi di atas
- **Search** berlaku pada: `users` (nama asesor), `no_reg` (no MET), `kompetensi_teknis` (skema keahlian), `kabupaten.name` (nama kota/kabupaten)
- **Filter tipe**: `semua` (tanpa filter), `internal`, atau `external`
- **Aggregasi** (`total_asesor`, `total_internal`, `total_external`) dihitung dari seluruh asesor di provinsi tanpa terpengaruh filter search/tipe
- **Pagination** diterapkan pada `asesor_list`
- Hanya asesor dengan `status_aktif='Y'`, `status_delete='1'`, dan `status_asesor='1'` yang ditampilkan

#### Error Responses

```json
{
  "status": "error",
  "code": "INVALID_PARAMETER",
  "message": "provinsi_id is required"
}
```

```json
{
  "status": "error",
  "code": "RESOURCE_NOT_FOUND",
  "message": "Data provinsi atau asesor tidak ditemukan."
}
```

| Status | Penyebab |
|--------|----------|
| 400 | `provinsi_id` tidak ada atau parameter tidak valid |
| 401 | Token JWT tidak valid / expired |
| 404 | Provinsi tidak ditemukan |
| 500 | Kegagalan database/server |

#### Use Case

Frontend dapat mengimplementasikan:
1. **Detail Screen** setelah user tap card provinsi di Dashboard Domisili Asesor
2. **Searchbar** di bagian atas untuk real-time search nama/MET/skema/kota
3. **Tab Filter** untuk memilih tipe asesor (Semua / Internal / External)
4. **Header KPI** menampilkan `total_asesor`, `total_internal`, `total_external`
5. **List Items** menampilkan detail lengkap setiap asesor

---

## HTTP Client Example

```http
### Get asesor list in DKI Jakarta (provinsi_id=31)
GET /api/dashboard/domisili-asesor/31/asesor
Authorization: Bearer {{token}}

### Search asesor with name containing "Budi"
GET /api/dashboard/domisili-asesor/31/asesor?search=Budi
Authorization: Bearer {{token}}

### Filter only external asesor
GET /api/dashboard/domisili-asesor/31/asesor?tipe=external
Authorization: Bearer {{token}}

### Combine search + filter + pagination
GET /api/dashboard/domisili-asesor/31/asesor?search=MET.2024&tipe=internal&limit=20&offset=0
Authorization: Bearer {{token}}
```

---

## Integration Checklist untuk Frontend

- [ ] Implement `DomisiliAsesorDetailScreen` dengan Searchbar di bagian atas
- [ ] Integrate API call `GET /api/dashboard/domisili-asesor/:provinsi_id/asesor`
- [ ] Handle query params: `search`, `tipe`, `limit`, `offset`
- [ ] Display header summary: `total_asesor`, `total_internal`, `total_external`
- [ ] Implement tab filter tipe asesor (Semua / Internal / External)
- [ ] Render list items dengan seluruh field asesor
- [ ] Handle pagination (load more / infinite scroll)
- [ ] Handle empty state ketika `filtered_count = 0`
- [ ] Handle error responses (400, 401, 404, 500)
