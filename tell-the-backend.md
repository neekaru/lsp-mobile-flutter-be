# Kontrak Backend LSP Mobile: Pendaftaran Publik dan Asesi

Dokumen ini **menggantikan seluruh isi kontrak sebelumnya**. Fokus kontrak adalah pendaftaran publik calon Asesi, pembuatan akun otomatis, login memakai NIK, serta pembatasan pemilihan skema berdasarkan riwayat asesmen.

## Aturan Bisnis Utama

| ID | Aturan |
|---|---|
| BR-01 | Pengunjung publik dapat membuka informasi umum, mencari/validasi sertifikat, dan mengirim pendaftaran calon Asesi tanpa login. |
| BR-02 | Pendaftaran publik yang berhasil wajib membuat akun pengguna berperan `asesi` secara otomatis. |
| BR-03 | Username/identity akun Asesi adalah **NIK** dari pendaftaran. Password awal adalah **`123456`**. Password hanya diinformasikan di UI, tidak boleh dikembalikan dalam response API maupun log. |
| BR-04 | NIK harus unik. Satu NIK tidak boleh membuat lebih dari satu akun atau pendaftaran identitas yang sama. |
| BR-05 | Profil Asesi, pemilihan skema, pendaftaran asesmen, pra-asesmen, portofolio, jadwal, dan sertifikat privat hanya boleh diakses oleh akun Asesi yang sudah login. |
| BR-06 | Asesi hanya dapat memilih dan mendaftar pada skema yang **belum pernah diuji** oleh Asesi tersebut. Skema pernah diuji tidak boleh ditampilkan sebagai pilihan dan backend tetap wajib menolak request yang dimanipulasi. |
| BR-07 | Status apa pun yang membuktikan Asesi sudah pernah masuk proses uji pada suatu `skema_id` dianggap sebagai riwayat uji, termasuk pendaftaran aktif, selesai, kompeten, atau belum kompeten. Backend harus memakai satu definisi yang konsisten pada endpoint daftar skema dan endpoint pendaftaran. |

## Autentikasi dan Otorisasi

Semua endpoint privat wajib memakai header berikut:

```http
Authorization: Bearer <access_token>
Accept: application/json
```

| Area | Akses |
|---|---|
| Informasi publik, pencarian sertifikat, validasi sertifikat, pendaftaran publik | Tanpa token |
| Data pribadi dan proses sertifikasi Asesi | JWT dengan role `asesi` |
| Data Admin/Asesor | Mengikuti role masing-masing; token Asesi tidak boleh mengaksesnya |

## Endpoint

### 1. Pendaftaran Publik dan Akun Otomatis

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `POST` | `/api/public/registrasi` | Publik | Menyimpan pendaftaran calon Asesi dan membuat akun Asesi otomatis |

#### Request

```json
{
  "nik": "6201010101010001",
  "nama_lengkap": "Nama Calon Asesi",
  "email": "calon.asesi@example.com",
  "no_telepon": "081234567890",
  "alamat": "Alamat domisili calon Asesi"
}
```

| Field | Wajib | Validasi |
|---|---:|---|
| `nik` | Ya | String numerik 16 digit dan belum terdaftar sebagai akun/identitas Asesi |
| `nama_lengkap` | Ya | Tidak kosong |
| `email` | Ya | Format email valid |
| `no_telepon` | Ya | Nomor telepon valid |
| `alamat` | Ya | Tidak kosong |

#### Proses Backend Wajib

1. Validasi seluruh field dan normalisasi NIK sebagai string.
2. Pastikan NIK belum ada pada akun pengguna maupun data Asesi.
3. Buat akun pengguna dengan `role: "asesi"`, identity/username berupa NIK, dan password awal `123456` yang disimpan sebagai hash.
4. Buat record Asesi yang terhubung ke akun tersebut dalam satu transaksi database.
5. Jika salah satu proses gagal, rollback seluruh transaksi agar tidak ada akun atau Asesi yatim.
6. Jangan mengirim password, hash password, token, atau detail internal melalui response maupun log.

#### Response Berhasil: `201 Created`

```json
{
  "status": "success",
  "message": "Pendaftaran berhasil. Akun Asesi telah dibuat.",
  "data": {
    "asesi_id": 451,
    "identity": "6201010101010001",
    "role": "asesi",
    "login_instruction": "Masuk menggunakan NIK dan password awal 123456."
  }
}
```

