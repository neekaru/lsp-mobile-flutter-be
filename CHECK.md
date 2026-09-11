# Audit Indikasi Double Filtering (Frontend vs Backend) — LSP Mobile

Dokumen ini memetakan seluruh titik di mana terjadi **redundansi filter / double filtering** antara Frontend (`lsp_digital_mobile`) dan Backend (`lsp-mobile/backend`).

---

## 1. Prinsip Utama Pemisahan Peran

| Kategori | Tempat yang Benar | Alasan & Pedoman |
|---|---|---|
| **Aturan Bisnis & State Transaksi** | **Backend (Single Source of Truth)** | Kelayakan edit (`can_edit`), hak akses (`is_my_asesi`), prasyarat tahapan (APL $\rightarrow$ AK), status gembok formulir (`is_locked`). Backend mengembalikan flag kanonikal siap pakai (boolean). |
| **Filter Presentasi & Interaktivitas UI** | **Frontend (Local UI Filter)** | Pencarian teks instan (search query lokal di list), tab kategori tampilan ("Semua", "Asesi Saya", "Tidak Hadir"), pagination visual, dan sorting tampilan lokal. |

> **Larangan**: Jangan menulis ulang kondisi aturan bisnis yang sama dua kali di Frontend dan Backend (`double filtering`). Jika Backend sudah mengevaluasi suatu kondisi dan mengirimkan hasilnya berupa flag, Frontend **wajib langsung mengonsumsi flag tersebut**.

---

## 2. Daftar Titik Terindikasi Double Filtering

### 1. Hak Akses & Rekomendasi Asesi (Daftar Peserta & Simpan Kolektif)
- **Lokasi Frontend:**
  - `lib/widgets/jadwal/asesi_list_cards.dart` (kondisi render DropdownButton)
  - `lib/screens/jadwal/asesi_list_screen.dart` (kondisi filter payload `_saveRekomendasiKolektif`)
  - `lib/models/jadwal_models.dart` (parsing `canEditVal`)
- **Lokasi Backend:**
  - `internal/usecase/asesor_jadwal_usecase.go` (method `Peserta` penentuan `canEdit`)
  - `internal/usecase/asesi_usecase.go` (method `GetAsesiByJadwalID`)
- **Indikasi Redundansi Sebelumnya:**
  - Backend sudah menghitung:
    ```go
    canEdit := isMyAsesi && isAPL01Valid && isAPL02Valid && !isTidakHadir && !isSelesai
    ```
  - Namun Frontend sebelumnya sempat menduplikasi rantai filter yang sama:
    ```dart
    if (asesi.isMyAsesi && asesi.canEdit && asesi.isAPL01Valid && asesi.isAPL02Valid && asesi.isAK02Valid)
    ```
    Bahkan penambahan `isAK02Valid` di FE dan BE sempat memicu bug Catch-22 (peserta belum dinilai malah terkunci, yang sudah dinilai malah kebuka).
- **Status Saat Ini:**
  - **SUDAH DIBERSIHKAN**. Frontend kini langsung mengonsumsi:
    ```dart
    // Parsing model — murni dari flag backend:
    final canEditVal = json['can_edit'] == true;

    // UI Card:
    : item.canEdit ? Container(/* Dropdown */) : Container(/* Read-only */)

    // Kolektif Save:
    if (asesi.canEdit) { ... }
    ```

---

### 2. Validasi Prasyarat Form Detail Asesi (Wizard APL-01 ➔ APL-02 ➔ AK-01 ➔ AK-02 ➔ AK-03 ➔ AK-04)
- **Lokasi Frontend:**
  - `lib/screens/asesi/asesor_detail_asesi_screen.dart` (`isFormUnlocked` & `getLockReason`)
- **Lokasi Backend:**
  - `internal/usecase/asesor_jadwal_usecase.go` (method `DetailAsesi`)
  - `internal/usecase/asesor_jadwal_shared.go` (`buildAsesiFormAccess`, `formAccessFromPrereqs`)
