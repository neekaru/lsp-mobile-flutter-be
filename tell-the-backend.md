# LSP Mobile - Asesor Role API Contract & Specifications

Dokumen ini mendefinisikan seluruh kontrak API yang dibutuhkan untuk peran (role) **Asesor** di aplikasi LSP Mobile. Dokumen ini berfungsi sebagai acuan tunggal (Single Source of Truth) bagi tim backend untuk mengimplementasikan layanan yang dibutuhkan agar aplikasi mobile dapat berjalan secara dinamis tanpa data simulasi (mock data).

---

## 1. Headers & Autentikasi Global

Semua endpoint untuk peran Asesor bersifat privat dan wajib menyertakan token autentikasi JWT di dalam header HTTP:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

Backend wajib mengekstrak identitas asesor dari JWT token untuk memvalidasi otorisasi kepemilikan jadwal penugasan dan data profil.

---

## 2. Ringkasan Endpoint

Berikut adalah daftar 18 endpoint API yang dibutuhkan oleh peran Asesor:

| No | Metode | Endpoint | Deskripsi | Status di UI Mobile |
|----|--------|----------|-----------|---------------------|
| 1 | `GET` | `/api/asesor/dashboard?tanggal=:tanggal` | Mengambil data rangkuman tugas, alert banner, jadwal hari ini, dan tugas prioritas. | Dinonaktifkan mock jika endpoint siap |
| 2 | `GET` | `/api/asesor/jadwal?status_jadwal=:status` | Mengambil daftar jadwal penugasan milik asesor berdasarkan status filter. | Dinamis |
| 3 | `GET` | `/api/asesor/jadwal/:id/detail` | Mengambil informasi rinci suatu jadwal penugasan. | Sebagian disimulasikan jika ID dummy |
| 4 | `GET` | `/api/asesor/jadwal/:id/peserta` | Mengambil daftar peserta (asesi) terdaftar dalam suatu jadwal penugasan. | Dinamis |
| 5 | `GET` | `/api/asesor/jadwal/:jadwal_id/peserta/:peserta_id` | Mengambil detail profil, kelengkapan, dan status asesmen peserta tertentu. | Sebagian disimulasikan jika ID dummy |
| 6 | `GET` | `/api/asesor/jadwal/:id/surat-tugas` | Mengambil URL file PDF Surat Perintah Tugas resmi. | Dinamis |
| 7 | `GET` | `/api/asesor/laporan` | Mengambil riwayat laporan tugas asesor yang telah dikirim. | Dinamis |
| 8 | `GET` | `/api/asesor/laporan/:id` | Mengambil detail lengkap laporan tugas asesor. | Dinamis |
| 9 | `GET` | `/api/asesor/skema-tuk` | Mengambil data skema sertifikasi dan TUK untuk dropdown pilihan. | Dinamis |
| 10 | `POST` | `/api/asesor/laporan/upload-lampiran` | Mengunggah file berkas bukti lampiran pendukung. | Dinamis |
| 11 | `POST` | `/api/asesor/laporan` | Mengirim data pembuatan laporan tugas baru (Wizard submit). | Dinamis |
| 12 | `GET` | `/api/asesor/profile` | Mengambil informasi profil data diri lengkap asesor. | Dinamis |
| 13 | `PUT` | `/api/asesor/profile` | Memperbarui data profil asesor (Telepon, Alamat, Instansi, Foto). | Dinamis |
| 14 | `GET` | `/api/asesor/honor?periode=:bulan_tahun` | Mengambil rincian honor asesor berdasarkan periode bulan tertentu beserta data transaksi/pembayaran lengkap. | Dinamis |
| 15 | `GET` | `/api/asesor/tiket` | Mengambil daftar tiket bantuan yang dikirimkan oleh asesor. | Disimulasikan (Local State) |
| 16 | `GET` | `/api/asesor/tiket/:id` | Mengambil rincian dan riwayat pesan dalam satu tiket bantuan. | Disimulasikan (Local State) |
| 17 | `POST` | `/api/asesor/tiket` | Mengirim formulir pembuatan tiket bantuan baru beserta berkas dokumentasi. | Disimulasikan (Local State) |
| 18 | `POST` | `/api/asesor/tiket/:id/reply` | Mengirim pesan balasan (tanggapan) baru ke dalam utas obrolan tiket bantuan. | Disimulasikan (Local State) |

