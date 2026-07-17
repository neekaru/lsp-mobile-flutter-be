# LSP Mobile - Asesi Role API Contract & Specifications

Dokumen ini mendefinisikan seluruh kontrak API yang digunakan untuk peran (role) **Asesi** (Peserta Sertifikasi) di aplikasi LSP Mobile. Dokumen ini berfungsi sebagai acuan tunggal bagi tim backend untuk mengimplementasikan layanan yang dibutuhkan agar aplikasi mobile dapat berjalan secara dinamis menggunakan API live.

---

## 1. Headers & Autentikasi Global

Semua request dari aplikasi (kecuali login & register) wajib menyertakan token autentikasi JWT di dalam header HTTP:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

---

## 2. Ringkasan Endpoint

Berikut adalah daftar lengkap endpoint API yang terintegrasi di sisi aplikasi mobile:

### A. Autentikasi & Manajemen Sesi
| No | Metode | Endpoint | Deskripsi | Layar/Fungsi di Flutter |
|----|--------|----------|-----------|------------------------|
| 1  | `POST` | `/api/auth/login` | Melakukan autentikasi pengguna berdasarkan email/akun, password, dan role. | `LoginScreen` |
| 2  | `POST` | `/api/auth/logout` | Menghapus session saat ini di server (opsional menyertakan device token FCM). | Tombol Logout / Keluar |
| 3  | `GET`  | `/api/auth/current` | Mengambil data pengguna yang sedang login berdasarkan JWT Token. | Init session / Auto-login |
| 4  | `POST` | `/api/auth/refresh` | Menggunakan refresh token untuk memperbarui access token yang kadaluarsa. | Dio Interceptor |
| 5  | `GET`  | `/api/sessions` | Mengambil daftar sesi login yang aktif di perangkat lain. | `KeamananScreen` |
| 6  | `DELETE`| `/api/sessions/:id` | Menghentikan paksa (revoke) sesi login perangkat lain tertentu. | `KeamananScreen` |

### B. Dashboard, Berita, & Jadwal
| No | Metode | Endpoint | Deskripsi | Layar/Fungsi di Flutter |
|----|--------|----------|-----------|------------------------|
| 7  | `GET`  | `/api/asesi/dashboard` | Mengambil data summary (jumlah skema/sertifikat), alert banner, dan berita terkini. | `DashboardScreen` |
| 8  | `GET`  | `/api/asesi/jadwal` | Mengambil daftar jadwal asesmen yang diikuti oleh Asesi. | `JadwalScreen` (Role Asesi) |
| 9  | `GET`  | `/api/berita` | Mengambil daftar berita dan artikel dengan pagination. | `DashboardScreen` / List Berita |

### C. Skema Sertifikasi (Pencarian & Detail)
| No | Metode | Endpoint | Deskripsi | Layar/Fungsi di Flutter |
|----|--------|----------|-----------|------------------------|
| 10 | `GET`  | `/api/sertifikat/skema` | Mengambil daftar skema sertifikasi yang tersedia dengan filter & pencarian. | `MulaiSertifikasiCard` / `PublicProfileScreen` |
| 11 | `GET`  | `/api/sertifikat/skema/bidang` | Mengambil kategori/bidang skema untuk chips filter di frontend. | `MulaiSertifikasiCard` |
| 12 | `GET`  | `/api/sertifikat/skema/:id` | Mengambil detail skema tertentu (termasuk list Unit Kompetensi & persyaratan). | `DetailSkemaScreen` |
| 13 | `GET`  | `/api/sertifikat/skema/:id/asesor` | Mengambil daftar rekomendasi asesor untuk skema yang dipilih. | `AsesorRecommendationScreen` |

### D. Alur Pendaftaran & Pra-Asesmen
| No | Metode | Endpoint | Deskripsi | Layar/Fungsi di Flutter |
|----|--------|----------|-----------|------------------------|
| 14 | `POST` | `/api/sertifikasi/daftar` | Mendaftarkan diri ke skema sertifikasi tertentu dengan memilih TUK & tanggal rencana. | `KonfirmasiPendaftaran` |
| 15 | `GET`  | `/api/sertifikasi/status` | Mengecek status pendaftaran aktif (apakah terdaftar, sedang pra-asesmen, dll). | `DetailSkemaScreen` |
| 16 | `GET`  | `/api/pra-asesmen/skema/:id/info` | Mengambil informasi status/judul pra-asesmen untuk skema tertentu. | `PraAsesmenWizard` |
| 17 | `GET`  | `/api/pra-asesmen/skema/:id/kompetensi` | Mengambil daftar unit kompetensi, elemen, dan KUK untuk asesmen mandiri. | `StepEvaluasiKompetensi` |
| 18 | `POST` | `/api/pra-asesmen/skema/:id/submit` | Mengirimkan jawaban asesmen mandiri (Kompeten [K] / Belum Kompeten [BK]). | `PraAsesmenWizard` (Submit) |

