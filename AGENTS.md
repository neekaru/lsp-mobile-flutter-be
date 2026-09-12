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

5. **Pemisahan Peran Filter & Larangan Redundan (No Duplicate / Double Filtering)**:
   - **Backend adalah Single Source of Truth untuk Aturan Bisnis & Otorisasi**:
     - Jangan pernah menulis ulang rantai filter bisnis di Frontend jika Backend sudah menyediakan flag kesimpulan (contoh: Backend sudah mengirim `can_edit: true/false`, maka Frontend **cukup** menggunakan `if (item.canEdit)`).
     - **DILARANG KERAS double filter**: Hindari pola seperti `if (item.canEdit && item.isAPL01Valid && item.isAPL02Valid && !isJadwalSelesai)`. Menulis ulang filter yang sama dua kali di FE dan BE hanya menambah kompleksitas, rawan desync, dan memaksa update APK berulang ketika aturan bisnis di Backend berubah.
   - **Peran Filter yang Tepat di Frontend**:
     - Frontend **hanya** menangani filter tampilan/presentasi lokal yang memang cocok di FE: pencarian teks lokal (search query), tab filter visual (misal tab "Semua", "Asesi Saya", "Tidak Hadir"), pagination visual, dan sorting UI.
     - Prinsip: Jika filter cocok di FE maka di FE; jika filter cocok di BE (aturan bisnis/akses) maka di BE — **jangan tulis dua kali**.
   - **Kewajiban AI Saat Membuat Fitur/Filter Baru**:
     - Ketika membuat fitur baru yang melibatkan filter/validasi, **AI WAJIB memastikan lokasinya tunggal (BE atau FE)**:
       1. **Utamakan Cek Pola Codebase yang Ada (Biar Cepat)**: Ikuti pola yang sudah terbukti di modul lain.
       2. **WAJIB Tanya ke User jika Ragu/Ambigu**: Jika tidak yakin apakah filter harus ditaruh di BE (query/business flag) atau FE (interaksi lokal), **AI WAJIB bertanya eksplisit ke user di awal**: *"Apakah filter ini sebaiknya ditaruh di BE atau FE?"* agar tidak terjadi double filter lagi di kemudian hari.

6. **Self-Verification Checklist**:
   - [ ] Jika ada breaking change, apakah memang benar-benar diperlukan dan sudah diselaraskan di frontend & backend? Jika tidak perlu, apakah model/parsing sudah 100% backward compatible?
   - [ ] Apakah model parsing aman jika backend mengirim field null/empty atau tipe yang berbeda?
   - [ ] Apakah data di Dashboard, List, dan Detail selaras dan tidak ada status mismatch?
   - [ ] Apakah semua state UI (Loading, Empty Data, Error / Offline, Success) tertangani dengan rapi?
   - [ ] Apakah ada sisa mock/hardcode yang belum diganti data dinamis?
   - [ ] Apakah tidak ada redundansi/double filtering aturan bisnis di Frontend?

## Clean Code & Standar Flutter (WAJIB)

- Pertahankan struktur folder dan arsitektur yang sudah ada di Flutter (`lib/`).
- Hindari membuat widget monolithic / god widget dalam satu file jika sudah terlalu panjang (> 500 baris). Pisahkan sub-widget / helper component ke file terpisah.
- Ikuti linting standard (`flutter_lints`).

## Import UI: WAJIB `material_ui`, DILARANG `flutter/material` (ZERO TOLERANCE)

> **Alasan**: proyek ini memakai `material_ui` (lihat `pubspec.yaml`) dan membungkus seluruh app dengan `MaterialUiCompatibilityBridge` di `lib/app.dart`. Mencampur `package:flutter/material.dart` di sebagian file membuat widget berjalan di luar bridge tersebut. Akibatnya muncul **exception layout/render yang dilempar berulang setiap frame** — jejaknya berakhir di `BuildOwner.buildScope → WidgetsBinding.drawFrame`, layar terlihat "stuck"/beku, dan penyebabnya menyesatkan karena widget yang dilaporkan Flutter hanyalah korban, bukan sumbernya. **Terbukti di lapangan: error hilang begitu import-nya diganti ke `material_ui`.**

**WAJIB** untuk semua file `.dart` yang memakai widget/UI (Widget, Screen, Dialog, BottomSheet, Theme, Icons, Colors, TextStyle, `BuildContext`):

```dart
// ✅ BENAR
import 'package:material_ui/material_ui.dart';

// ❌ SALAH — DILARANG
import 'package:flutter/material.dart';
```

**TIDAK BOLEH BERALIBI DENGAN ALASAN APA PUN:**
- ❌ **DILARANG beralibi** "cuma butuh `Colors`/`Icons`/`TextStyle` saja"
- ❌ **DILARANG beralibi** "file lain di folder ini juga sudah pakai `flutter/material`"
- ❌ **DILARANG beralibi** "`flutter analyze` sudah lolos / tidak ada warning"
- ❌ **DILARANG beralibi** "widget-nya kecil / cuma helper / cuma service"
- ❌ **DILARANG beralibi** "sudah jalan normal di HP saya"

**Yang TETAP boleh di-import langsung dari `package:flutter/...`** (bukan layer Material UI, tidak lewat bridge):

|Import|Untuk|
|---|---|
|`package:flutter/foundation.dart`|`kDebugMode`, `debugPrint`, `ChangeNotifier`, `compute`|
|`package:flutter/services.dart`|`SystemChrome`, `SystemUiOverlayStyle`, `Clipboard`, `HapticFeedback`|
|`package:flutter/rendering.dart`|API render layer (`RenderBox`, dsb.)|
|`package:flutter_test/flutter_test.dart`|file test|

**Kewajiban AI:**
1. Saat **membuat file UI baru** → langsung tulis `import 'package:material_ui/material_ui.dart';`. Jangan pernah `flutter/material`.
2. Saat **menyentuh file lama** yang masih memakai `flutter/material` → **ganti import-nya ke `material_ui` di kesempatan itu juga** (bukan tugas terpisah, bukan "nanti").
3. Saat muncul error render/layout yang jejaknya berakhir di `BuildOwner.buildScope` / `drawFrame` → **CEK IMPORT DULU sebelum membongkar widget tree**. Jangan langsung menyalahkan `Row`/`Column`/`Expanded`/`IconButton`; verifikasi lebih dulu apakah file (dan file induknya) sudah memakai `material_ui`.

**Cara audit cepat (harus 0 hasil):**
```bash
grep -rl "^import 'package:flutter/material\.dart';" lib
```

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
