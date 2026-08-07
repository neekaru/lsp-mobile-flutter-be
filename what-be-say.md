# API Changes — Frontend Notes

**Last Updated:** 2026-08-07

---

## 🆕 NEW: Detail Masa Berlaku Asesor — Daftar Asesor Masa Tenggang & Expired

**Added:** 2026-08-07

### Endpoint: `GET /api/dashboard/masa-berlaku-asesor/detail`

Endpoint ini mengembalikan daftar nama-nama Asesor yang berada dalam status **Masa Tenggang** atau **Expired**. Digunakan ketika Admin/Pengelola menekan card Masa Tenggang atau Expired pada statistik Masa Berlaku Asesor.

#### Query Parameters (Required)

| Parameter | Type | Required | Example | Default | Description |
|---|---|---|---|---|---|
| `status` | String | **Ya** | `tenggang` / `expired` | - | Kategori status masa berlaku (**wajib**: `tenggang` atau `expired`) |
| `search` | String | Tidak | `Budi` / `MET.2024` | - | Pencarian nama asesor, nomor MET, skema keahlian, atau kota/kabupaten (case-insensitive) |
| `limit` | Integer | Tidak | `50` | `50` | Batas jumlah data per halaman (max: 200) |
| `offset` | Integer | Tidak | `0` | `0` | Posisi offset pagination |

#### Example Request

```http
### Get asesor masa tenggang
GET /api/dashboard/masa-berlaku-asesor/detail?status=tenggang&limit=50&offset=0
Authorization: Bearer {{token}}

### Get asesor expired with search
GET /api/dashboard/masa-berlaku-asesor/detail?status=expired&search=Abdul
Authorization: Bearer {{token}}
```

#### Response `200 OK` — Status Tenggang

```json
{
  "status": "success",
  "message": "Data asesor masa tenggang berhasil diambil",
  "data": {
    "status_filter": "tenggang",
    "total_count": 45,
    "asesor_list": [
      {
        "id": "1329",
        "nama_asesor": "Sri Defi Isnaeni",
        "no_met": "MET.000.005857 2023",
        "status_masa_berlaku": "Tenggang",
        "tanggal_expired": "2026-08-11",
        "sisa_hari": 4,
        "skema_keahlian": "-",
        "provinsi": "Jawa Barat",
        "kabupaten_kota": "Kota Depok",
        "email": "defi.isnaeni@nurulfikri.ac.id",
        "no_hp": "087785651764"
      },
      {
        "id": "1326",
        "nama_asesor": "Yuliadi",
        "no_met": "MET.000.005851.2023",
        "status_masa_berlaku": "Tenggang",
        "tanggal_expired": "2026-08-11",
        "sisa_hari": 4,
        "skema_keahlian": "-",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Timur",
        "email": "yuliadi@nurulfikri.ac.id",
        "no_hp": "081232275321"
      }
    ]
  },
  "meta": {
    "total_count": 45,
    "filtered_count": 2,
    "limit": 50,
    "offset": 0
  }
}
```

#### Response `200 OK` — Status Expired

```json
{
  "status": "success",
  "message": "Data asesor expired berhasil diambil",
  "data": {
    "status_filter": "expired",
    "total_count": 343,
    "asesor_list": [
      {
        "id": "204",
        "nama_asesor": "Muhammad Aldi Azmy",
        "no_met": "MET.000.002.808 2020",
        "status_masa_berlaku": "Expired",
        "tanggal_expired": "2026-08-07",
        "sisa_hari": 0,
        "skema_keahlian": "-",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Selatan",
        "email": "-",
        "no_hp": "6285959480951"
      },
      {
        "id": "72",
        "nama_asesor": "Abdul Haris Hanifudin",
        "no_met": "MET.000.002915.2020",
        "status_masa_berlaku": "Expired",
        "tanggal_expired": "2026-07-28",
        "sisa_hari": -10,
        "skema_keahlian": "-",
        "provinsi": "DKI Jakarta",
        "kabupaten_kota": "Kota Jakarta Timur",
        "email": "hanifudin.net@gmail.com",
        "no_hp": "082130077000"
      }
    ]
  },
  "meta": {
    "total_count": 343,
    "filtered_count": 2,
    "limit": 50,
    "offset": 0
  }
}
```

#### Response Fields

