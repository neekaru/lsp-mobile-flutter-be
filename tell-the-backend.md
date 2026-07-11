# Jadwal Saya Asesor - API Ready

Semua endpoint berikut hanya untuk user dengan role `asesor`. Backend mengambil identitas asesor dari email pada JWT dan hanya mengizinkan jadwal yang memang ditugaskan kepada asesor tersebut.

## Headers

```http
Authorization: Bearer <access_token>
Accept: application/json
```

## Daftar Jadwal Saya

```http
GET /api/asesor/jadwal?status_jadwal=:status
```

| Tab | Request |
|---|---|
| Menunggu | `GET /api/asesor/jadwal?status_jadwal=0` |
| Dibatalkan | `GET /api/asesor/jadwal?status_jadwal=2` |
| Selesai | `GET /api/asesor/jadwal?status_jadwal=1,4` |

Jika `status_jadwal` tidak dikirim, backend menggunakan nilai `0` atau Menunggu.

### Response 200 OK

```json
{
  "status": "success",
  "message": "Asesor schedules retrieved successfully",
  "data": [
    {
      "id": 11152,
      "nama_jadwal": "Sertifikasi Junior Web Developer",
      "tanggal": "2026-04-27",
      "tanggal_akhir": "2026-04-30",
      "status_jadwal": "1",
      "tuk": "SMK Media Informatika",
      "jumlah_peserta": 54
    }
  ],
  "count": 1
}
```

Nilai `status_jadwal` yang diterima hanya `0`, `1`, `2`, dan `4`. Nilai lain menghasilkan `400 Bad Request`.

## Detail Jadwal

```http
GET /api/asesor/jadwal/:id/detail
```

Contoh:

```http
GET /api/asesor/jadwal/11152/detail
```

### Response 200 OK

```json
{
  "status": "success",
  "message": "Assessor schedule detail retrieved successfully",
  "data": {
    "status_label": "Selesai",
    "tanggal_asesmen": "2026-04-27",
    "waktu_asesmen": "08:00",
    "lokasi_asesmen": "Jl. Contoh No. 1",
    "jumlah_peserta": 54,
    "lead_asesor": "",
    "nama_jadwal": "Sertifikasi Junior Web Developer",
    "tuk": "SMK Media Informatika"
  }
}
```

### Keterangan Field

| Field | Keterangan |
|---|---|
| `status_label` | `Menunggu`, `Selesai`, `Dibatalkan`, `Berlangsung`, atau `Pelaporan` |
| `tanggal_asesmen` | Format `YYYY-MM-DD` |
| `waktu_asesmen` | Waktu jadwal dari backend, dapat berupa string kosong jika belum diisi |
| `lokasi_asesmen` | Alamat TUK, dapat berupa string kosong jika belum diisi |
| `jumlah_peserta` | Total peserta dari `lsp275_asesi` dan `lsp275_asesi_2024` |
| `lead_asesor` | Saat ini selalu string kosong karena database belum memiliki penanda asesor utama |

## Daftar Peserta

```http
GET /api/asesor/jadwal/:id/peserta
```

Contoh:

```http
GET /api/asesor/jadwal/11152/peserta
```

### Response 200 OK

```json
{
  "status": "success",
  "message": "Participants list retrieved successfully",
  "data": [
    {
      "id": 1,
      "nama_lengkap": "Nama Peserta",
      "hasil_rekomendasi": "K"
    }
  ],
  "meta": {
    "jadwal_id": 11152,
    "total_asesi": 54,
    "jumlah_kompeten": 30,
    "jumlah_belum_kompeten": 10,
    "jumlah_belum_dinilai": 14
  }
}
```

`hasil_rekomendasi` bernilai `K` untuk Kompeten, `BK` untuk Belum Kompeten, atau `-` jika belum dinilai.

## Detail Peserta

```http
GET /api/asesor/jadwal/:id/peserta/:peserta_id
```

Contoh:

```http
GET /api/asesor/jadwal/11152/peserta/241269
```

### Response 200 OK

```json
{
  "status": "success",
  "message": "Participant detail retrieved successfully",
  "data": {
    "peserta_id": 241269,
    "no_peserta": "",
    "nama_lengkap": "Nama Peserta",
    "nik": "0000000000000000",
    "tempat_lahir": "Yogyakarta",
    "tanggal_lahir": "1998-05-10",
    "skema_sertifikat": "Junior Web Developer",
    "institusi": "Nama Institusi",
    "email": "peserta@example.com",
    "no_telepon": "08123456789",
    "status_kelengkapan": {
      "portofolio": "Lengkap",
      "dokumen_pendukung": "Belum Lengkap",
      "persyaratan": "Belum Lengkap"
    },
    "status_assessment": {
      "kehadiran": "Belum tersedia",
      "tugas_asesmen": "Belum Dinilai",
      "laporan": "Belum Dibuat",
      "rekaman": "Belum Diunggah"
    }
  }
}
```

| Field | Nilai yang mungkin |
|---|---|
| `status_kelengkapan.portofolio` | `Lengkap`, `Belum Lengkap` |
| `status_kelengkapan.dokumen_pendukung` | `Lengkap`, `Belum Lengkap` |
| `status_kelengkapan.persyaratan` | `Lengkap`, `Belum Lengkap` |
| `status_assessment.kehadiran` | Saat ini `Belum tersedia`; database belum memiliki data kehadiran peserta. |
| `status_assessment.tugas_asesmen` | `Kompeten`, `Belum Kompeten`, `Belum Dinilai` |
| `status_assessment.laporan` | `Selesai`, `Belum Dibuat` |
| `status_assessment.rekaman` | `Selesai`, `Belum Diunggah` |

## Surat Tugas

```http
GET /api/asesor/jadwal/:id/surat-tugas
```

Endpoint dan validasi kepemilikan jadwal sudah tersedia. Namun database saat ini belum menyimpan file atau URL Surat Perintah Tugas, sehingga endpoint mengembalikan:

```json
{
  "status": "error",
  "message": "Surat tugas file is not available for this schedule"
}
```

Status HTTP: `404 Not Found`.

## Error Responses

- `400 Bad Request`: ID jadwal tidak valid.
- `401 Unauthorized`: token tidak ada atau tidak valid.
- `403 Forbidden`: role bukan `asesor`, atau jadwal bukan penugasan asesor login.
- `404 Not Found`: jadwal tidak tersedia, atau file Surat Tugas belum tersimpan.
