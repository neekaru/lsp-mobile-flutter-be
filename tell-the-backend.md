# Rekomendasi Asesor Berdasarkan Skema - API Proposal

Halo Tim Backend! Kami membutuhkan endpoint baru untuk mengambil daftar asesor yang direkomendasikan berdasarkan skema sertifikasi yang dipilih oleh asesi setelah proses konfirmasi pendaftaran.

---

## 🔍 Endpoint: Daftar Asesor per Skema

```http
GET /api/sertifikat/skema/:id/asesor
```

### Headers

```http
Authorization: Bearer <access_token>
Accept: application/json
```

### Deskripsi
Mengembalikan daftar asesor yang memiliki kompetensi sesuai dengan skema sertifikasi (`:id` di URL mewakili `id_skema`). Data ini digunakan untuk menampilkan halaman rekomendasi asesor di frontend sebelum asesi masuk ke langkah Pra-Asesmen.

---

## 📥 Response Format (200 OK)

```json
{
  "status": "success",
  "message": "Asesor list retrieved successfully",
  "data": [
    {
      "id_asesor": 1,
      "nama_asesor": "Eko Setiabudi",
      "no_reg": "REG-2024-001",
      "email": "eko.setiabudi@lsp.id",
      "hp": "081234567890",
      "jenis_asesmen": "Mandiri",
      "status_spt": "1",
      "is_complete": "1",
      "masa_berlaku": "2028-12-31",
      "kabupaten_kota": "Yogyakarta",
      "provinsi_id": "34",
      "kabupaten_id": "3471",
      "total_asesmen": 145
    },
    {
      "id_asesor": 2,
      "nama_asesor": "Hadi Dayat",
      "no_reg": "REG-2024-002",
      "email": "hadi.dayat@lsp.id",
      "hp": "081234567891",
      "jenis_asesmen": "Mandiri",
      "status_spt": "1",
      "is_complete": "1",
      "masa_berlaku": "2028-12-31",
      "kabupaten_kota": "Jakarta",
      "provinsi_id": "31",
      "kabupaten_id": "3171",
      "total_asesmen": 210
    }
  ]
}
```

---

## 🛠️ Catatan Backend (GORM / SQL Query Reference)
* Data asesor disaring berdasarkan kompetensi skema (bisa diambil dari pemetaan `lsp275_mapping_asesor` atau tabel keahlian asesor yang terkait dengan `id_skema`).
* Pastikan field `total_asesmen` dihitung secara dinamis dari jumlah baris aktivitas asesmen yang dilakukan oleh asesor tersebut.
* Di sisi frontend, kami menyediakan mock fallback jika endpoint ini belum di-deploy di production.