---

## 3. Spesifikasi Detail API

### MODUL 1: DASHBOARD & RINGKASAN

#### 1. Dashboard Asesor
* **Endpoint**: `GET /api/asesor/dashboard`
* **Query Parameters**:
  * `tanggal` (String, opsional): Tanggal spesifik dalam format `YYYY-MM-DD` atau `DD Month` (contoh: `2026-04-27` atau `20 April`). Jika kosong, backend menggunakan tanggal hari ini.
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Asesor dashboard data retrieved successfully",
  "data": {
    "summary": {
      "menunggu_verifikasi": 1,
      "asesmen_berlangsung": 0,
      "asesmen_selesai": 12,
      "menunggu_penugasan": 2
    },
    "alert_banner": {
      "has_alert": true,
      "title": "Verifikasi laporan tertunda",
      "subtitle": "Anda memiliki 1 laporan yang menunggu verifikasi"
    },
    "jadwal_hari_ini": [
      {
        "id_jadwal": 11152,
        "skema": "Sertifikasi Junior Web Developer",
        "tanggal": "2026-04-27",
        "waktu": "08:00",
        "tuk": "SMK Media Informatika",
        "status": "1"
      }
    ],
    "tugas_prioritas": [
      {
        "id_tugas": 28054,
        "title": "Laporan menunggu verifikasi",
        "subtitle": "Sertifikasi Junior Web Developer - SMK Media Informatika",
        "type": "menunggu_verifikasi"
      },
      {
        "id_tugas": 28055,
        "title": "Unggah Surat Tugas",
        "subtitle": "Sertifikasi Junior Graphic Designer - Politeknik Sampit",
        "type": "penugasan_baru"
      },
      {
        "id_tugas": 28056,
        "title": "Isi Catatan Asesmen",
        "subtitle": "Sertifikasi Network Security Engineer - UI",
        "type": "penugasan_baru"
      },
      {
        "id_tugas": 28057,
        "title": "Evaluasi Portofolio Mandiri",
        "subtitle": "Sertifikasi Cloud Computing Admin - SMK Media Informatika",
        "type": "asesmen_berlangsung"
      }
    ]
  }
}
```
* **Keterangan Field**:
  * `summary`: Menghitung jumlah asesmen berdasarkan tahapan status.
  * `alert_banner`: Pesan info penting yang mendesak untuk ditindaklanjuti.
  * `jadwal_hari_ini`: Jadwal asesmen yang harus dihadiri hari ini. Nilai status: `"0"` (waiting), `"1"` (completed), `"2"` (canceled), `"3"` (running), `"4"` (pelaporan).
  * `tugas_prioritas.type`: Kategori tugas (`menunggu_verifikasi`, `penugasan_baru`, `asesmen_berlangsung`, `asesmen_selesai`) untuk menentukan ikon dan warna di UI.

---

### MODUL 2: JADWAL & PENUGASAN

#### 2. Daftar Jadwal Penugasan Saya
* **Endpoint**: `GET /api/asesor/jadwal`
* **Query Parameters**:
  * `status_jadwal` (String, opsional): Memfilter status penugasan. Nilai:
    * `0` : Menunggu / Aktif
    * `1,4` : Selesai / Pelaporan
    * `2` : Dibatalkan
* **Response (200 OK)**:
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

#### 3. Detail Penugasan
* **Endpoint**: `GET /api/asesor/jadwal/:id/detail`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Assessor schedule detail retrieved successfully",
  "data": {
    "id": 11152,
    "jadwal": "Sertifikasi Junior Web Developer",
    "tanggal": "2026-07-24",
    "tanggal_akhir": "2026-07-27",
    "status_jadwal": "0",
    "status_label": "Waiting",
    "id_tuk": 1,
    "tuk": "LPP Cahaya Borneo",
    "alamat_tuk": "Kalimantan Tengah",
    "jenis_tuk": "Sewaktu",
    "waktu_asesmen": "09:00 - 12:00 WIB",
    "lokasi_asesmen": "Gedung A Lantai 2, Kota Yogyakarta",
    "jumlah_peserta": 54,
    "lead_asesor": "Eko Setiabudi",
    "asesor": [
      {
        "id_asesor": 1,
        "nama_asesor": "Eko Setiabudi",
        "no_reg": "MET.000.001928 2023",
        "email": "eko.setiabudi@lsp.com",
        "hp": "08123456789",
        "jenis_asesmen": "Mandiri",
        "status_spt": "Disetujui",
        "is_complete": "1",
        "masa_berlaku": "2028-12-31",
        "kabupaten_kota": "Yogyakarta",
        "provinsi_id": "34",
        "kabupaten_id": "3471",
        "total_asesmen": 15
      }
    ]
  }
}
```