- **Indikasi Redundansi Sebelumnya:**
  - Backend di `DetailAsesi` sudah menghitung status validasi tiap form:
    - `isAPL01Valid`
    - `isApprovedPra` (APL-02 disetujui)
    - `isAK01Valid` (AK-01 disetujui asesi)
    - `ak02Status` (AK-02 selesai / rekomendasi terisi)
    - `ak03Data.IsSudahDiisi`
  - Namun di Frontend, file `asesor_detail_asesi_screen.dart` merangkai ulang logika prasyarat bertingkat:
    ```dart
    // FE memeriksa manual rantai ketergantungan:
    final isAPL01Valid = _detailData!.apl01.isCompleteOrValid;
    final isAPL02Valid = _detailData!.apl02.isCompletedOrApproved;
    final isAK01Valid = _detailData!.ak01.status == 'Disetujui' || _detailData!.ak01.tandaTangan;
    final isAK02Valid = _detailData!.rekomendasiAsesorCode == '1' || ...;
    final isAK03Valid = _detailData!.ak03.isSudahDiisi || ...;
    ```
- **Risiko:**
  - Jika Backend mengubah aturan prasyarat (misal AK-07 tidak lagi butuh APL-02 approved), Frontend lama akan tetap mengunci form tersebut secara sepihak di HP user.
- **Status Saat Ini:**
  - **SUDAH DIBERSIHKAN**. Backend kini mengirim map kesimpulan hak akses form pada response `DetailAsesi`:
    ```json
    "form_access": {
      "APL01": { "unlocked": true,  "reason": "" },
      "APL02": { "unlocked": true,  "reason": "" },
      "AK01":  { "unlocked": false, "reason": "Selesaikan dan simpan rekomendasi FR-APL.02 terlebih dahulu." }
    }
    ```
    Frontend cukup membaca:
    ```dart
    bool isFormUnlocked(String formId) =>
        _detailData!.formAccess[formId]?.unlocked ?? true;

    String getLockReason(String formId) =>
        _detailData!.formAccess[formId]?.reason ?? '';
    ```
    Fallback `?? true` menjaga APK lama / backend lama tidak mengunci form secara sepihak; backend tetap menjadi penentu akhir saat penyimpanan.

---

### 3. Filter List Jadwal Asesor & Admin (Tab Draft, Running, Pelaporan)
- **Lokasi Frontend:**
  - `lib/screens/jadwal/jadwal_screen.dart` (`_loadJadwalData`, `_loadMoreDraft`, `_loadMoreRunning`)
- **Lokasi Backend:**
  - `internal/repository/asesor_jadwal_repository.go` & `jadwal_repository.go` (filter `status_jadwal IN ?`)
  - `internal/delivery/http/jadwal_controller.go` & `asesor_jadwal_controller.go` (parse `status_jadwal`)
- **Indikasi Redundansi Sebelumnya:**
  - API Backend sudah menerima parameter status jadwal (misal `?status_jadwal=draft`, `running`, `completed`) dan menjalankan SQL filtering yang ketat.
  - Namun di Frontend `jadwal_screen.dart`, data hasil response API masih difilter ulang:
    ```dart
    draftList = _sortJadwalList(rawDraft.where((item) => item.isDraft).toList());
    runningList = _sortJadwalList(isAdmin ? rawRunning.where((item) => item.isRunning).toList() : rawRunning);
    ```
- **Risiko:**
  - Jika definisi `isDraft` atau `isRunning` pada helper model Frontend memiliki perbedaan 1 status kode saja dengan query SQL Backend, jadwal yang seharusnya tampil akan hilang (terfilter keluar) di sisi mobile client.
- **Status Saat Ini:**
  - **SUDAH DIBERSIHKAN**. Filter `.where((item) => item.isDraft)` dan `.where((item) => item.isRunning)` dihapus, baik pada load awal maupun load-more. Frontend langsung memakai hasil query endpoint yang memang sudah spesifik meminta tab tersebut:
    ```dart
    draftList = _sortJadwalList(rawDraft);
    runningList = _sortJadwalList(rawRunning);
    ```
  - `_sortJadwalList` dan `_filterSelesaiByTanggalDanTuk` tetap dipertahankan karena keduanya murni presentasi (sorting tampilan + pencarian teks lokal pada endpoint asesi yang tidak menerima parameter `tanggal_asesmen`/`tuk`).

