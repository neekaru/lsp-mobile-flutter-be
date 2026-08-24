# TODO

Daftar pekerjaan yang **belum** dilakukan setelah refactor file >1000 baris
(commit `5dd6019`, tag `v1.2.1-beta.68`).

## 🔧 Belum Selesai — Refactor

- [ ] **Pecah `lib/screens/pengajuan/pengajuan_sertifikat_data_logic.dart` (1109 baris)**
  - Masih satu-satunya file di atas 1000 baris.
  - Rencana: pecah menjadi 2 mixin — (1) fetch master data + profil + sesi asesi,
    (2) logika skema/unit/persyaratan (FR.APL.01 & FR.APL.02).
  - Verifikasi dengan `flutter analyze`.

## ⚠️ Kebersihan Repo

- [ ] **Normalisasi line ending LF untuk semua file Dart**
  - Git memperingatkan `LF will be replaced by CRLF` saat menyentuh file
    (`core.autocrlf=true`, index sudah LF).
  - Rencana: pastikan semua file di index konsisten LF agar tidak ada diff
    spurious di commit berikutnya.

## ✅ Belum Dilakukan — Verifikasi & Rilis

- [ ] **Verifikasi UI hasil refactor di emulator / perangkat**
  - Refactor hanya memindahkan kode, tapi belum ada smoke-test manual:
    - Halaman Jadwal (asesi, asesor, admin) — tab & kartu
    - Detail Jadwal & Detail Pelaporan
    - Bukti Portofolio (upload file & link)
    - Profil Asesor & Admin (foto, honor, menu, carousel)
    - Statistik Detail (semua menu)
  - Jalankan `flutter run` dan cek halaman-halaman tersebut.

- [ ] **Buat release notes `v1.2.1-beta.68` di GitHub**
  - Tag sudah dibuat & di-push. Release notes belum ditulis.
