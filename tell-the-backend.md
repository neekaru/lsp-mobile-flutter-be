# Dokumen Kolaborasi API Frontend & Backend (LSP Digital Mobile)

Dokumen ini berisi daftar endpoint baru yang dibutuhkan oleh tim Frontend untuk menyelesaikan modul Pendaftaran, Asesor, dan Pra-Asesmen.

---

## 1. 🔍 Endpoint: Rekomendasi Asesor per Skema

```http
GET /api/sertifikat/skema/:id/asesor
```

### Headers
```http
Authorization: Bearer <access_token>
Accept: application/json
```

### Deskripsi
Mengembalikan daftar asesor yang memiliki kompetensi sesuai dengan skema sertifikasi (`:id` di URL mewakili `id_skema`). Data ini digunakan untuk menampilkan rekomendasi asesor di halaman `AsesorRecommendationScreen` setelah asesi mengonfirmasi pendaftaran.

### Response Format (200 OK)
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
    }
  ]
}
```

---

## 2. 📋 Endpoint: Informasi Jadwal & Detail Pra-Asesmen (Step 1 Wizard)

```http
GET /api/pra-asesmen/skema/:id/info
```

### Headers
```http
Authorization: Bearer <access_token>
Accept: application/json
```

### Deskripsi
Mengembalikan detail informasi skema, jadwal asesmen, lokasi Tempat Uji Kompetensi (TUK), dan nama asesor pendamping/pemantau untuk skema yang sedang didaftarkan oleh asesi. Data ini digunakan untuk melengkapi data di **Step 1 (Informasi Skema)** pada wizard pra-asesmen agar tidak lagi hardcoded.

### Response Format (200 OK)
```json
{
  "status": "success",
  "message": "Pra-asesmen info retrieved successfully",
  "data": {
    "skema_id": 12,
    "nama_skema": "Digital Marketing",
    "kode_skema": "SKM.70MKT00.010.2",
    "tanggal_asesmen": "2026-05-20",
    "tuk": "TUK Universitas LPP",
    "nama_asesor": "Eko Setiabudi"
  }
}
```

---

## 2b. 📝 Endpoint: Daftar Unit & Pertanyaan Evaluasi Mandiri (Step 2 Wizard)

```http
GET /api/pra-asesmen/skema/:id/kompetensi
```

### Headers
```http
Authorization: Bearer <access_token>
Accept: application/json
```

### Deskripsi
Mengembalikan daftar Unit Kompetensi beserta Elemen/Kriteria Unjuk Kerja (KUK) untuk skema yang dipilih. Data ini digunakan untuk merender daftar pertanyaan penilaian kemampuan diri/evaluasi mandiri secara dinamis pada **Step 2 (Evaluasi Mandiri)**.

### Response Format (200 OK)
```json
{
  "status": "success",
  "message": "Competency units and questions retrieved successfully",
  "data": {
    "skema_id": 12,
    "nama_skema": "Digital Marketing",
    "unit_kompetensi": [
      {
        "kode_unit": "M.70MKT00.010.2",
        "judul_unit": "Mengolah Data Riset",
        "elemen": [
          {
            "id_elemen": 101,
            "pertanyaan_kuk": "Apakah Anda dapat merancang instrumen riset pasar sesuai kebutuhan pemasaran?"
          },
          {
            "id_elemen": 102,
            "pertanyaan_kuk": "Apakah Anda dapat menganalisis data riset menggunakan software pengolah data?"
          }
        ]
      },
      {
        "kode_unit": "M.70MKT00.013.1",
        "judul_unit": "Melaksanakan Kegiatan Analisis di Media Sosial",
        "elemen": [
          {
            "id_elemen": 201,
            "pertanyaan_kuk": "Apakah Anda dapat memonitor matrik engagement media sosial secara berkala?"
          }
        ]
      }
    ]
  }
}
```

---

## 3. 📤 Endpoint: Submit Jawaban Pra-Asesmen (Step 2 - 4 Wizard)

```http
POST /api/pra-asesmen/skema/:id/submit
```

### Headers
```http
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

### Request Body (JSON)
Mengirimkan data evaluasi mandiri (Step 2), riwayat pengalaman kerja (Step 3), dan lembar persetujuan/komitmen asesi (Step 4).
```json
{
  "jawaban_evaluasi": [
    {
      "kode_unit": "M.70MKT00.010.2",
      "judul_unit": "Mengolah Data Riset",
      "jawaban": "ya"
    },
    {
      "kode_unit": "M.70MKT00.013.1",
      "judul_unit": "Melaksanakan Kegiatan Analisis di Media Sosial dan Media Bisnis Digital",
      "jawaban": "ya"
    }
  ],
  "pengalaman_kerja": {
    "has_experience": true,
    "perusahaan": "PT Solusi Digital",
    "posisi": "Digital Marketer",
    "durasi": "2 Tahun"
  },
  "persetujuan": {
    "agreement_1": true,
    "agreement_2": true,
    "agreement_3": true,
    "agree_terms": true
  }
}
```

### Response Format (200 OK / 201 Created)
```json
{
  "status": "success",
  "message": "Pra-asesmen submitted successfully",
  "data": {
    "pendaftaran_id": 105,
    "skema_id": 12,
    "status_pendaftaran": "pra_asesmen_submitted",
    "submitted_at": "2026-07-08T12:50:00Z"
  }
}
```

---

## 4. 📊 Endpoint: Hasil Review Pra-Asesmen

```http
GET /api/pra-asesmen/skema/:id/review
```

### Headers
```http
Authorization: Bearer <access_token>
Accept: application/json
```

### Deskripsi
Mendapatkan status review/evaluasi pra-asesmen dari pihak LSP/Asesor. Ini digunakan untuk menentukan apakah asesi memenuhi syarat (MS) untuk lanjut ke tahap **Tes Tertulis** atau harus memperbaiki data.

### Response Format (200 OK)
```json
{
  "status": "success",
  "message": "Review status retrieved successfully",
  "data": {
    "skema_id": 12,
    "status_review": "memenuhi_syarat",
    "keterangan": "Anda memenuhi persyaratan untuk mengikuti Tes Tertulis.",
    "checklist": {
      "portofolio_lengkap": true,
      "bukti_kompetensi_valid": true,
      "pra_asesmen_disetujui": true
    }
  }
}
```

---

## 🛠️ Catatan Implementasi Backend (GORM / Database Reference)
* **Penyaringan Asesor**: Data asesor disaring berdasarkan kompetensi skema (pemetaan `lsp275_mapping_asesor` atau tabel keahlian asesor yang terkait dengan `id_skema`).
* **Relasi Pra-Asesmen**: Buat tabel baru/kolom relasi `lsp275_pra_asesmen` yang mencatat detail evaluasi mandiri asesi, pengalaman kerja, serta status reviewnya.
* **Integrasi Status**: Pastikan ketika pra-asesmen disubmit, status pendaftaran asesi di-update (misal: `status_pendaftaran = 'pra_asesmen_submitted'`).
