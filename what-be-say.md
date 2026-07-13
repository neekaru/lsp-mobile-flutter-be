# Asesor API - Endpoints 6-13 Ready

Semua endpoint berikut hanya untuk user dengan role `asesor`. Backend mengambil identitas asesor dari email pada JWT.

## Headers

```http
Authorization: Bearer <access_token>
Accept: application/json
```

---

## 6. Daftar Laporan Tugas Asesor

```http
GET /api/asesor/laporan
```

Menampilkan riwayat laporan tugas dari jadwal yang telah selesai (status `1`/Selesai atau `4`/Pelaporan).

### Response 200 OK

```json
{
  "status": "success",
  "message": "Riwayat laporan tugas berhasil diambil",
  "data": [
    {
      "id": 24346,
      "kode_laporan": "LAP-2025-0819",
      "skema_sertifikasi": "Sertifikasi Disnaker B. Baru -Karir Jitu - Desainer Grafis Muda",
      "tanggal_pelaksanaan": "2025-08-19",
      "tuk": "TUK Mandiri Disnaker Kab. Barito Timur",
      "nama_asesor": "Bambang Fadjar Buwono",
      "status": "Terkonfirmasi"
    }
  ]
}
```

### Keterangan Field

| Field | Keterangan |
|---|---|
| `id` | ID dari `lsp275_mapping_asesor` |
| `kode_laporan` | Dibuat otomatis: `LAP-YYYY-MMDD` dari tanggal jadwal |
| `skema_sertifikasi` | Nama jadwal dari `lsp275_jadual_asesmen.jadual` |
| `tanggal_pelaksanaan` | Format `YYYY-MM-DD` |
| `tuk` | Nama TUK dari `lsp275_tuk.tuk` |
| `nama_asesor` | Nama asesor dari `lsp275_users.users` |
| `status` | `Terkonfirmasi` jika laporan sudah terisi (`ak06` ada data), `Draft` jika belum |

---

## 7. Detail Laporan Tugas Asesor

```http
GET /api/asesor/laporan/:id
```

Contoh:

```http
GET /api/asesor/laporan/24346
```

### Response 200 OK

```json
{
  "status": "success",
  "message": "Detail laporan tugas berhasil diambil",
  "data": {
    "id": 24346,
    "kode_laporan": "LAP-2025-0819",
    "status": "Terkonfirmasi",
    "asesor": "Bambang Fadjar Buwono",
    "skema_sertifikasi": "Sertifikasi Disnaker B. Baru -Karir Jitu - Desainer Grafis Muda",
    "tanggal_pelaksanaan": "19 Agustus 2025",
    "link_dokumentasi": "https://drive.google.com/drive/folders/...",
    "catatan": "Tingkatkan kemampuan kompetensi",
    "kpi_pelaksanaan": {
      "total_asesi": 10,
      "hadir": 10,
      "absen": 0,
      "kompeten": 7,
      "tidak_kompeten": 1
    },
    "dokumen": {
      "surat_tugas_name": "",
      "surat_tugas_url": ""
    },
    "daftar_asesi_dinilai": [
      {
        "nama": "M NOOR",
        "nim": "DKV 1565 39018 2025",
        "kehadiran": "Hadir",
        "penilaian": "K"
      }
    ],
    "lampiran_pendukung": []
  }
}
```

### Keterangan Field

| Field | Sumber DB | Keterangan |
|---|---|---|
| `id` | `mapping_asesor.id` | |
| `kode_laporan` | generated | Format `LAP-YYYY-MMDD` |
| `status` | `ak06` column | `Terkonfirmasi` jika ada data, `Draft` jika kosong |
| `asesor` | `users.users` | |
| `skema_sertifikasi` | `jadual_asesmen.jadual` | |
| `tanggal_pelaksanaan` | `jadual_asesmen.tanggal` | Format Indonesia: `19 Agustus 2025` |
| `link_dokumentasi` | `mapping_asesor.link_rekaman` | Bisa kosong string |
| `catatan` | `mapping_asesor.rekomendasi_peningkatan` | Bisa kosong string |
| `kpi_pelaksanaan.total_asesi` | count from `lsp275_asesi` + `lsp275_asesi_2024` | |
| `kpi_pelaksanaan.hadir` | = total_asesi | DB tidak punya data kehadiran, asumsi semua hadir |
| `kpi_pelaksanaan.absen` | = 0 | DB tidak punya data kehadiran |
| `kpi_pelaksanaan.kompeten` | count where `rekomendasi_asesor = '1'` | |
| `kpi_pelaksanaan.tidak_kompeten` | count where `rekomendasi_asesor = '2'` | |
| `dokumen.surat_tugas_*` | - | Selalu kosong, DB belum menyimpan file Surat Tugas |
| `daftar_asesi_dinilai[].nim` | `asesi.no_registrasi` | |
| `daftar_asesi_dinilai[].kehadiran` | - | Selalu `"Hadir"`, DB belum punya data kehadiran |
| `daftar_asesi_dinilai[].penilaian` | `asesi.rekomendasi_asesor` | `K` (1), `TK` (2), atau `-` (belum dinilai) |
| `lampiran_pendukung` | - | Selalu array kosong `[]`, belum ada storage lampiran |