#### 4. Daftar Peserta (Jadwal Asesi List)
* **Endpoint**: `GET /api/asesor/jadwal/:id/peserta`
* **Response (200 OK)**:
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
      "hasil_rekomendasi": "-"
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
* **Keterangan Field**:
  * `hasil_rekomendasi`: `"K"` (Kompeten), `"BK"` (Belum Kompeten), atau `"-"` / `null` jika belum dinilai.

#### 5. Detail Peserta
* **Endpoint**: `GET /api/asesor/jadwal/:jadwal_id/peserta/:peserta_id`
* **Response (200 OK)**:
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
      "tugas_asesmen": "Kompeten",
      "laporan": "Belum Dibuat",
      "rekaman": "Belum Diunggah"
    }
  }
}
```

#### 6. Mengambil File Surat Tugas PDF
* **Endpoint**: `GET /api/asesor/jadwal/:id/surat-tugas`
* **Response (200 OK)**:
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

### MODUL 3: PELAPORAN TUGAS ASESOR

#### 7. Riwayat Daftar Laporan Tugas Asesor
* **Endpoint**: `GET /api/asesor/laporan`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Riwayat laporan tugas berhasil diambil",
  "data": [
    {
      "id": 8810,
      "kode_laporan": "LAP-2026-0724",
      "skema_sertifikasi": "Design UI/UX",
      "tanggal_pelaksanaan": "2026-07-24",
      "tuk": "LPP Cahaya Borneo",
      "nama_asesor": "Muhammad Hanafi",
      "status": "Terkonfirmasi"
    }
  ]
}
```