---

### 4. Gembok Formulir FR-APL.02 & FR-AK.01 (Form Edit Lock)
- **Lokasi Frontend:**
  - `lib/widgets/asesi/asesi_apl_sections.dart`
  - `lib/widgets/asesi/asesi_ak01_section.dart`
- **Lokasi Backend:**
  - `internal/usecase/asesor_jadwal_usecase.go` (`DetailAsesi` & `UpdateAPL02`)
- **Indikasi Redundansi Sebelumnya:**
  - Di Backend:
    ```go
    isLockedPra := praVal == "1" || praVal == "2"
    ```
  - Di Frontend:
    ```dart
    final bool isLocked = apl02?.isLocked ??
        (apl02?.praAsesmen == '1' || apl02?.praAsesmen == '2');
    ```
    Frontend memiliki kalkulasi fallback gembok sendiri menggunakan nilai mentah `praAsesmen`.
- **Status Saat Ini:**
  - **SUDAH DIBERSIHKAN**. Backend selalu mengirim `is_locked` sebagai boolean non-null (field `bool` tanpa `omitempty`), dan Frontend murni memakai flag tersebut:
    ```dart
    final bool isLocked = apl02?.isLocked ?? false;
    ```
  - FR-AK.01 juga tidak lagi dihitung dari `status`/`tanda_tangan*` mentah. Backend kini mengirim `ak01.is_approved` (kanonikal: `isAPL01Valid && isApprovedPra && isAK01Approved`):
    ```dart
    final bool isApproved = ak01?.isApproved ?? false;
    ```

---

### 5. Validasi Tombol Simpan Rekomendasi di FR-AK.02
- **Lokasi Frontend:**
  - `lib/widgets/asesi/asesi_ak02_section.dart` (tombol Simpan Rekomendasi Asesor)
- **Lokasi Backend:**
  - `internal/usecase/asesor_jadwal_usecase.go` (`DetailAsesi`, `UpdateAsesiRekomendasi` & `UpdateAK02`)
- **Indikasi Redundansi Sebelumnya:**
  - Di Frontend:
    ```dart
    onPressed: (_isSubmitting || !hasValidMapa || apl02?.praAsesmen != '1') ? null : _submitRekomendasi
    ```
    Frontend menghitung kondisi `hasValidMapa` dan `praAsesmen != '1'`.
  - Di Backend:
    ```go
    if (req.RekomendasiAsesor == "1" || req.RekomendasiAsesor == "2") && (!isAPL02Valid || row.IDMapa == nil || *row.IDMapa == 0)
    ```
    Backend memeriksa kembali aturan bisnis yang persis sama.
- **Status Saat Ini:**
  - **SUDAH DIBERSIHKAN**. Backend mengirim flag kanonikal `ak02.can_submit` (dihitung dari `isAPL01Valid && isApprovedPra && IDMapa != 0` — persis aturan yang dipakai `UpdateAsesiRekomendasi`/`UpdateAK02`):
    ```go
    canSubmitAK02 := isAPL01Valid && isApprovedPra && row.IDMapa != nil && *row.IDMapa != 0
    ```
    ```dart
    onPressed: (_isSubmitting || !(ak02?.canSubmit ?? false)) ? null : _submitRekomendasi,
    ```
    `hasValidMapa` tetap dipakai untuk merender ringkasan hasil asesmen (murni presentasi), bukan lagi sebagai gerbang simpan.

---

### 6. Perhitungan Agregasi & Counter Status (Sertifikat & Permohonan)
- **Lokasi Frontend:**
  - `lib/screens/sertifikat/asesi_sertifikat_screen.dart` (counter tab Aktif / Akan Berakhir / Kadaluarsa)
  - `lib/screens/pendaftaran/permohonan_pendaftaran_screen.dart` (`_verifiedCount`, `_pendingCount`)