---

## 8. Daftar Skema & TUK (Dropdown)

```http
GET /api/asesor/skema-tuk
```

Mengembalikan daftar skema sertifikasi yang aktif beserta TUK tempat skema tersebut tersedia, dari relasi `lsp275_tuk_skema`.

### Response 200 OK

```json
{
  "status": "success",
  "message": "Daftar skema sertifikasi & TUK berhasil diambil",
  "data": [
    {
      "id": 335,
      "nama_skema": "Network Administrator Muda",
      "tuk": "LPK Kompetensi Akademi Digital"
    }
  ]
}
```

### Keterangan Field

| Field | Sumber DB |
|---|---|
| `id` | `lsp275_skema.id` |
| `nama_skema` | `lsp275_skema.skema` |
| `tuk` | `lsp275_tuk.tuk` |

---

## 9. Upload Lampiran Pendukung

```http
POST /api/asesor/laporan/upload-lampiran
Content-Type: multipart/form-data
```

### Request Body (Multipart)

| Parameter | Tipe | Keterangan |
|---|---|---|
| `file` | File | Berkas PDF atau Gambar (PNG/JPG/JPEG, Maksimal 5MB) |

### Response 200 OK

```json
{
  "status": "success",
  "message": "Upload File Berhasil",
  "data": {
    "file_name": "Bukti_Pendukung_1.pdf",
    "file_url": "http://host:port/storage/attachments/uuid-generated-name.pdf"
  }
}
```

File disimpan di direktori `storage/attachments/` dengan nama UUID. URL dibangun dari protocol + hostname server.

---

## 10. Kirim Laporan Tugas Baru (Submit Wizard)

```http
POST /api/asesor/laporan
Content-Type: application/json
```

### Request Body (JSON)

```json
{
  "jadwal_id": 9954,
  "nama_asesor": "Muhammad Hanafi",
  "skema_id": 1,
  "tanggal_pelaksanaan": "2026-07-24",
  "surat_tugas_url": "https://example.com/surat-tugas.pdf",
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
    "https://example.com/storage/attachments/temp-bukti-1.pdf"
  ]
}
```

> **PENTING:** `jadwal_id` WAJIB dikirim. Field ini tidak ada di spesifikasi awal tetapi diperlukan backend untuk mengaitkan laporan dengan penugasan asesor di `lsp275_mapping_asesor`. Frontend wajib mengirim `jadwal_id` dari jadwal yang sedang dipilih asesor.

### Response 201 Created

```json
{
  "status": "success",
  "message": "Laporan tugas berhasil dibuat",
  "data": {
    "id": 24346,
    "kode_laporan": "LAP-2026-0724",
    "status": "Terkonfirmasi"
  }
}
```

### Penyimpanan Data

| Field Request | Disimpan ke DB | Keterangan |
|---|---|---|
| `jadwal_id` | lookup `mapping_asesor` | WAJIB, untuk mencari record asesor-jadwal |
| `link_dokumentasi` | `mapping_asesor.link_rekaman` | |
| `catatan` | `mapping_asesor.rekomendasi_peningkatan` | |
| `daftar_peserta[].nim` | lookup `asesi.no_registrasi` | Update `rekomendasi_asesor`: `is_kompeten=true` -> `'1'`, `false` -> `'2'` |
| `surat_tugas_url` | tidak disimpan | DB tidak punya kolom untuk ini |
| `lampiran_pendukung` | tidak disimpan | DB tidak punya tabel storage lampiran |
| `skema_id` | tidak disimpan | Hanya untuk konteks frontend |
| `nama_asesor` | tidak disimpan | Diambil dari JWT |

Backend juga set `mapping_asesor.is_complete = '1'` untuk menandai laporan sudah dikirim.

---

## 11. Profil Asesor (Data Diri)

```http
GET /api/asesor/profile
```

### Response 200 OK