#### Respons Gagal

| Kondisi | HTTP | Pesan minimum |
|---|---:|---|
| Field tidak valid | `422` | Menjelaskan field yang harus diperbaiki |
| NIK telah terdaftar | `409` | `NIK sudah terdaftar. Silakan login menggunakan NIK Anda.` |
| Gangguan transaksi | `500` | Pesan aman tanpa detail internal |

### 2. Login Asesi

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `POST` | `/api/auth/login` | Publik | Login akun yang dibuat otomatis maupun akun lain |

#### Request login Asesi

```json
{
  "identity": "6201010101010001",
  "password": "123456",
  "role": "asesi"
}
```

#### Response Berhasil: `200 OK`

```json
{
  "status": "success",
  "data": {
    "token": "<access_token>",
    "refresh_token": "<refresh_token>",
    "user": {
      "id": 1,
      "name": "Nama Calon Asesi",
      "identity": "6201010101010001",
      "role": "asesi",
      "roles": ["asesi"]
    }
  }
}
```

### 3. Daftar Skema yang Bisa Dipilih Asesi

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/sertifikat/skema` | Role `asesi` | Mengambil hanya skema yang belum pernah diuji oleh Asesi login |
| `GET` | `/api/sertifikat/skema/bidang` | Role `asesi` | Mengambil bidang/filter skema yang masih dapat dipilih |
| `GET` | `/api/sertifikat/skema/:id` | Role `asesi` | Mengambil detail skema yang dapat dipilih |
| `GET` | `/api/sertifikat/skema/:id/asesor` | Role `asesi` | Mengambil rekomendasi asesor untuk skema yang dapat dipilih |

#### Query opsional

| Parameter | Contoh | Fungsi |
|---|---|---|
| `search` | `digital marketing` | Cari nama atau kode skema |
| `bidang_id` | `2` | Filter bidang skema |
| `limit` | `20` | Batas jumlah data |
| `offset` | `0` | Posisi pagination |

#### Ketentuan Filter Wajib

Backend harus menentukan daftar `skema_id` riwayat Asesi dari akun JWT, lalu mengecualikannya dari hasil. Frontend tidak boleh menjadi satu-satunya pengaman.

```text
eligible_schemes = all_schemes MINUS schemes_ever_tested_by_current_asesi
```

#### Response Berhasil: `200 OK`

```json
{
  "status": "success",
  "data": [
    {
      "id_skema": 8,
      "kode_skema": "SKM-UI-008",
      "skema": "Junior Web Developer",
      "kategori": "Informatika",
      "is_eligible": true
    }
  ],
  "meta": {
    "excluded_previously_tested_count": 2,
    "limit": 20,
    "offset": 0
  }
}
```

Jika seluruh skema sudah pernah diuji, endpoint tetap mengembalikan `200 OK` dengan `data: []` dan metadata yang benar.

### 4. Detail Status Sertifikasi

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `GET` | `/api/sertifikasi/status?skema_id=:id` | Role `asesi` | Menampilkan status pendaftaran Asesi untuk skema tertentu |

Response harus membedakan skema yang belum pernah diuji dan yang pernah diuji:

```json
{
  "status": "success",
  "data": {
    "skema_id": 1,
    "is_eligible": false,
    "has_been_tested": true,
    "status_pendaftaran": "selesai",
    "message": "Anda sudah pernah diuji pada skema ini dan tidak dapat mendaftar kembali."
  }
}
```

### 5. Pendaftaran Asesmen

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| `POST` | `/api/sertifikasi/daftar` | Role `asesi` | Mendaftarkan Asesi ke skema yang belum pernah diuji |

#### Request

```json
{
  "skema_id": 8,
  "tuk_id": 2,
  "tanggal_rencana": "2026-08-10"
}
```

#### Validasi Server Wajib

1. Identitas Asesi berasal dari JWT, bukan dari request body.
2. `skema_id` harus ada dan tersedia.
3. `skema_id` tidak boleh berada dalam riwayat skema yang pernah diuji oleh Asesi.
4. TUK dan tanggal rencana harus valid untuk skema tersebut.
5. Gunakan transaksi dan constraint/locking yang tepat agar dua request paralel tidak membuat pendaftaran ganda.

#### Response Berhasil: `201 Created`

```json
{
  "status": "success",
  "message": "Pendaftaran berhasil disimpan",
  "data": {
    "sertifikasi_id": 451,
    "status": "terdaftar",
    "skema_id": 8
  }
}
```

#### Response Skema Pernah Diuji: `422 Unprocessable Entity`

```json
{
  "status": "error",
  "code": "SCHEME_ALREADY_TESTED",
  "message": "Anda sudah pernah diuji pada skema ini dan tidak dapat mendaftar kembali."
}
```

### 6. Endpoint Privat Asesi Lainnya

Endpoint berikut tetap diperlukan untuk proses setelah akun dibuat dan login. Semua wajib memverifikasi role `asesi` serta kepemilikan sumber daya dari JWT.

| Metode | Endpoint | Fungsi |
|---|---|---|
| `GET` | `/api/asesi/dashboard` | Ringkasan skema, sertifikat, banner, dan berita Asesi |
| `GET` | `/api/asesi/jadwal` | Jadwal milik Asesi login |
| `GET` | `/api/pra-asesmen/skema/:id/info` | Informasi pra-asesmen milik Asesi |
| `GET` | `/api/pra-asesmen/skema/:id/kompetensi` | Unit kompetensi dan KUK |
| `POST` | `/api/pra-asesmen/skema/:id/submit` | Simpan jawaban pra-asesmen |
| `GET` | `/api/sertifikasi/:id/portofolio` | Daftar portofolio pendaftaran milik Asesi |
| `POST` | `/api/sertifikasi/:id/portofolio/upload` | Unggah portofolio multipart |
| `GET` | `/api/asesor/profile` | Data diri bersama untuk Asesor/Asesi |
| `PUT` | `/api/asesor/profile` | Ubah data diri yang diizinkan |
| `GET` | `/api/asesi/instansi` | Data instansi Asesi |
| `PUT` | `/api/asesi/instansi` | Ubah data instansi Asesi |
| `GET` | `/api/asesi/sertifikat` | Sertifikat terbit milik Asesi |
| `GET` | `/api/asesi/sertifikat/:id` | Detail sertifikat milik Asesi |
| `POST` | `/api/asesi/sertifikat/:id/upload-ttd` | Unggah foto/TTD sertifikat |
| `GET` | `/api/asesi/sertifikat/:id/download` | URL unduh sertifikat milik Asesi |

### 7. Endpoint Publik Tetap

| Metode | Endpoint | Fungsi |
|---|---|---|
| `GET` | `/api/berita` | Daftar berita publik |
| `GET` | `/api/berita/:id` | Detail berita publik |
| `GET` | `/api/sertifikat/search` | Pencarian sertifikat publik |
| `POST` | `/api/sertifikat/validate` | Validasi nomor sertifikat publik |

## Format Error Global

```json
{
  "status": "error",
  "code": "MACHINE_READABLE_CODE",
  "message": "Pesan yang aman dan dapat ditampilkan ke pengguna.",
  "errors": {
    "field": ["Pesan validasi field"]
  }
}
```

| HTTP | Penggunaan |
|---:|---|
| `401` | Token tidak ada, tidak valid, atau kedaluwarsa |
| `403` | Role tidak memiliki akses |
| `404` | Sumber daya tidak ada atau bukan milik pengguna |
| `409` | NIK sudah memiliki akun/pendaftaran identitas yang sama |
| `422` | Validasi request gagal atau Asesi memilih skema yang pernah diuji |
| `500` | Kegagalan internal tanpa membocorkan detail sistem |

## Kriteria Penerimaan Backend

| ID | Kriteria |
|---|---|
| AC-01 | Pendaftaran publik dengan NIK baru membuat tepat satu akun `asesi` dan tepat satu record Asesi secara atomik. |
| AC-02 | NIK yang sama tidak dapat membuat akun kedua dan menghasilkan `409`. |
| AC-03 | Akun hasil pendaftaran dapat login menggunakan NIK serta password awal `123456`. |
| AC-04 | Tanpa JWT, pengguna tidak dapat membuka profil atau memulai proses asesmen. |
| AC-05 | Endpoint daftar skema tidak mengembalikan skema yang pernah diuji oleh Asesi login. |
| AC-06 | `POST /api/sertifikasi/daftar` menolak skema pernah diuji dengan `422` dan kode `SCHEME_ALREADY_TESTED`, termasuk bila request dibuat di luar aplikasi. |
| AC-07 | Asesi tidak dapat membaca, mengubah, atau mengunduh sumber daya milik Asesi lain. |