### E. Portofolio & Dokumen Persyaratan
| No | Metode | Endpoint | Deskripsi | Layar/Fungsi di Flutter |
|----|--------|----------|-----------|------------------------|
| 19 | `GET`  | `/api/sertifikasi/:id/portofolio` | Mengambil list dokumen persyaratan yang harus diunggah beserta statusnya. | `BuktiPortofolioScreen` |
| 20 | `POST` | `/api/sertifikasi/:id/portofolio/upload` | Mengunggah berkas portofolio (KTP, pasfoto, ijazah, dll) (Multipart). | `BuktiPortofolioScreen` |

### F. Profil Asesi (Data Diri & Instansi)
| No | Metode | Endpoint | Deskripsi | Layar/Fungsi di Flutter |
|----|--------|----------|-----------|------------------------|
| 21 | `GET`  | `/api/asesor/profile` | Mengambil data diri asesi (nama_lengkap, email, no_telepon, alamat, pasfoto). | `DataDiriScreen` |
| 22 | `PUT`  | `/api/asesor/profile` | Memperbarui data diri asesi (no_telepon, alamat, dll). | `EditDataDiriScreen` |
| 23 | `GET`  | `/api/asesi/instansi` | Mengambil tipe status pekerjaan & rincian data instansi saat ini. | `EditInstansiScreen` |
| 24 | `PUT`  | `/api/asesi/instansi` | Memperbarui tipe status instansi & kolom data instansi pendukung. | `EditInstansiScreen` |

### G. Sertifikat & Validasi
| No | Metode | Endpoint | Deskripsi | Layar/Fungsi di Flutter |
|----|--------|----------|-----------|------------------------|
| 25 | `GET`  | `/api/asesi/sertifikat` | Mengambil daftar sertifikat kompetensi yang telah diterbitkan untuk Asesi. | `AsesiSertifikatScreen` |
| 26 | `GET`  | `/api/asesi/sertifikat/:id` | Mengambil detail lengkap satu sertifikat (Nomor Blanko, Seri, Asesor, dll). | `DetailSertifikatScreen` |
| 27 | `POST` | `/api/asesi/sertifikat/:id/upload-ttd` | Mengunggah foto + TTD (PDF/PNG) pendukung sertifikat (Multipart/Multi-file). | `DetailSertifikatScreen` (Upload) |
| 28 | `GET`  | `/api/asesi/sertifikat/:id/download` | Mengambil secure URL untuk mengunduh PDF Sertifikat asli. | `DetailSertifikatScreen` (Download) |
| 29 | `POST` | `/api/sertifikat/validate` | Melakukan verifikasi validitas sertifikat untuk publik berdasarkan No. Sertifikat. | `ValidasiSertifikatScreen` |
| 30 | `GET`  | `/api/sertifikat/search` | Mencari data sertifikat yang terdaftar secara publik. | `SertifikatScreen` |

---

## 3. Spesifikasi Detail API & Contoh Payload

### MODUL 1: AUTENTIKASI & SESI

#### 1. Login Pengguna
* **Endpoint**: `POST /api/auth/login`
* **Request Body**:
```json
{
  "identity": "muhammadhanafi_12@gmail.com",
  "password": "SecretPassword123",
  "role": "asesi"
}
```
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "def456...",
    "user": {
      "id": 1,
      "name": "Muhammad Hanafi",
      "email": "muhammadhanafi_12@gmail.com",
      "role": "asesi",
      "roles": ["asesi"]
    }
  }
}
```

#### 2. Get Sesi Aktif
* **Endpoint**: `GET /api/sessions`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": [
    {
      "id": 12,
      "device_name": "Chrome on Windows",
      "ip_address": "192.168.1.15",
      "last_active": "2026-07-15T12:00:00Z",
      "is_current": true
    },
    {
      "id": 13,
      "device_name": "Samsung Galaxy S23",
      "ip_address": "192.168.1.99",
      "last_active": "2026-07-14T08:30:00Z",
      "is_current": false
    }
  ]
}
```