```json
{
  "status": "success",
  "message": "Profil asesor berhasil diambil",
  "data": {
    "id_asesor": "MET.DEMO.000001.2026",
    "nama_lengkap": "Asesor Demo LSP",
    "status_aktif": "Aktif",
    "nik": "",
    "email": "asesor.demo@lsp.id",
    "no_telepon": "081234567891",
    "foto_profil_url": "",
    "instansi": "",
    "alamat": ""
  }
}
```

### Keterangan Field

| Field | Sumber DB | Keterangan |
|---|---|---|
| `id_asesor` | `lsp275_users.no_reg` | Nomor registrasi asesor |
| `nama_lengkap` | `lsp275_users.users` | |
| `status_aktif` | `lsp275_users.status_aktif` | `Y` -> `"Aktif"`, lainnya -> `"Tidak Aktif"` |
| `nik` | - | Selalu kosong, tabel `lsp275_users` tidak punya kolom NIK |
| `email` | `lsp275_users.email` | |
| `no_telepon` | `lsp275_users.hp` | |
| `foto_profil_url` | `lsp275_users.foto_user` | Bisa kosong |
| `instansi` | `lsp275_users.instansi_asesor_external` | Bisa kosong |
| `alamat` | `lsp275_users.alamat` | Bisa kosong |

---

## 12. Update Profil Asesor

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
  "foto_profil_url": "https://example.com/storage/profiles/hanafi.jpg"
}
```

Semua field bersifat opsional. Hanya field yang dikirim yang akan diupdate.

### Response 200 OK

```json
{
  "status": "success",
  "message": "Profil berhasil diperbarui",
  "data": {
    "id_asesor": "MET.DEMO.000001.2026",
    "nama_lengkap": "Asesor Demo LSP",
    "no_telepon": "0858978655634",
    "alamat": "Jl. Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah",
    "instansi": "Politeknik Negeri Sampit"
  }
}
```

### Pemetaan Field

| Field Request | Field DB |
|---|---|
| `no_telepon` | `lsp275_users.hp` |
| `alamat` | `lsp275_users.alamat` |
| `instansi` | `lsp275_users.instansi_asesor_external` |
| `foto_profil_url` | `lsp275_users.foto_user` |

---

## 13. Daftar Honor Asesor (Berdasarkan Periode)

```http
GET /api/asesor/honor?periode=:bulan_tahun
```

### Query Parameters

| Parameter | Tipe | Keterangan |
|---|---|---|
| `periode` | String | Format `NamaBulan Tahun` (contoh: `Juli 2026`, `Juni 2026`). Wajib diisi. |

### Contoh Request

```http
GET /api/asesor/honor?periode=Juli+2026
```

### Response 200 OK

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
      }
    ]
  }
}
```

### Keterangan Field

| Field | Sumber DB | Keterangan |
|---|---|---|
| `periode` | dari query param | Nama bulan Indonesia + tahun |
| `total_honor` | sum of `mapping_asesor.honor` | Format `Rp. X.XXX.XXX` |
| `jumlah_asesmen_selesai` | count of records | Format `N Asesmen selesai` |
| `rincian[].id_detail` | `mapping_asesor.id` | |
| `rincian[].judul_asesmen` | `jadual_asesmen.jadual` | |
| `rincian[].tanggal` | `jadual_asesmen.tanggal` | Format Indonesia: `12 Juli 2026` |
| `rincian[].tuk` | `lsp275_tuk.tuk` | |
| `rincian[].honor` | `mapping_asesor.honor` | Format `Rp. X.XXX.XXX` |

### Catatan Honor

- Data berasal dari `lsp275_mapping_asesor.honor` (varchar) yang difilter untuk jadwal dengan `status_jadwal = '1'` (Selesai).
- Nilai honor di DB bisa berupa angka (`600000`), format titik (`1.000.000`), teks (`Langsung dari TUK`), atau URL.
- Backend membersihkan nilai: menghapus titik, parse sebagai integer. Jika tidak bisa diparse, dianggap `0`.
- Nama bulan yang diterima: `Januari`, `Februari`, `Maret`, `April`, `Mei`, `Juni`, `Juli`, `Agustus`, `September`, `Oktober`, `November`, `Desember` (case-insensitive).

---

## Error Responses

Semua endpoint mengembalikan error seragam:

- `400 Bad Request`: Parameter tidak valid, `jadwal_id` tidak dikirim (EP10), format `periode` salah (EP13).
- `401 Unauthorized`: Token JWT tidak disertakan atau kedaluwarsa.
- `403 Forbidden`: Role user bukan `asesor`, atau asesor mencoba akses data milik asesor lain.
- `404 Not Found`: Data laporan tidak ditemukan (EP7), atau asesor tidak terdaftar.
- `500 Internal Server Error`: Kesalahan database atau server.