| Field | Type | Description |
|---|---|---|
| `data.status_filter` | String | Kategori filter (`"tenggang"` atau `"expired"`) |
| `data.total_count` | Integer | Total asesor pada kategori tersebut (tanpa filter search) |
| `data.asesor_list` | Array | Daftar asesor (dipengaruhi filter search) |
| `asesor_list[].id` | String | ID unik asesor |
| `asesor_list[].nama_asesor` | String | Nama lengkap asesor beserta gelar |
| `asesor_list[].no_met` | String | Nomor MET/Registrasi asesor |
| `asesor_list[].status_masa_berlaku` | String | `"Tenggang"` atau `"Expired"` |
| `asesor_list[].tanggal_expired` | String | Tanggal expired (format: `YYYY-MM-DD`) |
| `asesor_list[].sisa_hari` | Integer | Selisih hari menuju expired. **Positif** = sisa hari, **Negatif** = telah lewat N hari, **0** = expired hari ini |
| `asesor_list[].skema_keahlian` | String | Bidang/skema kompetensi asesor (atau `"-"` jika kosong) |
| `asesor_list[].provinsi` | String | Nama provinsi domisili (atau `"-"` jika kosong) |
| `asesor_list[].kabupaten_kota` | String | Nama kota/kabupaten domisili (atau `"-"` jika kosong) |
| `asesor_list[].email` | String | Email asesor (atau `"-"` jika kosong) |
| `asesor_list[].no_hp` | String | Nomor HP/WA asesor (atau `"-"` jika kosong) |
| `meta.total_count` | Integer | Total asesor pada kategori status (tanpa filter search) |
| `meta.filtered_count` | Integer | Jumlah hasil setelah filter search |
| `meta.limit` | Integer | Limit yang diterapkan |
| `meta.offset` | Integer | Offset yang diterapkan |

#### Backend Implementation Notes

- **Status Tenggang**: `tgl_expired > CURDATE()` AND `DATEDIFF(tgl_expired, CURDATE()) <= 90` (kurang dari 3 bulan)
- **Status Expired**: `tgl_expired <= CURDATE()` (sudah habis masa berlaku)
- **Perhitungan sisa_hari**: menggunakan `DATEDIFF(tgl_expired, CURDATE())` berdasarkan tanggal kalender Midnight `00:00:00`
- **Search** berlaku pada: `users` (nama asesor), `no_reg` (no MET), `kompetensi_teknis` (skema keahlian), `kabupaten.name` (nama kota/kabupaten)
- **Ordering**:
  - Tenggang: ASC (yang terdekat expire duluan)
  - Expired: DESC (yang paling baru expire duluan)
- **Data Real**:
  - Total Tenggang: **45 asesor**
  - Total Expired: **343 asesor**
- Hanya asesor dengan `status_aktif='Y'`, `status_delete='1'`, `tgl_expired IS NOT NULL`, dan `tgl_expired != '1970-01-01'` yang ditampilkan

#### Error Responses

```json
{
  "status": "error",
  "code": "INVALID_PARAMETER",
  "message": "Parameter status wajib diisi dengan tenggang atau expired."
}
```

| Status | Penyebab |
|--------|----------|
| 400 | Parameter `status` tidak valid, kosong, atau bukan `tenggang`/`expired` |
| 401 | Token JWT tidak valid / expired |
| 500 | Kegagalan database/server |

#### Use Case

Frontend dapat mengimplementasikan:
1. **Detail Screen** setelah user tap card **Masa Tenggang** atau **Expired** di statistik Masa Berlaku Asesor
2. **Searchbar** di bagian atas untuk real-time search nama/MET/skema/kota
3. **Header KPI** menampilkan `total_count` (total asesor dalam kategori)
4. **List Items** menampilkan detail lengkap setiap asesor dengan badge status dan sisa_hari
5. **Badge Visual**:
   - Tenggang: tampilkan `sisa_hari` dengan warning color (e.g., "4 hari lagi")
   - Expired: tampilkan `sisa_hari` negatif dengan danger color (e.g., "10 hari lewat")
6. **Empty State** untuk kategori yang tidak ada data

---

## HTTP Client Examples

```http
### Get asesor masa tenggang (< 3 bulan)
GET /api/dashboard/masa-berlaku-asesor/detail?status=tenggang
Authorization: Bearer {{token}}

### Get asesor expired
GET /api/dashboard/masa-berlaku-asesor/detail?status=expired
Authorization: Bearer {{token}}

### Search asesor tenggang with name "Sri"
GET /api/dashboard/masa-berlaku-asesor/detail?status=tenggang&search=Sri
Authorization: Bearer {{token}}

### Search asesor expired with pagination
GET /api/dashboard/masa-berlaku-asesor/detail?status=expired&search=Abdul&limit=20&offset=0
Authorization: Bearer {{token}}
```

---

## Integration Checklist untuk Frontend

- [ ] Implement `MasaBerlakuAsesorDetailScreen` dengan Searchbar di bagian atas
- [ ] Integrate API call `GET /api/dashboard/masa-berlaku-asesor/detail`
- [ ] Handle **required** query param `status` (`tenggang` atau `expired`)
- [ ] Handle optional query params: `search`, `limit`, `offset`
- [ ] Display header KPI: `total_count`
- [ ] Render list items dengan seluruh field asesor
- [ ] Display badge `status_masa_berlaku` dengan visual indicator:
  - **Tenggang**: warning color (orange/yellow)
  - **Expired**: danger color (red)
- [ ] Display `sisa_hari` dengan format:
  - Positif: "N hari lagi"
  - Negatif: "N hari lewat"
  - 0: "Expired hari ini"
- [ ] Handle pagination (load more / infinite scroll)
- [ ] Handle empty state ketika `filtered_count = 0`
- [ ] Handle error responses (400, 401, 500)
- [ ] Validate `status` parameter sebelum API call (harus `tenggang` atau `expired`)