#### 3. Revoke/Hapus Sesi
* **Endpoint**: `DELETE /api/sessions/:id`
* **Deskripsi**: Menghapus/menghentikan sesi login tertentu.
* **PENTING UNTUK TIM BACKEND**:
  1. Ketika endpoint ini dipanggil, backend **WAJIB** membatalkan (revoke/blacklist) JWT Access Token dan Refresh Token yang terasosiasi dengan sesi tersebut.
  2. Request berikutnya dari perangkat dengan token yang telah di-revoke tersebut **harus mengembalikan status HTTP 401 Unauthorized** (bukan 200 OK), sehingga aplikasi mobile dapat mendeteksi sesi berakhir dan otomatis me-logout pengguna.
  3. Relasi FCM Device Token yang terdaftar pada sesi tersebut **harus dihapus** dari server sehingga perangkat tersebut tidak lagi menerima notifikasi push.
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Sesi berhasil dihentikan"
}
```

---

### MODUL 2: DASHBOARD, BERITA, & JADWAL

#### 3. Dashboard Asesi
* **Endpoint**: `GET /api/asesi/dashboard`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "summary": {
      "skema_diikuti": 1,
      "sertifikat_aktif": 2
    },
    "alert_banner": {
      "has_alert": true,
      "title": "Pra-Asesmen Menunggu Pengisian",
      "subtitle": "Silakan selesaikan pengisian Pra-Asesmen untuk skema Digital Marketing Madya"
    },
    "berita_terkini": [
      {
        "id": 1,
        "title": "Sosialisasi LSP Digital Gelombang 2",
        "date": "15 Juli 2026",
        "summary": "Pendaftaran sertifikasi kompetensi gelombang kedua resmi dibuka bagi pelaku industri digital.",
        "image_url": "https://lsp-example.com/images/berita1.jpg"
      }
    ]
  }
}
```

#### 4. Jadwal Saya (Asesi)
* **Endpoint**: `GET /api/asesi/jadwal`
* **Query Parameters**:
  * `status_jadwal`: status filter (`0`=Mendatang, `3`=Sedang Berjalan, `1`=Selesai)
  * `limit`: default `20`
  * `offset`: default `0`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": [
    {
      "id": 45,
      "jadwal": "Asesmen Kompetensi Digital Marketing Madya - Juli 2026",
      "tuk": "TUK LSP Digital Utama",
      "tanggal": "2026-07-25",
      "tanggal_akhir": "2026-07-26",
      "status_jadwal": "3",
      "status_label": "Sedang Berjalan",
      "jumlah_asesi": 1,
      "asesor": [
        "Dr. Ir. Ahmad Yani, M.Kom"
      ],
      "days_overdue": 0,
      "catatan": "Harap membawa laptop dan berkas portofolio fisik asli saat asesmen."
    }
  ]
}
```

---

### MODUL 3: SKEMA SERTIFIKASI & PENDAFTARAN

#### 5. Kategori/Bidang Skema
* **Endpoint**: `GET /api/sertifikat/skema/bidang`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "nama_bidang": "Digital Marketing"
    },
    {
      "id": 2,
      "nama_bidang": "Informatika"
    }
  ]
}
```

#### 6. Detail Skema
* **Endpoint**: `GET /api/sertifikat/skema/:id`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id_skema": 1,
    "kode_skema": "SKM-DM-002",
    "skema": "Digital Marketing Madya",
    "kategori": "Digital Marketing",
    "deskripsi": "Skema sertifikasi pemasaran digital tingkat madya.",
    "unit_kompetensi": [
      {
        "kode_unit": "DM-01",
        "judul_unit": "Melakukan Riset Pasar Digital"
      }
    ],
    "persyaratan": [
      "CV Terbaru",
      "Pasfoto latar belakang merah",
      "KTP",
      "Fotokopi Ijazah terakhir"
    ],
    "is_registered": false,
    "sertifikasi_id": null,
    "status_pendaftaran": null
  }
}
```

#### 7. Rekomendasi Asesor
* **Endpoint**: `GET /api/sertifikat/skema/:id/asesor`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": [
    {
      "id_asesor": 23,
      "nama_asesor": "Dr. Ir. Ahmad Yani, M.Kom",
      "no_reg": "MET.000.123456",
      "email": "ahmadyani@example.com",
      "hp": "08123456789",
      "kabupaten_kota": "Sampit",
      "masa_berlaku": "2028-12-31"
    }
  ]
}
```

#### 8. Pendaftaran Baru
* **Endpoint**: `POST /api/sertifikasi/daftar`
* **Request Body**:
```json
{
  "skema_id": 1,
  "tuk_id": 2,
  "tanggal_rencana": "2026-08-10"
}
```
* **Response (201 Created)**:
```json
{
  "status": "success",
  "message": "Pendaftaran berhasil disimpan",
  "data": {
    "sertifikasi_id": 451,
    "status": "terdaftar"
  }
}
```

