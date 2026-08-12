# Kontrak & Panduan Integrasi Backend LSP Mobile: Detail Penyebaran Wilayah (Inline Expansion), Detail Asesor Kompetensi Teknis & Masa Berlaku Asesor

Dokumen ini berisi spesifikasi API backend dan panduan integrasi frontend untuk aplikasi LSP Mobile, mencakup:
1. **Fitur Detail Penyebaran Wilayah (Inline Expansion - Tanpa Popup Modal)**
2. **Fitur Detail Asesor Kompetensi Teknis (Berdasarkan Skema)**
3. **Fitur Detail Masa Berlaku Asesor (Status Tenggang & Expired / SPT 2026)**

---

## 1. Fitur 1: Detail Penyebaran Wilayah (Inline Expansion)

### 1.1. Requirement & User Request
> **[Roy Buana]**: "Ketika di klik, gak usah popup. Langsung munculkan di bawah."
> 1. **Jumlah Asesor**: Bidangnya apa saja
> 2. **Jumlah TUK**: Di kabupaten mana saja
> 3. **Jumlah Asesi**: Bidangnya apa saja

### 1.2. Endpoint Specification

* **Base URL:** `GET /api/dashboard/penyebaran-wilayah/detail`
* **Authentication:** Public / Bearer Token Required

#### Query Parameters:

| Parameter | Type | Required | Example | Description |
|-----------|------|----------|---------|-------------|
| `provinsi_id` | String/Int | Yes | `73` | ID/Kode Provinsi |
| `wilayah_id` | String | Optional | `sulawesi` | Kode Wilayah/Pulau (untuk filter tambahan) |

---

### 1.3. Example Request & Response Structure

#### Request Example:
```http
GET /api/dashboard/penyebaran-wilayah/detail?provinsi_id=73
Accept: application/json
```

#### Success Response (`200 OK`):
```json
{
  "status": "success",
  "message": "Data detail penyebaran wilayah berhasil diambil",
  "data": {
    "provinsi_id": 73,
    "nama_provinsi": "Sulawesi Tenggara",
    "summary": {
      "total_asesor": 125,
      "total_tuk": 18,
      "total_asesi": 5363
    },
    "asesor": {
      "total": 125,
      "by_bidang": [
        {
          "bidang_id": "Teknologi Informasi & Komunikasi",
          "nama_bidang": "Teknologi Informasi & Komunikasi",
          "jumlah_asesor": 45
        },
        {
          "bidang_id": "Pemasaran Digital",
          "nama_bidang": "Pemasaran Digital",
          "jumlah_asesor": 30
        },
        {
          "bidang_id": "Manajemen Sumber Daya Manusia",
          "nama_bidang": "Manajemen Sumber Daya Manusia",
          "jumlah_asesor": 50
        }
      ]
    },
    "tuk": {
      "total": 18,
      "by_kabupaten": [
        {
          "kabupaten_id": "7371",
          "nama_kabupaten": "KOTA MAKASSAR",
          "jumlah_tuk": 8
        },
        {
          "kabupaten_id": "7306",
          "nama_kabupaten": "KABUPATEN GOWA",
          "jumlah_tuk": 6
        },
        {
          "kabupaten_id": "7302",
          "nama_kabupaten": "KABUPATEN BULUKUMBA",
          "jumlah_tuk": 4
        }
      ]
    },
    "asesi": {
      "total": 5363,
      "by_bidang": [
        {
          "bidang_id": "Teknologi Informasi & Komunikasi",
          "nama_bidang": "Teknologi Informasi & Komunikasi",
          "jumlah_asesi": 2800
        },
        {
          "bidang_id": "Pemasaran Digital",
          "nama_bidang": "Pemasaran Digital",
          "jumlah_asesi": 1563
        },
        {
          "bidang_id": "Manajemen Sumber Daya Manusia",
          "nama_bidang": "Manajemen Sumber Daya Manusia",
          "jumlah_asesi": 1000
        }
      ]
    }
  }
}
```

#### Error Response (`400 Bad Request`):
```json
{
  "status": "error",
  "code": "INVALID_PARAMETER",
  "message": "provinsi_id is required",
  "errors": null
}
```

#### Error Response (`404 Not Found`):
```json
{
  "status": "error",
  "code": "RESOURCE_NOT_FOUND",
  "message": "Data wilayah tidak ditemukan.",
  "errors": null
}
```

#### Error Response (`500 Internal Server Error`):
```json
{
  "status": "error",
  "code": "INTERNAL_SERVER_ERROR",
  "message": "Terjadi kesalahan pada server.",
  "errors": null
}
```

---

### 1.4. Data Schema

