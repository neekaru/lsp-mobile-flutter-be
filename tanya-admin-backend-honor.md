# Pertanyaan & Pengecekan Data Honor Asesor Kosong

Dokumen ini berisi poin-poin pertanyaan dan verifikasi teknis yang dapat dikirimkan kepada **Tim Backend / Admin LSP** terkait penyebab data Honor Asesor mengembalikan respons kosong (`data: []`).

---

## Pesan untuk Tim Backend / Admin

```markdown
Halo Tim Backend / Admin LSP,

Kami ingin mengonfirmasi terkait endpoint Honor Asesor:
- `GET /api/admin/honor-asesor` (Admin Dashboard)
- `GET /api/asesor/honor` (Profil Asesor)

Saat ini respons API mengembalikan `status: "success"`, namun array `data` bernilai kosong (`[]`).

Mohon konfirmasi dan pengecekan beberapa kriteria di database:

### 1. Filter Periode Bulan (`bulan`)
- Backend secara bawaan memfilter berdasarkan bulan berjalan (misal `2026-08` / `YYYY-MM`).
- Jika belum ada jadwal asesmen yang dilaksanakan pada bulan tersebut, hasil akan kosong.
- **Pertanyaan**: Apakah disarankan Mobile App mengirimkan parameter `bulan=semua` secara default jika data bulan berjalan belum ada?

### 2. Validasi Status Jadwal Asesmen
Berdasarkan spesifikasi `what-be-say.md`, backend melakukan filter ketat terhadap jadwal:
- `status_jadwal IN ('1', '4')` (1: Selesai, 4: Pelaporan)
- `status_delete = '1'`
- `status_aktif = 'Y'`
- **Pertanyaan**: Mohon dipastikan apakah data jadwal asesmen di DB saat ini sudah mencapai status '1' / '4', atau masih berstatus '0' (Draft) / '2' (Aktif)?

### 3. Pemetaan Asesor (`lsp275_mapping_asesor`)
- Apakah record penugasan asesor pada tabel `lsp275_mapping_asesor` sudah terhubung dengan `id_asesor` dan `id_jadual` yang valid?

### 4. Permintaan Data Sampel (Seeder / Test Data)
- Mohon bantuan untuk menambahkan data sampel/seeder honor asesor di DB dengan variasi:
  - Status Pembayaran `0` (Menunggu Pembayaran)
  - Status Pembayaran `1` (Pembayaran Selesai)
  - Dilengkapi `link_bukti_pembayaran` (URL cloud/drive)

Terima kasih atas bantuan dan kerjasamanya!
```

---

## Ringkasan Teknis Penyebab Data Kosong

| No | Kemungkinan Penyebab | Penjelasan Teknis Backend |
|---|---|---|
| 1 | **Filter Bulan Berjalan** | Query DB memfilter `tanggal` pelaksanaan jadwal pada bulan berjalan (default `YYYY-MM`). Jika tidak ada jadwal di bulan ini, API mengembalikan `[]`. |
| 2 | **Status Jadwal Belum Selesai** | Query DB mengecualikan jadwal yang berstatus `0` (Draft) atau `2` (Berjalan). Hanya jadwal status `1` (Selesai) & `4` (Pelaporan) yang dihitung honornya. |
| 3 | **Belum Ada Data Penugasan** | Tabel `lsp275_mapping_asesor` di database server belum memiliki entri relasi ke `lsp275_users` (Asesor). |
| 4 | **Format Honor Teks Non-Numerik** | Nilai honor yang diset `0` atau `Langsung Dipotong Oleh TUK` secara otomatis dieksklusikan dari kalkulasi backend. |