---

### MODUL 4: PRA-ASESMEN WIZARD

#### 9. Get Info Pra-Asesmen
* **Endpoint**: `GET /api/pra-asesmen/skema/:id/info`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "skema": "Digital Marketing Madya",
    "kode_skema": "SKM-DM-002",
    "status_pra_asesmen": "belum_diisi"
  }
}
```

#### 10. Get Unit & Elemen Kompetensi
* **Endpoint**: `GET /api/pra-asesmen/skema/:id/kompetensi`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "skema": "Digital Marketing Madya",
    "unit_kompetensi": [
      {
        "kode_unit": "DM-01",
        "judul_unit": "Melakukan Riset Pasar Digital",
        "elemen": [
          {
            "id_elemen": 101,
            "pertanyaan_kuk": "Apakah Anda dapat menentukan segmentasi pasar di media sosial?",
            "pilihan_rekomendasi": "K"
          }
        ]
      }
    ]
  }
}
```

#### 11. Kirim Pra-Asesmen Mandiri
* **Endpoint**: `POST /api/pra-asesmen/skema/:id/submit`
* **Request Body**:
```json
{
  "evaluasi": [
    {
      "id_elemen": 101,
      "nilai": "K"
    }
  ]
}
```
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Pra-Asesmen mandiri berhasil disimpan"
}
```

---

### MODUL 5: PORTOFOLIO & DOKUMEN PERSYARATAN

#### 12. List Dokumen Portofolio
* **Endpoint**: `GET /api/sertifikasi/:id/portofolio`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "documents": [
      {
        "key": "ktp",
        "label": "Kartu Tanda Penduduk (KTP)",
        "is_required": true,
        "status": "Terverifikasi",
        "file_name": "ktp_hanafi.pdf",
        "comment": null
      },
      {
        "key": "pasfoto",
        "label": "Pas Foto Terbaru 4x6",
        "is_required": true,
        "status": "Ditolak",
        "file_name": "foto_lama.jpg",
        "comment": "Foto buram & latar harus merah"
      }
    ]
  }
}
```

#### 13. Upload Portofolio (Multipart)
* **Endpoint**: `POST /api/sertifikasi/:id/portofolio/upload`
* **Content-Type**: `multipart/form-data`
* **Request Body**:
  * `key`: "ktp" / "pasfoto" / dll.
  * `file`: Berkas PDF/PNG/JPG (Maksimal 2MB)
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Berkas berhasil diunggah",
  "data": {
    "file_name": "foto_terbaru_merah.jpg",
    "status": "Menunggu Verifikasi"
  }
}
```

---

### MODUL 6: PROFIL (DATA DIRI & INSTANSI)

#### 14. Data Diri
* **Endpoint**: `GET /api/asesor/profile` (Catatan: Digunakan bersama oleh Asesor & Asesi)
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "nama_lengkap": "Muhammad Hanafi",
    "email": "muhammadhanafi_12@gmail.com",
    "no_telepon": "0858978655634",
    "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah",
    "foto_profil_url": "https://lsp-example.com/storage/profile/foto.jpg"
  }
}
```

#### 15. Update Data Diri
* **Endpoint**: `PUT /api/asesor/profile`
* **Request Body**:
```json
{
  "no_telepon": "0858978655634",
  "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah",
  "instansi": "Politeknik Sampit",
  "foto_profil_url": "https://lsp-example.com/storage/profile/foto.jpg"
}
```
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "nama_lengkap": "Muhammad Hanafi",
    "no_telepon": "0858978655634",
    "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah"
  }
}
```

#### 16. Get Informasi Instansi
* **Endpoint**: `GET /api/asesi/instansi`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "tipe_instansi": "Mahasiswa",
    "data_instansi": {
      "nama_perguruan_tinggi": "Politeknik Sampit",
      "fakultas": "Teknologi Informasi",
      "program_studi": "Sistem Informasi",
      "nim": "087685674568",
      "alamat": "Jl. Wengga Metropolitan"
    }
  }
}
```

