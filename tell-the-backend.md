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

---

# Modul Pelaporan Tugas Asesor - API Contract & Documentation

Bagian ini mendefinisikan endpoint untuk pembuatan dan visualisasi **Laporan Pelaksanaan Tugas Asesor**. Modul ini digunakan setelah asesor menyelesaikan sesi ujian sertifikasi untuk melaporkan kehadiran asesi, penilaian kompetensi, link dokumentasi, serta dokumen pendukung.

---

## 6. Daftar Laporan Tugas Asesor

Menampilkan riwayat laporan tugas yang telah dibuat/dikirim oleh Asesor.

```http
GET /api/asesor/laporan
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Riwayat laporan tugas berhasil diambil",
  "data": [
    {
      "id": 8810,
      "kode_laporan": "LAP-2026-0724",
      "skema_sertifikasi": "Desaign UI/Ux",
      "tanggal_pelaksanaan": "2026-07-24",
      "tuk": "LPP Cahaya Borneo",
      "nama_asesor": "Muhammad Hanafi",
      "status": "Terkonfirmasi"
    }
  ]
}
```

---

## 7. Detail Laporan Tugas Asesor

Menampilkan informasi rinci dari laporan tugas tertentu, termasuk ringkasan KPI pelaksanaan (Total Asesi, Hadir, Absen, Kompeten, Tidak Kompeten), berkas surat tugas, dokumentasi, catatan evaluasi, daftar penilaian asesi, serta lampiran pendukung.

```http
GET /api/asesor/laporan/:id
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Detail laporan tugas berhasil diambil",
  "data": {
    "id": 8810,
    "kode_laporan": "LAP-2026-0724",
    "status": "Terkonfirmasi",
    "asesor": "Muhammad Hanafi",
    "skema_sertifikasi": "Desaign UI/Ux",
    "tanggal_pelaksanaan": "24 Juli 2026",
    "link_dokumentasi": "https://drive.google.com/drive/folders/123xyz",
    "catatan": "Asesi telah mengumpulkan seluruh tugas implementasi UI Design dengan lengkap. Melalui sesi wawancara, Asesi mampu membuktikan keaslian karya secara mandiri, menjelaskan alur user flow dengan logis, serta menggunakan design system yang terkini.",
    "kpi_pelaksanaan": {
      "total_asesi": 10,
      "hadir": 8,
      "absen": 2,
      "kompeten": 7,
      "tidak_kompeten": 1
    },
    "dokumen": {
      "surat_tugas_name": "Surat tugas.pdf",
      "surat_tugas_url": "https://lsp-example.com/storage/surat-tugas/st-11152.pdf"
    },
    "daftar_asesi_dinilai": [
      {
        "nama": "Ayu Putri Sri",
        "nim": "0897556789",
        "kehadiran": "Hadir",
        "penilaian": "K"
      },
      {
        "nama": "Bayu Nugrahan",
        "nim": "09769990862",
        "kehadiran": "Absen",
        "penilaian": "TK"
      }
    ],
    "lampiran_pendukung": [
      {
        "nama": "Bukti_Pendukung_1.pdf",
        "url": "https://lsp-example.com/storage/attachments/bukti-1.pdf"
      },
      {
        "nama": "Foto_Dokumentasi_2.png",
        "url": "https://lsp-example.com/storage/attachments/foto-2.png"
      }
    ]
  }
}
```

---

## 8. Mengambil Daftar Skema & TUK (Dropdown Option)

Digunakan pada form Step 1 Laporan Baru untuk mendapatkan pilihan skema sertifikasi dan TUK yang aktif.

```http
GET /api/asesor/skema-tuk
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Daftar skema sertifikasi & TUK berhasil diambil",
  "data": [
    {
      "id": 1,
      "nama_skema": "Desaign UI/Ux",
      "tuk": "LPP Cahaya Borneo"
    },
    {
      "id": 2,
      "nama_skema": "Junior Web Programmer",
      "tuk": "TUK Mandiri Universitas"
    }
  ]
}
```

---

## 9. Upload Lampiran Pendukung

Endpoint asinkron untuk mengunggah lampiran pendukung (file PDF/Gambar) saat form pembuatan laporan sedang berjalan.

```http
POST /api/asesor/laporan/upload-lampiran
Content-Type: multipart/form-data
```

### Request Body (Multipart)

