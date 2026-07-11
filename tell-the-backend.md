# Penugasan & Detail Peserta Asesor - API Contract & Documentation

Dokumen ini mendefinisikan seluruh endpoint API yang dibutuhkan oleh modul **Penugasan** pada aplikasi mobile, mencakup daftar jadwal penugasan, detail penugasan, daftar peserta, dan detail kelengkapan/status asesmen masing-masing peserta.

Semua endpoint berikut bersifat privat dan hanya dapat diakses oleh user dengan role `asesor`. Backend wajib mengambil identitas asesor dari JWT token untuk memvalidasi kepemilikan jadwal penugasan.

---

## Headers Utama

```http
Authorization: Bearer <access_token>
Accept: application/json
```

---

## 1. Penugasan (Daftar Jadwal Saya)

Menampilkan daftar jadwal penugasan ujian sertifikasi yang ditugaskan kepada Asesor yang sedang login.

```http
GET /api/asesor/jadwal?status_jadwal=:status
```

### Query Parameters

| Parameter | Tipe | Keterangan |
|---|---|---|
| `status_jadwal` | String | Memfilter status jadwal. Nilai yang diperbolehkan:<br>- `0` : Menunggu / Aktif<br>- `1,4` : Selesai / Pelaporan<br>- `2` : Dibatalkan |

### Contoh Request

```http
GET /api/asesor/jadwal?status_jadwal=0
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Asesor schedules retrieved successfully",
  "data": [
    {
      "id": 11152,
      "nama_jadwal": "Sertifikasi Junior Web Developer",
      "tanggal": "2026-07-24",
      "tanggal_akhir": "2026-07-27",
      "status_jadwal": "0",
      "tuk": "LPP Cahaya Borneo",
      "jumlah_peserta": 54
    }
  ],
  "count": 1
}
```

---

## 2. Detail Penugasan

Menampilkan informasi rinci dari jadwal penugasan tertentu, termasuk waktu, lokasi TUK, dan nama lead asesor.

```http
GET /api/asesor/jadwal/:id/detail
```

### Contoh Request

```http
GET /api/asesor/jadwal/11152/detail
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Assessor schedule detail retrieved successfully",
  "data": {
    "status_label": "Menunggu",
    "tanggal_asesmen": "2026-07-24",
    "waktu_asesmen": "09:00 - 12:00 WIB",
    "lokasi_asesmen": "Gedung A Lantai 2, Kota Yogyakarta",
    "jumlah_peserta": 54,
    "lead_asesor": "Eko Setiabudi",
    "nama_jadwal": "Sertifikasi Junior Web Developer",
    "tuk": "LPP Cahaya Borneo"
  }
}
```

### Keterangan Field Response

| Field | Tipe | Keterangan |
|---|---|---|
| `status_label` | String | Label status (`Menunggu`, `Selesai`, `Dibatalkan`, `Berlangsung`, `Pelaporan`) |
| `tanggal_asesmen` | String | Tanggal pelaksanaan format `YYYY-MM-DD` |
| `waktu_asesmen` | String | Waktu pelaksanaan (contoh: `"09:00 - 12:00 WIB"`) |
| `lokasi_asesmen` | String | Alamat lengkap Tempat Uji Kompetensi (TUK) |
| `jumlah_peserta` | Integer| Total peserta terdaftar dalam jadwal penugasan ini |
| `lead_asesor` | String | Nama ketua asesor pelaksana |

---

## 3. Daftar Peserta (Jadwal Asesi List)

Menampilkan daftar peserta (asesi) yang mengikuti sertifikasi pada jadwal penugasan tersebut beserta ringkasan status kelulusan (Kompeten/Belum Kompeten/Belum Dinilai).

```http
GET /api/asesor/jadwal/:id/peserta
```

### Contoh Request

```http
GET /api/asesor/jadwal/11152/peserta
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Participants list retrieved successfully",
  "data": [
    {
      "id": 101,
      "nama_lengkap": "Andi Pratama",
      "hasil_rekomendasi": "K"
    },
    {
      "id": 102,
      "nama_lengkap": "Budi Santoso",
      "hasil_rekomendasi": "BK"
    },
    {
      "id": 103,
      "nama_lengkap": "Citra Lestari",
      "hasil_rekomendasi": null
    }
  ],
  "meta": {
    "jadwal_id": 11152,
    "total_asesi": 3,
    "jumlah_kompeten": 1,
    "jumlah_belum_kompeten": 1,
    "jumlah_belum_dinilai": 1
  }
}
```

### Keterangan Field Response

- `hasil_rekomendasi`: Bernilai `"K"` (Kompeten), `"BK"` (Belum Kompeten), atau `null` jika asesi belum dinilai.

---

## 4. Detail Peserta

Menampilkan profil lengkap peserta, status kelengkapan dokumen persyaratan/portofolio, serta status tahapan assessment peserta.

```http
GET /api/asesor/jadwal/:jadwal_id/peserta/:peserta_id
```

### Contoh Request

```http
GET /api/asesor/jadwal/11152/peserta/101
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Participant detail retrieved successfully",
  "data": {
    "peserta_id": 101,
    "no_peserta": "PES-2026-0724-001",
    "nama_lengkap": "Andi Pratama",
    "nik": "6253748567382",
    "tempat_lahir": "Yogyakarta",
    "tanggal_lahir": "1998-05-10",
    "skema_sertifikat": "UI/UX Design",
    "institusi": "LPP Jigja",
    "email": "andipratama@gmail.com",
    "no_telepon": "085678736521",
    "status_kelengkapan": {
      "portofolio": "Lengkap",
      "dokumen_pendukung": "Lengkap",
      "persyaratan": "Lengkap"
    },
    "status_assessment": {
      "kehadiran": "Hadir",
      "tugas_asesmen": "Belum Dinilai",
      "laporan": "Belum Dibuat",
      "rekaman": "Belum Diunggah"
    }
  }
}
```

### Keterangan Field Response

#### `status_kelengkapan`
- `portofolio`: `"Lengkap"` atau `"Belum Lengkap"`
- `dokumen_pendukung`: `"Lengkap"` atau `"Belum Lengkap"`
- `persyaratan`: `"Lengkap"` atau `"Belum Lengkap"`

#### `status_assessment`
- `kehadiran`: `"Hadir"` atau `"Absen"`
- `tugas_asesmen`: `"Kompeten"`, `"Belum Kompeten"`, atau `"Belum Dinilai"`
- `laporan`: `"Selesai"` atau `"Belum Dibuat"`
- `rekaman`: `"Selesai"` atau `"Belum Diunggah"`

---

## 5. Surat Tugas

Mengambil file PDF Surat Perintah Tugas untuk jadwal penugasan tertentu.

```http
GET /api/asesor/jadwal/:id/surat-tugas
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Surat tugas retrieved successfully",
  "data": {
    "file_url": "https://lsp-example.com/storage/surat-tugas/st-11152.pdf"
  }
}
```

---

## Response Error Global

Semua endpoint di atas mengembalikan status error seragam jika terjadi kegagalan:

- **400 Bad Request**: Parameter ID jadwal/peserta tidak valid atau salah tipe data.
- **401 Unauthorized**: Token JWT tidak disertakan atau telah kedaluwarsa.
- **403 Forbidden**: Role user bukan `asesor` atau user mencoba mengakses data penugasan milik asesor lain.
- **404 Not Found**: Data jadwal penugasan atau data peserta tidak ditemukan di database.