#### 17. Update Informasi Instansi
* **Endpoint**: `PUT /api/asesi/instansi`
* **Request Body**:
```json
{
  "tipe_instansi": "Mahasiswa",
  "data_instansi": {
    "nama_perguruan_tinggi": "Politeknik Sampit",
    "fakultas": "Teknologi Informasi",
    "program_studi": "Sistem Informasi",
    "nim": "087685674568",
    "alamat": "Jl. Wengga Metropolitan"
  }
}
```
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Data instansi berhasil disimpan"
}
```

---

### MODUL 7: SERTIFIKAT ASESI & VALIDASI PUBLIC

#### 18. List Sertifikat Asesi
* **Endpoint**: `GET /api/asesi/sertifikat`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "skema": "Digital Marketing Madya",
      "pemegang": "Muhammad Hanafi",
      "nomor_sertifikat": "FR-APR-02",
      "tanggal_terbit": "2026-04-20",
      "tanggal_berlaku": "2028-04-20",
      "status": "aktif",
      "kategori": "Digital Marketing",
      "institusi": "LSP Digital Marketing",
      "nomor_registrasi": "REG-55431-2026",
      "nomor_blanko": "BLANKO-778811",
      "nomor_seri": "SERI-001A",
      "tempat_uji": "TUK LSP Digital Utama",
      "nama_asesor": "Dr. Ir. Ahmad Yani, M.Kom"
    }
  ]
}
```

#### 19. Detail Sertifikat Asesi
* **Endpoint**: `GET /api/asesi/sertifikat/:id`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "skema": "Digital Marketing Madya",
    "pemegang": "Muhammad Hanafi",
    "nomor_sertifikat": "FR-APR-02",
    "tanggal_terbit": "2026-04-20",
    "tanggal_berlaku": "2028-04-20",
    "status": "aktif",
    "kategori": "Digital Marketing",
    "institusi": "LSP Digital Marketing",
    "nomor_registrasi": "REG-55431-2026",
    "nomor_blanko": "BLANKO-778811",
    "nomor_seri": "SERI-001A",
    "tempat_uji": "TUK LSP Digital Utama",
    "nama_asesor": "Dr. Ir. Ahmad Yani, M.Kom"
  }
}
```

#### 20. Upload Foto & TTD Sertifikat (Multipart)
* **Endpoint**: `POST /api/asesi/sertifikat/:id/upload-ttd`
* **Content-Type**: `multipart/form-data`
* **Request Body**:
  * `file`: Berkas PDF/PNG berisi foto + tanda tangan (Maksimal 5MB, mendukung multi-file)
* **Response (200 OK)**:
```json
{
  "status": "success",
  "message": "Berkas foto & tanda tangan berhasil disimpan",
  "data": {
    "uploaded_files": [
      {
        "name": "ttd_hanafi.png",
        "url": "https://lsp-example.com/storage/sertifikat/ttd/1_ttd.png"
      }
    ]
  }
}
```

#### 21. Download Sertifikat PDF
* **Endpoint**: `GET /api/asesi/sertifikat/:id/download`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "download_url": "https://lsp-example.com/storage/sertifikat/pdf/sertifikat_1.pdf"
  }
}
```

#### 22. Validasi Sertifikat Publik
* **Endpoint**: `POST /api/sertifikat/validate`
* **Request Body**:
```json
{
  "no_dokumen": "FR-APR-02"
}
```
* **Response (200 OK)**:
```json
{
  "valid": true,
  "message": "Sertifikat Terverifikasi Valid",
  "data": {
    "id": 1,
    "skema": "Digital Marketing Madya",
    "pemegang": "Muhammad Hanafi",
    "nomor_sertifikat": "FR-APR-02",
    "tanggal_terbit": "20 April 2026",
    "tanggal_berlaku": "20 April 2028",
    "status": "aktif"
  }
}
```

---

## 4. Status Kode & Respons Error Global

Seluruh endpoint wajib mengembalikan format respons error JSON terstandar jika terjadi kegagalan transaksi/akses:

```json
{
  "status": "error",
  "message": "Pesan rincian kesalahan yang ramah pengguna"
}
```

### HTTP Status Codes:
* **400 Bad Request**: Payload data tidak lengkap, validasi data gagal, atau ukuran berkas melebihi batas.
* **401 Unauthorized**: JWT token tidak valid, kadaluarsa, atau tidak terlampir pada header Authorization.
* **403 Forbidden**: Otorisasi gagal karena role bukan `asesi` atau mencoba mengakses data milik pengguna lain.
* **404 Not Found**: Data skema, pendaftaran, portofolio, atau sertifikat tidak ditemukan.
* **500 Internal Server Error**: Terjadi gangguan teknis pada server basis data atau sistem backend.

---

### 5. API Dashboard & Statistik Admin (Terintegrasi)

