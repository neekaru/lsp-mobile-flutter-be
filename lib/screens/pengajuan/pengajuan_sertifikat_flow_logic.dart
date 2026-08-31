// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart';

import '../../core/navigation/main_navigator.dart' show mainNavigatorKey, MainNavigatorState;
import '../../services/api_service.dart';
import '../auth/splash_screen.dart';
import 'bukti_portofolio_screen.dart';
import 'pengajuan_sertifikat_data_logic.dart';

// ============================================================================
// PengajuanSertifikatFlowLogic
//
// Navigasi antar step, submit pendaftaran, dan dialog untuk
// PengajuanSertifikatScreen. Bergantung pada PengajuanSertifikatDataLogic
// untuk field + data fetching.
// ============================================================================

mixin PengajuanSertifikatFlowLogic
    on PengajuanSertifikatDataLogic {
  Future<void> navigateToBuktiPortofolio() async {
    final ok = await ensurePersyaratanLengkap(
      contextLabel: 'ke Bukti Portofolio',
    );
    if (!ok) return;

    var documents = buildPortofolioDocuments();
    if (sertifikasiId != null) {
      try {
        final remote = await AsesiService.getPortofolioList(sertifikasiId!);
        if (remote.isNotEmpty) {
          // Merge remote status into local section map (keep a/b/c separation)
          final localByKey = {
            for (final d in documents) (d['key']?.toString() ?? ''): d,
          };
          final merged = <Map<String, dynamic>>[];
          final seen = <String>{};
          for (final d in remote) {
            final key = d['key']?.toString() ?? '';
            if (key.isEmpty) continue;
            seen.add(key);
            final local = localByKey[key];
            final section = (d['section']?.toString().isNotEmpty == true)
                ? d['section'].toString()
                : (local?['section']?.toString() ??
                    sectionFromJenisBukti(
                      d['jenis_bukti']?.toString() ??
                          local?['jenis_bukti']?.toString() ??
                          '',
                      key,
                      d['label']?.toString() ?? key,
                    ));
            merged.add({
              ...d,
              'section': section,
              'jenis_bukti': d['jenis_bukti'] ?? local?['jenis_bukti'] ?? '',
              'label': (d['label']?.toString().isNotEmpty == true)
                  ? d['label']
                  : (local?['label'] ?? key),
            });
            final fn = d['file_name']?.toString();
            final st = d['status']?.toString() ?? '';
            if (fn != null && fn.isNotEmpty) {
              uploadedFileNames[key] = fn;
              uploadedDocs[key] = st != 'Belum Diunggah';
            }
          }
          for (final d in documents) {
            final key = d['key']?.toString() ?? '';
            if (key.isEmpty || seen.contains(key)) continue;
            merged.add(d);
          }
          documents = merged;
        }
      } catch (e) {
        debugPrint('Error load portofolio list: $e');
      }
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuktiPortofolioScreen(
          selectedSkema: selectedSkema ?? '',
          uploadedDocs: uploadedDocs,
          uploadedFileNames: uploadedFileNames,
          uploadedFilePaths: uploadedFilePaths,
          documents: documents,
          onUploadChanged: (key, isUploaded, fileName, filePath) {
            setState(() {
              uploadedDocs[key] = isUploaded;
              uploadedFileNames[key] = fileName;
              if (filePath != null) {
                uploadedFilePaths[key] = filePath;
              }
            });
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  bool isAlreadyRegisteredError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('sudah terdaftar') ||
        msg.contains('sudah lulus') ||
        msg.contains('sertifikat masih berlaku') ||
        msg.contains('tidak bisa daftar ulang') ||
        msg.contains('pendaftaran ulang') ||
        msg.contains('conflict') ||
        msg.contains('409');
  }

  String cleanErrorMessage(Object e) {
    return e
        .toString()
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^DioException.*?:\s*'), '')
        .trim();
  }

  /// Missing mandatory uploads only (match web: admin default + mandatory DB).
  List<String> missingPersyaratanLabels() {
    final missing = <String>[];
    void check(List<Map<String, String>> items, {bool forceRequired = false}) {
      for (final p in items) {
        final key = p['key'] ?? '';
        if (key.isEmpty) continue;
        final mand = (p['mandatory'] ?? '').toLowerCase();
        final required = forceRequired ||
            mand == '1' ||
            mand == 'true' ||
            mand == 'yes';
        if (!required) continue;
        final ok = uploadedDocs[key] == true &&
            (uploadedFilePaths[key]?.isNotEmpty == true ||
                uploadedFileNames[key]?.isNotEmpty == true);
        if (!ok) missing.add(p['label'] ?? key);
      }
    }

    // Administratif default (Pasfoto + KTP) always mandatory — same as web
    check(persyaratanAdministratif, forceRequired: true);
    // Dasar: only when mandatory=1 from DB
    check(persyaratanDasar);
    return missing;
  }

  Future<bool> ensurePersyaratanLengkap({String contextLabel = 'persyaratan'}) async {
    final missing = missingPersyaratanLabels();
    if (missing.isEmpty) return true;
    if (!mounted) return false;
    final list = missing.take(6).map((e) => '• $e').join('\n');
    final more = missing.length > 6 ? '\n…dan ${missing.length - 6} lainnya' : '';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B),
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Persyaratan Belum Lengkap',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi dulu Persyaratan Dasar & Administratif sebelum melanjutkan $contextLabel.\n\nBelum diunggah:\n$list$more',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mengerti',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return false;
  }

  /// Warning saat user coba maju ke Dokumen Portofolio / Asesmen Mandiri
  /// padahal skema belum dipilih. Setelah ditutup, balik ke Data Pengajuan.
  Future<void> showPilihSkemaDuluWarning() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.assignment_late_rounded,
                      color: Color(0xFF378CE7),
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Skema Dulu',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Anda belum memilih skema sertifikasi. Unit, Elemen, dan KUK '
                  'baru bisa dimuat setelah skema dipilih. Kembali ke langkah '
                  'Data Pengajuan lalu pilih skema.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Data Pengajuan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    // Arahkan balik ke step Data Pengajuan (step 0).
    if (mounted) {
      setState(() {
        currentStep = 0;
      });
    }
  }

  Future<void> nextStep() async {
    if (currentStep < 5) {
      if (currentStep == 0) {
        final skemaId = selectedSkemaId;
        final jadwalId = selectedJadwalId;
        if (skemaId == null || skemaId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pilih skema sertifikasi terlebih dahulu.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (jadwalId == null || jadwalId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pilih jadwal uji kompetensi terlebih dahulu.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final already = await isAlreadyRegisteredOnSkema(skemaId);
        if (already) {
          await showAlreadyRegisteredWarning();
          return;
        }
      }
      // Step 1 = Profil Peserta (NIK 16 digit & Nama Lengkap wajib)
      if (currentStep == 1) {
        final nik = nikController.text.trim();
        if (nik.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NIK wajib diisi.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (nik.length != 16 || !RegExp(r'^[0-9]{16}$').hasMatch(nik)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NIK harus terdiri dari 16 digit angka.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final nama = namaLengkapController.text.trim();
        if (nama.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nama lengkap wajib diisi.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
      // Step 3 = Dokumen Persyaratan (Dasar + Administratif) harus lengkap
      if (currentStep == 3) {
        final ok = await ensurePersyaratanLengkap(
          contextLabel: 'ke Dokumen Portofolio',
        );
        if (!ok) return;
      }
      final next = currentStep + 1;
      // Step 4/5 (Dokumen Portofolio & Asesmen Mandiri) butuh skema valid.
      // Tanpa guard ini, user bisa maju dengan skema kosong → tampil 0 unit.
      if ((next == 4 || next == 5) &&
          (selectedSkemaId == null || selectedSkemaId! <= 0)) {
        await showPilihSkemaDuluWarning();
        return;
      }
      setState(() {
        currentStep = next;
      });
      // Ensure unit/elemen/KUK loaded when entering Dokumen Portofolio / Asesmen
      if (next == 4 || next == 5) {
        await ensureKompetensiLoaded();
      }
    } else {
      setState(() {
        isSubmitting = true;
      });

      try {
        // Guard: persyaratan Dasar + Administratif harus lengkap sebelum submit
        final reqOk = await ensurePersyaratanLengkap(
          contextLabel: 'submit pendaftaran',
        );
        if (!reqOk) {
          if (mounted) setState(() => isSubmitting = false);
          return;
        }

        final skemaId = selectedSkemaId;
        final jadwalId = selectedJadwalId;
        if (skemaId == null || skemaId <= 0) {
          throw Exception('Pilih skema sertifikasi terlebih dahulu.');
        }
        if (jadwalId == null || jadwalId <= 0) {
          throw Exception('Pilih jadwal asesmen terlebih dahulu.');
        }
        final dataPribadi = buildDataPribadiPayload();

        // 0. Publik: ensure-asesi → token. Sudah login asesi: skip.
        final fromPublicLogin = await ensureAsesiSession(dataPribadi);

        // 0b. FE pre-check status (setelah punya JWT) — dialog warning, jangan hanya andalkan BE 409
        final already = await isAlreadyRegisteredOnSkema(skemaId);
        if (already) {
          if (mounted) {
            setState(() => isSubmitting = false);
          }
          await showAlreadyRegisteredWarning();
          return;
        }

        // 1. Daftar (auth) — BE tolak jika sudah lulus / sudah terdaftar skema sama
        final regRes = await AsesiService.daftarSertifikasi(
          skemaId: skemaId,
          jadwalId: jadwalId,
          dataPribadi: dataPribadi,
        );

        if (regRes == null) {
          throw Exception('Gagal melakukan pendaftaran sertifikasi.');
        }

        final sertifikasiIdRaw = regRes['sertifikasi_id'] ?? regRes['id'];
        if (sertifikasiIdRaw == null) {
          throw Exception('ID Sertifikasi tidak valid.');
        }
        final sertId = sertifikasiIdRaw is int
            ? sertifikasiIdRaw
            : int.parse(sertifikasiIdRaw.toString());
        sertifikasiId = sertId;

        // 2. Upload persyaratan (key = slug from API, path = local file)
        for (final entry in uploadedFilePaths.entries) {
          final docKey = entry.key;
          final filePath = entry.value;
          if (filePath != null &&
              filePath.isNotEmpty &&
              !filePath.startsWith('http')) {
            final up = await AsesiService.uploadPortofolio(
              sertId,
              docKey,
              filePath,
            );
            if (up == null) {
              throw Exception(
                'Gagal unggah dokumen "$docKey". Periksa file lalu coba lagi.',
              );
            }
          }
        }

        // 3. Submit Pra-Asesmen (key: k:{id_kuk} | e:{id_elemen})
        await ensureKompetensiLoaded();
        final List<Map<String, dynamic>> evaluasi = [];
        kukAssessments.forEach((key, isKompeten) {
          if (isKompeten == null) return;
          int idElemen = 0;
          int idKuk = 0;
          if (key.startsWith('k:')) {
            idKuk = int.tryParse(key.substring(2)) ?? 0;
          } else if (key.startsWith('e:')) {
            idElemen = int.tryParse(key.substring(2)) ?? 0;
          } else {
            idElemen = int.tryParse(key) ?? 0;
          }
          if (idElemen <= 0 && idKuk <= 0) return;
          // resolve id_elemen from nested units if only id_kuk
          if (idElemen <= 0 && idKuk > 0) {
            for (final u in asesmenUnits) {
              final groups = u['elemen'];
              if (groups is! List) continue;
              for (final g in groups) {
                final items = g is Map ? g['items'] : null;
                if (items is! List) continue;
                for (final it in items) {
                  if (it is Map && it['id_kuk'] == idKuk) {
                    idElemen = it['id_elemen'] as int? ?? 0;
                  }
                }
              }
            }
          }
          final item = <String, dynamic>{
            'id_elemen': idElemen,
            'nilai': isKompeten == true ? 'K' : 'KB',
          };
          if (idKuk > 0) item['id_kuk'] = idKuk;
          final bukti = kukEvidence[key];
          if (bukti != null && bukti.isNotEmpty) item['bukti'] = bukti;
          evaluasi.add(item);
        });

        if (kompetensiHasDetail && evaluasi.isEmpty) {
          throw Exception(
            'Lengkapi asesmen mandiri (evaluasi kompetensi) sebelum mengirim.',
          );
        }
        if (evaluasi.isNotEmpty) {
          final submitRes =
              await AsesiService.submitPraAsesmen(skemaId, evaluasi);
          if (!submitRes) {
            throw Exception('Gagal submit evaluasi pra-asesmen.');
          }
        }

        if (!mounted) return;

        // Publik → asesi: freeze + restart Splash (clean shell, no weird guest UI)
        if (fromPublicLogin) {
          await freezeAndRestartSplash(
            message: 'Pendaftaran berhasil.\nMenyiapkan aplikasi sebagai Asesi…',
          );
          return;
        }

        showSuccessDialog();
      } catch (e) {
        debugPrint('Error during submission flow: $e');
        if (!mounted) return;
        final clean = cleanErrorMessage(e);
        if (isAlreadyRegisteredError(e)) {
          setState(() => isSubmitting = false);
          await showAlreadyRegisteredWarning(beMessage: clean);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(clean.isEmpty ? 'Terjadi kesalahan.' : clean),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }

  void previousStep() {
    if (currentStep == 5 && activeUnitDetailIndex != null) {
      setState(() {
        activeUnitDetailIndex = null;
      });
      return;
    }
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  // ignore: unused_element
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF5350),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pengajuan Berhasil',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pengajuan sertifikasi Anda telah berhasil dikirimkan ke pihak LSP untuk diverifikasi.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dismiss Dialog
                      // Rebuild shell as current role (asesi) — avoids stale guest tabs
                      mainNavigatorKey = GlobalKey<MainNavigatorState>();
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const SplashScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 450),
                        ),
                        (_) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Menu Utama',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