#### 8. Detail Laporan Tugas Asesor
* **Endpoint**: `GET /api/asesor/laporan/:id`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Detail laporan tugas berhasil diambil",
  "data": {
    "id": 8810,
    "kode_laporan": "LAP-2026-0724",
    "status": "Terkonfirmasi",
    "nama_asesor": "Muhammad Hanafi",
    "skema_sertifikasi": "Design UI/UX",
    "tanggal_pelaksanaan": "24 Juli 2026",
    "link_dokumentasi": "https://drive.google.com/drive/folders/123xyz",
    "catatan": "Asesi telah mengumpulkan seluruh tugas implementasi UI Design dengan lengkap. Melalui sesi wawancara, Asesi mampu membuktikan keaslian karya secara mandiri, menjelaskan alur user flow dengan logis, serta menggunakan design system yang terkini.",
    "ringkasan": {
      "total_peserta": 10,
      "hadir": 8,
      "absen": 2,
      "kompeten": 7,
      "belum_kompeten": 1
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
      "https://lsp-example.com/storage/attachments/bukti-1.pdf",
      "https://lsp-example.com/storage/attachments/foto-2.png"
    ]
  }
}
```

#### 9. Dropdown Skema & TUK
* **Endpoint**: `GET /api/asesor/skema-tuk`
* **Response (200 OK)**:
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

#### 10. Upload Berkas Lampiran Pendukung (Multipart)
* **Endpoint**: `POST /api/asesor/laporan/upload-lampiran`
* **Content-Type**: `multipart/form-data`
* **Request Body**:
  * `file`: Berkas PDF/Gambar (Maksimal 10MB)
* **Response (200 OK)**:
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

#### 11. Kirim Laporan Tugas Baru (Wizard Submit)
* **Endpoint**: `POST /api/asesor/laporan`
* **Content-Type**: `application/json`
* **Request Body (JSON)**:
```json
{
  "jadwal_id": 11152,
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
* **Response (201 Created)**:
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

### MODUL 4: PROFIL, HONOR & TIKET BANTUAN ASESOR

#### 12. Mengambil Profil Data Diri Asesor
* **Endpoint**: `GET /api/asesor/profile`
* **Response (200 OK)**:
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

#### 13. Update Profil Asesor
* **Endpoint**: `PUT /api/asesor/profile`
* **Content-Type**: `application/json`
* **Request Body (JSON)**:
```json
{
  "no_telepon": "0858978655634",
  "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah",
  "instansi": "Politeknik Negeri Sampit",
  "foto_profil_url": "https://lsp-example.com/storage/profiles/hanafi.jpg"
}
```
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Profil berhasil diperbarui",
  "data": {
    "id_asesor": "ASR-2026-000123",
    "nama_lengkap": "Muhammad Hanafi",
    "no_telepon": "0858978655634",
    "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah",
    "instansi": "Politeknik Negeri Sampit",
    "foto_profil_url": "https://lsp-example.com/storage/profiles/hanafi.jpg"
  }
}
```

#### 14. Daftar Honor Asesor
* **Endpoint**: `GET /api/asesor/honor`
* **Query Parameters**:
  * `periode` (String, opsional): Memfilter berdasarkan format `NamaBulan Tahun` (contoh: `Juli 2026`). Jika kosong, backend wajib mengembalikan seluruh riwayat honor/pendapatan.
* **Response (200 OK)**:
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
        "honor": "Rp. 625.000",
        "status": "Complete",
        "jumlah_asesmen": 2,
        "metode_pembayaran": "Transfer Bank",
        "tanggal_pembayaran": "20 Juli 2026, 10:00 WIB",
        "no_transfer": "PAY-20262007-001",
        "jumlah_asesi": 12,
        "jenis_asesmen": "Asesmen Mandiri / Praktik"
      },
      {
        "id_detail": 502,
        "judul_asesmen": "Uji Kompetensi: Digital Marketing",
        "tanggal": "10 Juli 2026",
        "tuk": "TUK Sewaktu LSP",
        "honor": "Rp. 625.000",
        "status": "Menunggu",
        "jumlah_asesmen": 1,
        "metode_pembayaran": "Transfer Bank",
        "tanggal_pembayaran": "-",
        "no_transfer": "-",
        "jumlah_asesi": 18,
        "jenis_asesmen": "Asesmen Portofolio"
      },
      {
        "id_detail": 503,
        "judul_asesmen": "Uji Kompetensi: Network Administrator",
        "tanggal": "06 Juli 2026",
        "tuk": "SMKN 1 Sampit",
        "honor": "Rp. 625.000",
        "status": "Complete",
        "jumlah_asesmen": 3,
        "metode_pembayaran": "Transfer Bank",
        "tanggal_pembayaran": "08 Juli 2026, 14:20 WIB",
        "no_transfer": "PAY-20262007-003",
        "jumlah_asesi": 15,
        "jenis_asesmen": "Asesmen Praktik Langsung"
      },
      {
        "id_detail": 504,
        "judul_asesmen": "Uji Kompetensi: Junior Graphic Designer",
        "tanggal": "02 Juli 2026",
        "tuk": "Politeknik Sampit",
        "honor": "Rp. 625.000",
        "status": "Complete",
        "jumlah_asesmen": 4,
        "metode_pembayaran": "Transfer Bank",
        "tanggal_pembayaran": "04 Juli 2026, 09:15 WIB",
        "no_transfer": "PAY-20262007-004",
        "jumlah_asesi": 20,
        "jenis_asesmen": "Asesmen Wawancara"
      }
    ]
  }
}
```