Seluruh endpoint dashboard admin di bawah ini bersifat **public (tanpa auth)** mengikuti pola existing `/api/dashboard/*` untuk kemudahan rendering halaman dashboard & statistik.

---

### Status Endpoint Dashboard & Statistik Admin

| # | Metode | Endpoint | Status | Catatan |
|---|--------|----------|--------|---------|
| A1 | GET | `/api/dashboard/summary` | ✅ Updated | + field counter antrean (`pendaftaran_asesi_baru`, `honor_asesor_belum_dibayar`) |
| A2 | GET | `/api/dashboard/assesmen-graph` | ✅ Updated | + `kompeten`, `belum_kompeten`, `total` (alias `jumlah_asesmen`) |
| A3 | GET | `/api/dashboard/asesor-distribution` | ✅ Live | Tidak diubah |
| A4 | GET | `/api/dashboard/penyebaran-mitra` | ✅ Live | Tidak diubah |
| A5 | GET | `/api/dashboard/statistik-overview` | ✅ Live | Tidak diubah |
| A6 | GET | `/api/dashboard/asesor-stats` | ✅ Updated | + `trend_total_asesor` flat field di level root `data` |
| A7 | GET | `/api/dashboard/sertifikat-per-skema` | ✅ Live | Tidak diubah |
| A8 | GET | `/api/dashboard/asesor-homebase` | 🆕 BARU | List asesor + homebase + assessments |

---

### A1. Dashboard Summary & Counters `[REUSED - UPDATED]`
* **Method**: `GET`
* **Endpoint**: `/api/dashboard/summary`
* **Deskripsi**: Mengambil metrik kuantitatif utama dan jumlah antrean persetujuan (Approve Jadwal, Laporan, Pendaftaran baru, Honor) untuk dashboard Admin.
* **Headers**: None (Public Endpoint).
* **Parameter Request**: None.
* **Audit Kolom / Field Response**:
  - **Field yang Sudah Ada (Existing)**:
    - `total_asesmen` (int): Total asesmen keseluruhan.
    - `total_pemegang_sertifikat` (int): Total pemegang sertifikat.
    - `total_asesor` (int): Total asesor terdaftar.
    - `total_tuk` (int): Jumlah TUK terdaftar.
    - `total_asesi` (int): Jumlah asesi terdaftar.
    - `jadwal_belum_terkonfirmasi` (int): Jumlah antrean konfirmasi jadwal.
    - `surat_tugas_menunggu_pengiriman` (int): Jumlah antrean laporan surat tugas.
    - `trends` (Object): Objek persentase pertumbuhan dibanding bulan sebelumnya (asesmen, pemegang_sertifikat, asesor, tuk).
  - **Field Baru yang Ditambahkan (Updated)**:
    - `pendaftaran_asesi_baru` (int): Antrean pendaftaran $\rightarrow$ dihitung dari tabel `lsp275_asesi` dengan kriteria `COALESCE(jadwal_id, 0) = 0`.
    - `honor_asesor_belum_dibayar` (int): Antrean honor $\rightarrow$ dihitung dari tabel `lsp275_mapping_asesor` di mana `status_pembayaran_honor = '0'`, `is_complete = '1'`, dan kolom `honor` terisi (bukan null/empty/`0`).
