# Agent Instructions — LSP Mobile Frontend (Flutter)

## Prinsip kerja (WAJIB)

- **STOP OVERTHINKING.** User mau hasil cepat. Jangan bertele-tele, jangan analisis berlebihan, jangan ragu-ragu.
- Langsung eksekusi setelah memahami permintaan. Kalau ambigu, ambil interpretasi paling masuk akal dari kode yang ada.
- Jangan menambah fitur/helper/komentar yang tidak diminta.

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