| Parameter | Tipe | Keterangan |
|---|---|---|
| `file` | File | Berkas PDF atau Gambar (Maksimal 5MB) |

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Upload File Berhasil",
  "data": {
    "file_name": "Bukti_Pendukung_1.pdf",
    "file_url": "https://lsp-example.com/storage/attachments/temp-bukti-1.pdf"
  }
}
```

---

## 10. Kirim Laporan Tugas Baru (Submit Wizard)

Mengirimkan seluruh data laporan tugas baru dari form wizard (Step 1 sampai Step 4).

```http
POST /api/asesor/laporan
Content-Type: application/json
```

### Request Body (JSON)

```json
{
  "nama_asesor": "Muhammad Hanafi",
  "skema_id": 1,
  "tanggal_pelaksanaan": "2026-07-24",
  "surat_tugas_url": "https://lsp-example.com/storage/surat-tugas/st-11152.pdf",
  "link_dokumentasi": "https://drive.google.com/drive/folders/123xyz",
  "catatan": "Evaluasi pelaksanaan berjalan kondusif.",
  "daftar_peserta": [
    {
      "nim": "0897556789",
      "kehadiran": "Hadir",
      "is_kompeten": true
    },
    {
      "nim": "09769990862",
      "kehadiran": "Absen",
      "is_kompeten": false
    }
  ],
  "lampiran_pendukung": [
    "https://lsp-example.com/storage/attachments/temp-bukti-1.pdf"
  ]
}
```

### Response (201 Created)

```json
{
  "status": "success",
  "message": "Laporan tugas berhasil dibuat",
  "data": {
    "id": 8810,
    "kode_laporan": "LAP-2026-0724",
    "status": "Terkonfirmasi"
  }
}
```

---

# Modul Profil & Honor Asesor - API Contract & Documentation

Modul ini mengelola data pribadi Asesor dan menampilkan rekapitulasi pembayaran (honor) atas tugas asesmen yang telah diselesaikan.

---

## 11. Profil Asesor (Data Diri)

Mengambil data profil lengkap dari asesor yang sedang login.

```http
GET /api/asesor/profile
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Profil asesor berhasil diambil",
  "data": {
    "id_asesor": "ASR-2026-000123",
    "nama_lengkap": "Muhammad Hanafi",
    "status_aktif": "Aktif",
    "nik": "6303001204950002",
    "email": "muhammadhanafi_12@gmail.com",
    "no_telepon": "0858978655634",
    "foto_profil_url": "https://lsp-example.com/storage/profiles/hanafi.jpg",
    "instansi": "Politeknik Negeri Sampit",
    "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah"
  }
}
```

---

## 12. Update Profil Asesor

Memperbarui data pribadi asesor seperti nomor telepon, alamat, instansi, atau foto profil.

```http
PUT /api/asesor/profile
Content-Type: application/json
```

### Request Body (JSON)

```json
{
  "no_telepon": "0858978655634",
  "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah",
  "instansi": "Politeknik Negeri Sampit",
  "foto_profil_url": "https://lsp-example.com/storage/profiles/hanafi.jpg"
}
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Profil berhasil diperbarui",
  "data": {
    "id_asesor": "ASR-2026-000123",
    "nama_lengkap": "Muhammad Hanafi",
    "no_telepon": "0858978655634",
    "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah",
    "instansi": "Politeknik Negeri Sampit"
  }
}
```

---

## 13. Daftar Honor Asesor (Berdasarkan Periode)

Menampilkan daftar pendapatan/honor asesor atas pelaksanaan asesmen yang disaring berdasarkan periode bulan tertentu.

```http
GET /api/asesor/honor?periode=:bulan_tahun
```

### Query Parameters

| Parameter | Tipe | Keterangan |
|---|---|---|
| `periode` | String | Format filter `NamaBulan Tahun` (contoh: `Juli 2026`, `Juni 2026`) |

### Contoh Request

```http
GET /api/asesor/honor?periode=Juli+2026
```

### Response (200 OK)

```json
{
  "status": "success",
  "message": "Daftar honor berhasil diambil",
  "data": {
    "periode": "Juli 2026",
    "total_honor": "Rp. 2.500.000",
    "jumlah_asesmen_selesai": "4 Asesmen selesai",
    "rincian": [
      {
        "id_detail": 501,
        "judul_asesmen": "Uji Kompetensi: Junior Web Programmer",
        "tanggal": "12 Juli 2026",
        "tuk": "Politeknik Sampit",
        "honor": "Rp. 625.000"
      },
      {
        "id_detail": 502,
        "judul_asesmen": "Uji Kompetensi: Digital Marketing",
        "tanggal": "10 Juli 2026",
        "tuk": "TUK Sewaktu LSP",
        "honor": "Rp. 625.000"
      },
      {
        "id_detail": 503,
        "judul_asesmen": "Uji Kompetensi: Network Administrator",
        "tanggal": "06 Juli 2026",
        "tuk": "SMKN 1 Sampit",
        "honor": "Rp. 625.000"
      },
      {
        "id_detail": 504,
        "judul_asesmen": "Uji Kompetensi: Junior Graphic Designer",
        "tanggal": "02 Juli 2026",
        "tuk": "Politeknik Sampit",
        "honor": "Rp. 625.000"
      }
    ]
  }
}
```