* **Mapping Model Flutter (`DashboardSummary`)**:
  - `total_asesmen` $\rightarrow$ `DashboardSummary.totalAsesmen`
  - `total_pemegang_sertifikat` $\rightarrow$ `DashboardSummary.totalPemegangSertifikat`
  - `total_asesor` $\rightarrow$ `DashboardSummary.totalAsesor`
  - `total_tuk` $\rightarrow$ `DashboardSummary.totalTuk`
  - `total_asesi` $\rightarrow$ `DashboardSummary.totalAsesi`
  - `jadwal_belum_terkonfirmasi` $\rightarrow$ `DashboardSummary.jadwalBelumTerkonfirmasi` (Konter "Approve Jadwal")
  - `surat_tugas_menunggu_pengiriman` $\rightarrow$ `DashboardSummary.suratTugasMenungguPengiriman` (Konter "Laporan")
  - `pendaftaran_asesi_baru` $\rightarrow$ `DashboardSummary.pendaftaranAsesiBaru` (Konter "Pendaftaran")
  - `honor_asesor_belum_dibayar` $\rightarrow$ `DashboardSummary.honorAsesorBelumDibayar` (Konter "Honor")
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "total_asesmen": 45,
    "total_pemegang_sertifikat": 128,
    "total_asesor": 23,
    "total_tuk": 8,
    "total_asesi": 342,
    "jadwal_belum_terkonfirmasi": 10,
    "surat_tugas_menunggu_pengiriman": 4,
    "pendaftaran_asesi_baru": 12,
    "honor_asesor_belum_dibayar": 4,
    "trends": {
      "asesmen": {
        "formatted": "+12,5%"
      },
      "pemegang_sertifikat": {
        "formatted": "+8,3%"
      },
      "asesor": {
        "formatted": "+4,2%"
      },
      "tuk": {
        "formatted": "+0,0%"
      }
    },
    "meta": {
      "is_current_month": true,
      "note": "Perubahan dihitung dibanding bulan lalu"
    }
  }
}
```

---

### A2. Tren Asesmen Bulanan (Grafik) `[REUSED - UPDATED]`
* **Method**: `GET`
* **Endpoint**: `/api/dashboard/assesmen-graph`
* **Deskripsi**: Mengambil data historis jumlah asesmen bulanan untuk merender grafik tren.
* **Headers**: None (Public Endpoint).
* **Parameter Request**: None.
* **Audit Kolom / Field Response**:
  - **Field yang Sudah Ada & Diperbarui**:
    - `label` (String): Label nama bulan (misal "Jan 2026", "Jun 2026").
    - `jumlah_asesmen` (int): Jumlah asesmen bulanan dari snapshot `dashboard_jadwal_bulanan`.
    - `total` (int): Alias dari `jumlah_asesmen` (untuk kecocokan FE).
    - `kompeten` (int): Jumlah asesi berstatus kompeten, diperoleh dari live join `lsp275_jadual_asesmen` + asesi (`terbitkan_sertifikat`).
    - `belum_kompeten` (int): Jumlah asesi belum kompeten, diperoleh dari live join `lsp275_jadual_asesmen` + asesi (`terbitkan_sertifikat`).
    - `is_current_month` (bool): Flag penanda bulan berjalan saat ini.
* **Mapping Model Flutter (`MonthlyAssessment`)**:
  - `label` $\rightarrow$ `MonthlyAssessment.label` (Label X-Axis chart)
  - `total` / `jumlah_asesmen` $\rightarrow$ `MonthlyAssessment.total` (Tinggi bar chart)
  - `kompeten` $\rightarrow$ `MonthlyAssessment.kompeten`
  - `belum_kompeten` $\rightarrow$ `MonthlyAssessment.belumKompeten`
  - `is_current_month` $\rightarrow$ `MonthlyAssessment.isCurrentMonth`
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": [
    {
      "label": "Jan 2026",
      "jumlah_asesmen": 12,
      "total": 12,
      "kompeten": 10,
      "belum_kompeten": 2,
      "is_current_month": false
    },
    {
      "label": "Jun 2026",
      "jumlah_asesmen": 45,
      "total": 45,
      "kompeten": 40,
      "belum_kompeten": 5,
      "is_current_month": true
    }
  ]
}
```

---

### A3. Sebaran Wilayah Asesor `[REUSED - LIVE]`
* **Method**: `GET`
* **Endpoint**: `/api/dashboard/asesor-distribution`
* **Headers**: None (Public Endpoint).
* **Parameter Request (Query)**:
  - `limit` (int, opsional, default: `5`): Membatasi jumlah data provinsi teratas yang ditarik.
* **Response (200 OK)**:
```json
{
  "status": "success",
  "total_asesor": 23,
  "data": [
    {
      "provinsi": "Kalimantan Tengah",
      "total_asesor": 10
    },
    {
      "provinsi": "DKI Jakarta",
      "total_asesor": 5
    }
  ]
}
```

---

### A4. Penyebaran TUK / Mitra `[REUSED - LIVE]`
* **Method**: `GET`
* **Endpoint**: `/api/dashboard/penyebaran-mitra`
* **Headers**: None (Public Endpoint).
* **Parameter Request (Query)**:
  - `limit` (int, opsional, default: `5`): Membatasi jumlah kota/mitra teratas.
* **Response (200 OK)**:
```json
{
  "status": "success",
  "meta": {
    "total_mitra": 8
  },
  "data": [
    {
      "kota": "Sampit",
      "jumlah": 4,
      "mitra": ["LKP Sampit IT", "TUK Palapa"]
    }
  ]
}
```

---