- **Lokasi Backend:**
  - `internal/usecase/asesi_usecase.go` (`ListSertifikat` + `mapSertifikatRow`)
  - `internal/usecase/permohonan_usecase.go` (`GetList`)
  - `internal/repository/permohonan_repository.go` (`GetPermohonanList`)
- **Indikasi Redundansi Sebelumnya:**
  - Frontend menghitung manual counter status dengan pencocokan string lokal (bahkan menangani fallback typo legacy database `'terferivikasi'`).
- **Status Saat Ini:**
  - **SUDAH DIBERSIHKAN**. Backend mengembalikan objek agregasi siap pakai:
    ```json
    "meta": { "total": 12, "total_aktif": 10, "total_akan_kadaluarsa": 1, "total_kadaluarsa": 1 }
    ```
    ```json
    "meta": { "total": 50, "total_terverifikasi": 20, "total_menunggu": 30 }
    ```
    Frontend langsung membaca `meta`:
    ```dart
    final int aktifCount = (_meta['total_aktif'] as num?)?.toInt() ?? 0;
    int get _verifiedCount => (_meta['total_terverifikasi'] as num?)?.toInt() ?? 0;
    ```
  - Status item permohonan kini juga dihitung backend dengan aturan yang identik dengan endpoint detail (`pra_asesmen = '1' OR is_confirm = '1'`), sehingga badge List dan Detail tidak bisa berbeda:
    ```sql
    CASE WHEN a.pra_asesmen = '1' OR a.is_confirm = '1' THEN 'Terverifikasi' ELSE 'Menunggu' END as status
    ```
    Pencocokan string lokal `contains('terverifikasi') || contains('terferivikasi')` dihapus (termasuk di `detail_permohonan_screen.dart`).

---

## 3. Checklist Sebelum Menulis Filter Baru

Sebelum menambahkan `if (...)` atau `.where(...)` di Frontend:
- [ ] **Apakah kondisi ini menentukan hak akses / otorisasi / state bisnis?**
  - $\rightarrow$ **Wajib di Backend**. Kembalikan flag boolean jelas (misal: `can_edit`, `can_submit`, `is_locked`, `form_access`).
- [ ] **Apakah kondisi ini murni tampilan visual interaktif (search query teks lokal, tab visual)?**
  - $\rightarrow$ **Cocok di Frontend**.
- [ ] **Apakah kondisi ini sudah diperiksa oleh Backend?**
  - $\rightarrow$ **Jangan tulis ulang di Frontend**. Gunakan langsung flag yang dikirim oleh Backend.

---

## 4. Ringkasan Kontrak Flag Kanonikal (Backend ➔ Frontend)

| Endpoint | Flag Kanonikal | Arti |
|---|---|---|
| `GET /api/asesor/asesi/:id` | `form_access.<FORM>.unlocked` / `.reason` | Hak akses & alasan kunci tiap formulir (APL01, APL02, AK07, AK01, AK02, AK03) |
| `GET /api/asesor/asesi/:id` | `apl02.is_locked` | FR-APL.02 sudah ada persetujuan/rekomendasi (read-only) |
| `GET /api/asesor/asesi/:id` | `ak01.is_approved` | FR-AK.01 sudah disetujui asesi & asesor |
| `GET /api/asesor/asesi/:id` | `ak02.can_submit` | Rekomendasi FR-AK.02 boleh disimpan (APL-02 approved + MAPA terpilih) |
| `GET /api/asesor/jadwal/:id/peserta` | `can_edit` / `can_view_detail` / `is_my_asesi` | Kelayakan edit & lihat detail peserta |
| `GET /api/asesi/sertifikat` | `meta.total_aktif` / `total_akan_kadaluarsa` / `total_kadaluarsa` | Counter tab sertifikat |
| `GET /api/permohonan` | `meta.total_terverifikasi` / `total_menunggu`, item `status` | Counter tab & status verifikasi permohonan |

**Backward compatible**: seluruh field baru bersifat aditif. APK versi lama yang belum membaca `form_access`/`meta` tetap berjalan dengan data lama (list + field status yang sudah ada), dan APK baru yang membaca flag kanonikal tidak akan mengunci form secara sepihak bila backend belum mengirimnya (`?? true` / `?? 0`).
