# Jadwal Asesi & Asesor - API Documentation

## Endpoints

### 1. Daftar Jadwal Asesi

```http
GET /api/asesi/jadwal
```

Auth: wajib Bearer token. User harus punya role `asesi`.

Nama endpoint sengaja memakai `/api/asesi/jadwal`, bukan `/api/jadwal/my`, agar lebih formal dan konsisten untuk produk nasional.

### 2. Detail Asesor per Jadwal

```http
GET /api/jadwal/:id/asesor-detail
```

Auth: wajib Bearer token.

Mengembalikan detail jadwal, TUK, dan daftar asesor yang ditugaskan dengan profil lengkap dan total asesmen.

### 3. Cek Registrasi Skema Sertifikat

```http
GET /api/sertifikat/skema/:id
```

Response mengandung field `is_already_registered` (boolean) untuk mengecek apakah user sudah terdaftar di skema tertentu.

---

## Headers

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Tidak perlu query parameter `user_id`. Backend mengambil `id_users` otomatis dari JWT claim.

---

## Query Parameters (Jadwal Asesi)

| Parameter | Tipe | Default | Keterangan |
|-----------|------|---------|------------|
| `limit` | integer | `20` | Batas data per page, max `100` |
| `offset` | integer | `0` | Offset pagination |
| `status_jadwal` | string | kosong | Optional, bisa single atau comma-separated. Contoh: `1`, `3,4` |

---

## Status Jadwal

| Status | Arti | Tab Frontend |
|--------|------|-------------|
| `0` | Waiting/Draft | **Mendatang** |
| `1` | Completed/Selesai | **Selesai** |
| `2` | Canceled/Dibatalkan | - |
| `3` | Running/Sedang Berjalan | **Berjalan** |
| `4` | Pelaporan | - |

Tanpa `status_jadwal`, response berisi semua jadwal asesi login dalam satu paket.

---

## Frontend Tab Split

Gunakan filter `status_jadwal` untuk masing-masing tab:

| Tab | Filter |
|-----|--------|
| **Mendatang** | `status_jadwal=0` |
| **Berjalan** | `status_jadwal=3` |
| **Selesai** | `status_jadwal=1` |

Implementasi ada di `lib/screens/jadwal/jadwal_screen.dart`.

---

## Response 200 OK (Jadwal Asesi)

```json
{
  "status": "success",
  "message": "Jadwal asesi retrieved successfully",
  "data": [
    {
      "id": 11153,
      "jadwal": "Asesmen Kompetensi - Programmer Batch 5",
      "tanggal_mulai": "2026-07-10",
      "tanggal_selesai": "2026-07-12",
      "status_jadwal": "3",
      "tuk": "TUK Teknologi Digital",
      "kuota": 20
    }
  ],
  "count": 1
}
```

`count` adalah total jadwal milik asesi yang cocok dengan filter, bukan jumlah item halaman saja.

---

## Response 200 OK (Asesor Detail)

```json
{
  "status": "success",
  "message": "Asesor detail retrieved successfully",
  "data": {
    "jadwal": {
      "id": 11153,
      "jadwal": "Asesmen Kompetensi - Programmer Batch 5",
      "tanggal_mulai": "2026-07-10",
      "tanggal_selesai": "2026-07-12",
      "status_jadwal": "3",
      "tuk": "TUK Teknologi Digital"
    },
    "asesor": [
      {
        "id_asesor": 39,
        "nama": "Muhadi Tri Wusana, S.T., M.Eng.",
        "profesi": "Assesor Mandiri",
        "no_reg": "REG-2024-001",
        "total_asesmen": 372,
        "foto": null,
        "kabupaten": "Kota Bandung",
        "kompetensi": "Ahli Pengembangan Aplikasi",
        "skema": "Skema Sertifikasi Okupasi Programmer"
      }
    ]
  }
}
```

**PENTING**: `total_asesmen` berasal dari `lsp275_mapping_asesor` (hitungan baris), bukan angka hardcoded.

Frontend model `AsesorDetailItem` sudah punya field `totalAsesmen` — jangan pakai nilai statis `100+`.

Implementasi ada di `lib/screens/jadwal/profil_asesor_screen.dart`.

---

## Backend Notes

### Filter Database

| Table | Filter |
|-------|--------|
| `lsp275_jadual_asesmen` | `status_delete = '1'`, `status_aktif = 'Y'` |
| `lsp275_asesi` | `id_users = <jwt_user_id>`, `u_status = 'N'` |
| `lsp275_asesi_2024` | `id_users = <jwt_user_id>`, `u_status = 'N'` |

**Catatan**: `lsp275_asesi` dan `lsp275_asesi_2024` tidak punya kolom `status_delete`. Gunakan `u_status = 'N'`.

### View vs Query Langsung

- `vasesor` — OK untuk profil asesor (nama, kabupaten, kompetensi, skema), tapi **tidak** untuk pengalaman/alamat (field kosong di view).
- `vjadwal_asesor` — **tidak bisa dipakai** karena error `ONLY_FULL_GROUP_BY`. Semua query jadwal pakai raw table joins.

### Demo Account

| Field | Value |
|-------|-------|
| Username | `demo_asesi_001` |
| Password | (isi dari admin) |
| `id_users` | `194329` |

Memiliki 3 jadwal:

| Jadwal | Status | Tab |
|--------|--------|-----|
| `11080` | 0 (Waiting) | Mendatang |
| `11079` | 3 (Running) | Berjalan |
| `11153` | 1 (Completed) | Selesai |

Skema `379` dan `392` sudah terdaftar. Skema `413` belum.

---

## Examples

### Jadwal Asesi

Semua jadwal asesi:
```http
GET /api/asesi/jadwal
Authorization: Bearer <access_token>
```

Jadwal selesai:
```http
GET /api/asesi/jadwal?status_jadwal=1
Authorization: Bearer <access_token>
```

Jadwal berjalan dan pelaporan:
```http
GET /api/asesi/jadwal?status_jadwal=3,4
Authorization: Bearer <access_token>
```

### Asesor Detail

```http
GET /api/jadwal/11153/asesor-detail
Authorization: Bearer <access_token>
```

---

## HTTP Client Files

Contoh request tersedia di backend:
- `api/jadwal_asesi.http`
- `api/jadwal_asesor_detail.http`