### A5. Total Overview Statistik `[REUSED - LIVE]`
* **Method**: `GET`
* **Endpoint**: `/api/dashboard/statistik-overview`
* **Headers**: None (Public Endpoint).
* **Parameter Request**: None.
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "total_asesi": 9540,
    "sertifikat_terbit": 7890,
    "lsp_terdaftar": 12,
    "tingkat_kelulusan": 82.7,
    "trends": {
      "total_asesi": "+12,4%",
      "sertifikat_terbit": "+8,7%",
      "lsp_terdaftar": "+0,0%",
      "tingkat_kelulusan": "+1,2%"
    }
  }
}
```

---

### A6. Distribusi Asesor Stats `[REUSED - UPDATED]`
* **Method**: `GET`
* **Endpoint**: `/api/dashboard/asesor-stats`
* **Deskripsi**: Mengambil statistik status asesor (aktif, internal, external, online vs offline asesmen, wilayah tercover) untuk tab "Distribusi Asesor".
* **Headers**: None (Public Endpoint).
* **Parameter Request**: None.
* **Audit Kolom / Field Response**:
  - **Field yang Sudah Ada & Diperbarui**:
    - `total_asesor` (int), `asesor_aktif` (int), `asesor_internal` (int), `asesor_external` (int), `total_tuk` (int), `online_asesmen` (int), `offline_asesmen` (int), `wilayah_tercover` (int).
    - `trend_total_asesor` (String): Ditambahkan di root level `data` (misal `"+15,7%"`).
    - `trends.total_asesor` (String): Tetap dipertahankan untuk backward compatibility.
* **Mapping Model Flutter (`AsesorStats`)**:
  - `trend_total_asesor` $\rightarrow$ `AsesorStats.trendTotalAsesor` (dengan fallback ke `trends.total_asesor`)
* **Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "total_asesor": 1317,
    "asesor_aktif": 1200,
    "asesor_internal": 1095,
    "asesor_external": 222,
    "total_tuk": 45,
    "online_asesmen": 1684,
    "offline_asesmen": 5894,
    "wilayah_tercover": 34,
    "trend_total_asesor": "+15,7%",
    "trends": {
      "total_asesor": "+15,7%"
    }
  }
}
```

---

### A7. Distribusi Sertifikat per Skema `[REUSED - LIVE]`
* **Method**: `GET`
* **Endpoint**: `/api/dashboard/sertifikat-per-skema`
* **Headers**: None (Public Endpoint).
* **Parameter Request (Query)**:
  - `limit` (int, opsional, default: `50`): Jumlah skema teratas.
* **Response (200 OK)**:
```json
{
  "status": "success",
  "meta": {
    "total_pemegang_sertifikat": 643
  },
  "data": [
    {
      "id_skema": 1,
      "kode_skema": "SKM-DM-002",
      "skema": "Digital Marketing Madya",
      "kategori": "Digital Marketing",
      "total_pemegang": 200
    }
  ]
}
```

---

### A8. Asesor Berdasarkan Homebase `[NEW - PERLU DIBUAT]`
* **Method**: `GET`
* **Endpoint**: `/api/dashboard/asesor-homebase`
* **Deskripsi**: Mengambil daftar lengkap Asesor beserta domisili homebase dan total asesmen yang telah dijalankan untuk layar **Asessor Berdasarkan Homebase**.
* **Headers**: None (Public Endpoint).
* **Backend Source / Query Notes**:
  - **Sumber Data**: `lsp275_users` (hanya grup asesor yang berstatus aktif: `status_asesor = '1'`).
  - **Kolom `scheme`**: Diambil dari skema pertama yang ter-mapping pada `t_teknis_asesor` $\rightarrow$ `lsp275_skema` (jika kosong/belum terpetakan, kembalikan string kosong `""`).
  - **Kolom `homebase`**: Diambil dari `master_provinsi.name` melalui `provinsi_id` (jika null, kembalikan string kosong `""`).
  - **Kolom `assessments`**: Total jumlah jadwal yang selesai/tahap pelaporan (dihitung dari record `lsp275_mapping_asesor` dengan kriteria `status_jadwal IN ('1', '4')`).
  - **Pengurutan (Ordering)**: Diurutkan berdasarkan `assessments DESC` (jumlah penugasan terbanyak), kemudian secara alfabetis `name ASC`.
  - **Bentuk Response**: Mengikuti standar dashboard (`{ "data": [...] }` tanpa wrapper `status` di top-level).
* **Response (200 OK)**:
```json
{
  "data": [
    {
      "name": "ARI WIBOWO",
      "scheme": "Pemasaran Digital",
      "homebase": "DI YOGYAKARTA",
      "assessments": 241
    },
    {
      "name": "Ajj Oprator Komputer Muda",
      "scheme": "LPP Talenta Digital Marketing",
      "homebase": "JAKARTA",
      "assessments": 8
    }
  ]
}
```