#### 15. Daftar Tiket Bantuan Asesor
* **Endpoint**: `GET /api/asesor/tiket`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Daftar tiket bantuan berhasil diambil",
  "data": [
    {
      "id": "TK-072026-001",
      "title": "Jadwal Tidak Dapat Dibuka",
      "date": "20 Juli 2026, 13:00",
      "category": "Jadwal",
      "status": "Proses",
      "messages": [
        {
          "sender": "Asesor",
          "time": "20 Juli 2026 13:00",
          "text": "Saya tidak bisa membuka detail jadwal asesmen saya pada hari ini. Muncul pesan error koneksi."
        },
        {
          "sender": "LSP Admin",
          "time": "20 Juli 2026 13:15",
          "text": "Halo Pak, mohon pastikan koneksi internet stabil atau coba restart aplikasi ya."
        }
      ]
    },
    {
      "id": "TK-072026-002",
      "title": "Surat Tugas Tidak ada",
      "date": "18 Juli 2026, 08:00",
      "category": "Surat Tugas",
      "status": "Proses",
      "messages": [
        {
          "sender": "Asesor",
          "time": "18 Juli 2026 08:00",
          "text": "Mohon bantuannya, surat tugas untuk skema sertifikasi UI/UX tidak terlampir di dashboard."
        }
      ]
    }
  ]
}
```

#### 16. Detail Tiket Bantuan Asesor
* **Endpoint**: `GET /api/asesor/tiket/:id`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Detail tiket bantuan berhasil diambil",
  "data": {
    "id": "TK-072026-001",
    "title": "Jadwal Tidak Dapat Dibuka",
    "date": "20 Juli 2026, 13:00",
    "category": "Jadwal",
    "status": "Proses",
    "messages": [
      {
        "sender": "Asesor",
        "time": "20 Juli 2026 13:00",
        "text": "Saya tidak bisa membuka detail jadwal asesmen saya pada hari ini. Muncul pesan error koneksi."
      },
      {
        "sender": "LSP Admin",
        "time": "20 Juli 2026 13:15",
        "text": "Halo Pak, mohon pastikan koneksi internet stabil atau coba restart aplikasi ya."
      }
    ]
  }
}
```

#### 17. Kirim Tiket Bantuan Baru
* **Endpoint**: `POST /api/asesor/tiket`
* **Content-Type**: `application/json` (atau `multipart/form-data` jika menyertakan upload file lampiran)
* **Request Body (JSON)**:
```json
{
  "nama_lengkap": "Muhammad Hanafi",
  "judul": "Jadwal Tidak Dapat Dibuka",
  "pesan": "Saya tidak bisa membuka detail jadwal asesmen saya pada hari ini. Muncul pesan error koneksi.",
  "dokumentasi_url": "https://lsp-example.com/storage/attachments/screenshot_kendala.png"
}
```
* **Response (201 Created)**:
```json
{
  "status": "success",
  "message": "Tiket bantuan berhasil dibuat",
  "data": {
    "id": "TK-072026-003",
    "title": "Jadwal Tidak Dapat Dibuka",
    "category": "Jadwal",
    "status": "Proses",
    "date": "Hari ini"
  }
}
```

#### 18. Kirim Pesan Tanggapan / Reply Chat Tiket Bantuan
* **Endpoint**: `POST /api/asesor/tiket/:id/reply`
* **Content-Type**: `application/json`
* **Request Body (JSON)**:
```json
{
  "text": "Baik, saya coba restart aplikasinya dahulu."
}
```
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Tanggapan berhasil dikirim",
  "data": {
    "sender": "Asesor",
    "time": "Hari ini",
    "text": "Baik, saya coba restart aplikasinya dahulu."
  }
}
```

---

## 4. Status Kode & Respons Error Global

Backend wajib mengembalikan format error standar JSON yang konsisten jika terjadi kegagalan transaksi/akses:

```json
{
  "status": "error",
  "message": "Pesan deskripsi kesalahan / alasan error"
}
```

### Status Codes:
* **400 Bad Request**: Payload data tidak lengkap, validasi tipe data salah, atau format input tidak sesuai (contoh: format tanggal tidak valid).
* **401 Unauthorized**: Token JWT tidak valid, tidak dikirim, atau telah kedaluwarsa.
* **403 Forbidden**: Otorisasi gagal karena user tidak memiliki peran `asesor`, atau mencoba mengakses jadwal/laporan milik asesor lain.
* **404 Not Found**: Data jadwal, peserta, laporan, profil, atau honor tidak ditemukan.
* **500 Internal Server Error**: Kegagalan sistem internal pada database atau server backend.