#### Data Object Schema
| Field | Type | Description |
|---|---|---|
| `provinsi_id` | Integer/String | ID/Kode Provinsi |
| `nama_provinsi` | String | Nama resmi provinsi |
| `summary` | Object | Akumulasi total Asesor, TUK, Asesi |
| `asesor` | Object | `total` (Integer) & `by_bidang` (Array of AsesorBidangItem) |
| `tuk` | Object | `total` (Integer) & `by_kabupaten` (Array of TUKKabupatenItem) |
| `asesi` | Object | `total` (Integer) & `by_bidang` (Array of AsesiBidangItem) |

---

### 1.5. UI/UX & Interaction Requirements

* **TIDAK BOLEH: Popup Modal**
  * DILARANG menampilkan data detail dalam popup modal terpisah.
* **WAJIB: Inline Expansion (Accordion)**
  * Data detail harus muncul langsung di bawah (*inline expansion / accordion*) dari card/wilayah yang diklik.

#### Interaction Flow:
1. User menekan card provinsi (misal: "Sulawesi Tenggara")
2. Tanpa popup modal, card tersebut expand ke bawah.
3. Tampilkan 3 section breakdown:
   - **Jumlah Asesor** (per Bidang/Skema)
   - **Jumlah TUK** (per Kabupaten/Kota)
   - **Jumlah Asesi** (per Bidang/Skema)

#### Recommended Layout:
```text
┌─────────────────────────────────────────────────────────────┐
│ Sulawesi Tenggara                                      [▲]  │
│ 125 Asesor  •  18 TUK  •  5,363 Asesi                       │
├─────────────────────────────────────────────────────────────┤
│ 👤 Jumlah Asesor (125)                                      │
│   • Teknologi Informasi & Komunikasi: 45                    │
│   • Pemasaran Digital: 30                                   │
│   • Manajemen SDM: 50                                       │
│                                                             │
│ 🏢 Jumlah TUK (18)                                          │
│   • KOTA MAKASSAR: 8                                        │
│   • KABUPATEN GOWA: 6                                       │
│   • KABUPATEN BULUKUMBA: 4                                  │
│                                                             │
│ 👨‍🎓 Jumlah Asesi (5,363)                                    │
│   • Teknologi Informasi & Komunikasi: 2,800                 │
│   • Pemasaran Digital: 1,563                                │
│   • Manajemen SDM: 1,000                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Fitur 2: Detail Asesor Kompetensi Teknis (Berdasarkan Skema)

### 2.1. Aturan Bisnis
* Pengguna dapat melihat statistik Kompetensi Teknis berdasarkan skema sertifikasi.
* Menekan salah satu **Skema Sertifikasi** membuka screen detail yang menampilkan daftar Asesor yang memiliki kompetensi pada skema tersebut.
* Memiliki **Searchbar** di bagian atas (nama, MET, email, kota/kabupaten, provinsi) dan filter status (`semua`, `aktif`, `tenggang`, `expired`).

### 2.2. Spesifikasi Endpoint API
* **Endpoint:** `GET /api/dashboard/kompetensi-teknis/{skema_id}/asesor`
* **Query Parameters:** `search`, `status` (`semua`/`aktif`/`tenggang`/`expired`), `limit`, `offset`.

#### Contoh Response Berhasil (`200 OK`):
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
      }
    ]
  },
  "meta": {
    "total_count": 86,
    "filtered_count": 1,
    "limit": 50,
    "offset": 0
  }
}
```

---

## 3. Fitur 3: Detail Masa Berlaku Asesor (Status Tenggang & Expired / SPT 2026)

### 3.1. Aturan Bisnis
* Menekan card **Masa Tenggang** atau **Expired** membuka screen detail berisi daftar nama-nama Asesor terkait.

### 3.2. Spesifikasi Endpoint API
* **Endpoint:** `GET /api/dashboard/masa-berlaku-asesor/detail`
* **Query Parameters:** `status` (`tenggang`/`expired`), `search`, `limit`, `offset`.

---

## 4. Implementation & Testing Checklist

### Implementation Checklist
- **API Integration:**
  - Fungsi fetch `fetchPenyebaranWilayahDetail(provinsiId)`
  - Loading state & Error handling inline
  - Caching response untuk mencegah re-fetch berulang
- **UI Components:**
  - `WilayahCard` dengan state `isExpanded`
  - Toggle expand/collapse tanpa modal popup
  - Sub-komponen `AsesorBidangList`, `TUKKabupatenList`, `AsesiBidangList`
- **UX & Performance:**
  - Lazy load data saat expand pertama kali
  - Smooth animation expand/collapse
  - Empty state jika breakdown kosong ("Tidak ada data")

### Testing Checklist
- Test dengan `provinsi_id` valid & invalid
- Test provinsi dengan data 0 asesor / 0 TUK / 0 asesi
- Verify ketiadaan popup modal saat card diklik
