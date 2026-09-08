# Agent Instructions — LSP Mobile Frontend (Flutter)

## Prinsip kerja (WAJIB)

- **STOP OVERTHINKING.** User mau hasil cepat. Jangan bertele-tele, jangan analisis berlebihan, jangan ragu-ragu.
- Langsung eksekusi setelah memahami permintaan. Kalau ambigu, ambil interpretasi paling masuk akal dari kode yang ada.
- Jangan menambah fitur/helper/komentar yang tidak diminta.

## Prinsip Universal "Sekali Update Beres" & Defensive Mobile Coding (WAJIB)

> **PRINSIP UTAMA**: Review & rilis update ke Google Play Store memakan waktu dan proses panjang. **KITA HARUS SEKALI UPDATE LANGSUNG TUNTAS & BERSIH** tanpa ada bug sepele, ketidakkonsistenan data, atau regresi yang memaksa update berulang.

Untuk **SETIAP PERUBAHAN APAPUN** (Widget, Screen, Form, Model Parsing, Service API, Navigasi, State Management, Filter/Search, Storage/Cache):

1. **Kepatuhan pada Kontrak Backend & Kebijakan Breaking Changes**:
   - Frontend **WAJIB selalu selaras dengan struktur data dan kontrak resmi Backend**.
   - **Breaking Changes Diizinkan Jika Benar-Benar Diperlukan**: Jika perombakan UI/UX, simplifikasi model, atau kebutuhan bisnis menuntut perubahan struktur, breaking changes **boleh dilakukan** dengan menyelaraskan kedua sisi (Frontend & Backend) sekaligus.
   - **Jika Tidak Perlu Breaking Changes $\rightarrow$ WAJIB 100% Backward Compatible**:
     - Jika perubahan tidak memerlukan breaking change, pertahankan fallback field dan parsing yang toleran agar APK versi sebelumnya tetap aman dan tidak crash.

2. **Defensive Parsing & Fault-Tolerant by Default**:
   - Model Flutter **WAJIB** kebal terhadap segala variasi format API backend:
     - Gunakan `JsonHelper.asInt`, `JsonHelper.asBool`, `JsonHelper.asString` untuk mencegah runtime type mismatch (misal backend kirim string `"123"` vs int `123`, `true` vs `"1"` vs `1`).
     - Jangan pernah berasumsi key/field selalu ada atau tidak pernah `null` (selalu sediakan safe default value).
     - Parser status/enum/label **WAJIB** case-insensitive dan menangani format kode angka maupun format teks (contoh: `'0'/'draft'/'menunggu'`, `'1'/'selesai'/'completed'`).

3. **Konsistensi Alur Data Navigasi (Dashboard ➔ List ➔ Detail ➔ Form Action)**:
   - Saat mengoper data lewat route arguments/model converter (misal `toJadwalItem()`, `toAsesiItem()`), pastikan seluruh field esensial terpetakan lengkap tanpa ada data yang terpotong.
   - Di halaman Detail / Edit: **WAJIB memprioritaskan data realtime hasil fetch API** (`detailData`) dibanding argumen awal navigasi yang statis/usang.

4. **Audit 360° Semua Entry Point (Cross-Module Verification)**:
   - Sebelum menyatakan task selesai, uji semua alur masuk:
     - Dari Dashboard Card/Shortcut
     - Dari List Menu / Filter Tab
     - Dari Notifikasi / Dialog
     - Dari Search Bar / Modal Picker
   - Pastikan status, warna badge, aksi tombol, dan data yang tampil **100% identik dan konsisten** di semua jalur tersebut.

5. **Self-Verification Checklist**:
   - [ ] Jika ada breaking change, apakah memang benar-benar diperlukan dan sudah diselaraskan di frontend & backend? Jika tidak perlu, apakah model/parsing sudah 100% backward compatible?
   - [ ] Apakah model parsing aman jika backend mengirim field null/empty atau tipe yang berbeda?
   - [ ] Apakah data di Dashboard, List, dan Detail selaras dan tidak ada status mismatch?
   - [ ] Apakah semua state UI (Loading, Empty Data, Error / Offline, Success) tertangani dengan rapi?
   - [ ] Apakah ada sisa mock/hardcode yang belum diganti data dinamis?

## Clean Code & Standar Flutter (WAJIB)

- Pertahankan struktur folder dan arsitektur yang sudah ada di Flutter (`lib/`).
- Hindari membuat widget monolithic / god widget dalam satu file jika sudah terlalu panjang (> 500 baris). Pisahkan sub-widget / helper component ke file terpisah.
- Ikuti linting standard (`flutter_lints`).

## Git & File Management (WAJIB)

### LARANGAN MUTLAK `git add .` (ZERO TOLERANCE)

**DILARANG KERAS DAN MUTLAK** menjalankan command berikut:
- `git add .`
- `git add -A`
- `git add --all`
- `git add *`
- `git add -u`
- Stage semua file / bulk staging secara liar

**TIDAK BOLEH BERALIBI DENGAN ALASAN APA PUN:**
- ❌ **DILARANG beralibi** "biar cepat / praktis"
- ❌ **DILARANG beralibi** "hanya file yang diubah saja kok"
- ❌ **DILARANG beralibi** "sudah ada .gitignore jadi pasti aman"
- ❌ **DILARANG beralibi** "semua file sudah dicek satu-satu"
- ❌ **DILARANG beralibi** "cuma nambah 1-2 baris"
- ❌ **DILARANG beralibi** untuk efisiensi, kelupaan, atau alasan teknis/non-teknis lainnya

**SATU-SATUNYA PENGECUALIAN:**
Command `git add .` **HANYA** boleh dijalankan jika **USER SECARA EKSPLISIT** mengetikkan dan memerintahkan "git add ." di chat. Jika tidak ada perintah tertulis dari user, command ini **100% HARAM & DILARANG**.

**CARA STAGING YANG WAJIB:**
Selalu tambahkan file secara **eksplisit dan spesifik satu per satu** hanya pada file yang relevan dengan task yang dikerjakan:
```bash
git add path/to/specific_file.dart
git add path/to/another_file.dart
```

### File yang TIDAK BOLEH di-push:

**JANGAN PERNAH** commit/push file-file berikut:

- File kredensial/kunci: `*.jks`, `*.keystore`, `key.properties`, `local.properties`, `google-services.json` (kecuali public template)
- `.env`, `.env.*` (kecuali `.env.example`)
- `*_demo.txt`, `login.json`, `completed.json`
- `*.bak`, `*.tmp`, `*.log`
- Build artifacts / folder `build/`, `.dart_tool/`
- File testing/demo lainnya

**Action sebelum commit:**
```bash
# Cek file yang akan di-commit
git status

# Jika ada file sensitif/build/demo, remove dari staging:
git reset HEAD <file>
```
