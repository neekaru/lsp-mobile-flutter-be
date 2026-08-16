// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../core/navigation/main_navigator.dart' show mainNavigatorKey, MainNavigatorState;
import '../../services/api_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/common/notification_service.dart';
import '../../services/auth/token_storage.dart';
import '../../models/master_models.dart';
import '../auth/splash_screen.dart';
import 'pengajuan_sertifikat_skema_logic.dart';

// ============================================================================
// PengajuanSertifikatDataLogic
//
// State fields + data fetching (master data, profil asesi, sesi) untuk
// PengajuanSertifikatScreen. Bergantung pada PengajuanSertifikatSkemaLogic
// untuk state + logika skema/unit/persyaratan (FR.APL.01 & FR.APL.02).
// Dipisah dari screen agar file screen tetap ringkas.
// ============================================================================

mixin PengajuanSertifikatDataLogic on PengajuanSertifikatSkemaLogic {
  Future<void> loadInitialData() async {
    // Wait for route transition animation to finish before making network calls
    await Future.delayed(const Duration(milliseconds: 375));
    if (!mounted) return;

    // Master data only (dropdowns bind to master* lists from API)
    fetchProvinsi();
    fetchMasterSkema();
    fetchMasterSumberAnggaran();
    fetchMasterPendidikan();
    fetchMasterPekerjaan();
    loadAsesiProfile();
  }

  Future<void> fetchMasterPekerjaan() async {
    setState(() => isLoadingPekerjaan = true);
    try {
      final list = await ApiService.getMasterPekerjaanList();
      if (mounted) {
        setState(() {
          listPekerjaan = list;
          isLoadingPekerjaan = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master pekerjaan: $e');
      if (mounted) setState(() => isLoadingPekerjaan = false);
    }
  }

  Future<void> fetchMasterPendidikan() async {
    setState(() => isLoadingPendidikan = true);
    try {
      final list = await ApiService.getMasterPendidikanList();
      if (mounted) {
        setState(() {
          listPendidikan = list;
          isLoadingPendidikan = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master pendidikan: $e');
      if (mounted) setState(() => isLoadingPendidikan = false);
    }
  }

  Future<void> loadAsesiProfile() async {
    try {
      final profile = await AsesiService.getProfile();
      if (profile == null || !mounted) return;
      setState(() {
        if ((profile['nik']?.toString() ?? '').isNotEmpty) {
          nikController.text = profile['nik'].toString();
        }
        if ((profile['nama_lengkap']?.toString() ?? '').isNotEmpty) {
          namaLengkapController.text = profile['nama_lengkap'].toString();
        }
        final jk = profile['jenis_kelamin']?.toString() ?? '';
        if (jk == '1' || jk.toLowerCase().contains('laki')) {
          jenisKelamin = 'Laki-Laki';
        } else if (jk == '2' || jk.toLowerCase().contains('perempuan')) {
          jenisKelamin = 'Perempuan';
        }
        if ((profile['tempat_lahir']?.toString() ?? '').isNotEmpty) {
          tempatLahirController.text = profile['tempat_lahir'].toString();
        }
        if ((profile['tgl_lahir']?.toString() ?? '').isNotEmpty) {
          tanggalLahirController.text =
              AsesiService.normalizeTglLahir(profile['tgl_lahir'].toString());
        }
        if ((profile['alamat']?.toString() ?? '').isNotEmpty) {
          alamatDomisiliController.text = profile['alamat'].toString();
        }
        if (profile['id_provinsi'] != null) {
          selectedProvinsi = profile['id_provinsi'].toString();
        }
        if (profile['id_kabupaten'] != null) {
          selectedKota = profile['id_kabupaten'].toString();
        }
        if ((profile['id_kecamatan']?.toString() ?? '').isNotEmpty) {
          selectedKecamatan = profile['id_kecamatan'].toString();
        }
        if ((profile['telp']?.toString() ?? '').isNotEmpty) {
          noTelpController.text = profile['telp'].toString();
        }
        if ((profile['email']?.toString() ?? '').isNotEmpty) {
          emailController.text = profile['email'].toString();
        }
        if (profile['id_pendidikan'] != null) {
          selectedPendidikanId =
              int.tryParse(profile['id_pendidikan'].toString());
        }
        if ((profile['nama_sekolah']?.toString() ?? '').isNotEmpty) {
          namaSekolahController.text = profile['nama_sekolah'].toString();
        }
        if ((profile['jurusan']?.toString() ?? '').isNotEmpty) {
          jurusanController.text = profile['jurusan'].toString();
        }
        if (profile['id_pekerjaan'] != null) {
          selectedPekerjaanId =
              int.tryParse(profile['id_pekerjaan'].toString());
        }
        if ((profile['organisasi']?.toString() ?? '').isNotEmpty) {
          namaPerusahaanController.text = profile['organisasi'].toString();
        }
        if ((profile['jabatan']?.toString() ?? '').isNotEmpty) {
          jabatanController.text = profile['jabatan'].toString();
        }
        if ((profile['alamat_company']?.toString() ?? '').isNotEmpty) {
          alamatPerusahaanController.text =
              profile['alamat_company'].toString();
        }
        if ((profile['kode_pos_company']?.toString() ?? '').isNotEmpty) {
          kodeposPerusahaanController.text =
              profile['kode_pos_company'].toString();
        }
        if ((profile['telp_company']?.toString() ?? '').isNotEmpty) {
          telpPerusahaanController.text = profile['telp_company'].toString();
        }
        if ((profile['email_company']?.toString() ?? '').isNotEmpty) {
          emailPerusahaanController.text =
              profile['email_company'].toString();
        }
      });
      if (selectedProvinsi != null) {
        await fetchKabupaten(selectedProvinsi!);
        if (selectedKota != null) {
          await fetchKecamatan(selectedKota!);
        }
      }
    } catch (e) {
      debugPrint('Error loading asesi profile: $e');
    }
  }

  Map<String, dynamic> buildDataPribadiPayload() {
    final payload = <String, dynamic>{
      'nik': nikController.text.trim(),
      'nama_lengkap': namaLengkapController.text.trim(),
      'jenis_kelamin': AsesiService.mapJenisKelamin(jenisKelamin),
      'tempat_lahir': tempatLahirController.text.trim(),
      'tgl_lahir': AsesiService.normalizeTglLahir(tanggalLahirController.text),
      'alamat': alamatDomisiliController.text.trim(),
      'telp': noTelpController.text.trim(),
      'email': emailController.text.trim(),
      'nama_sekolah': namaSekolahController.text.trim(),
      'jurusan': jurusanController.text.trim(),
    };
    final idProv = int.tryParse(selectedProvinsi ?? '');
    if (idProv != null) payload['id_provinsi'] = idProv;
    final idKab = int.tryParse(selectedKota ?? '');
    if (idKab != null) payload['id_kabupaten'] = idKab;
    if ((selectedKecamatan ?? '').isNotEmpty) {
      payload['id_kecamatan'] = selectedKecamatan;
    }
    if (selectedPendidikanId != null) {
      payload['id_pendidikan'] = selectedPendidikanId;
    }
    if (selectedSumberAnggaranId != null) {
      payload['id_sumber_anggaran'] = selectedSumberAnggaranId;
    }
    if (selectedPemberiAnggaranId != null) {
      payload['id_instansi_anggaran'] = selectedPemberiAnggaranId;
    }
    if (selectedPekerjaanId != null) {
      payload['id_pekerjaan'] = selectedPekerjaanId;
    }
    final organisasi = namaPerusahaanController.text.trim();
    if (organisasi.isNotEmpty) payload['organisasi'] = organisasi;
    final jabatan = jabatanController.text.trim();
    if (jabatan.isNotEmpty) payload['jabatan'] = jabatan;
    final alamatCompany = alamatPerusahaanController.text.trim();
    if (alamatCompany.isNotEmpty) payload['alamat_company'] = alamatCompany;
    final kodePos = kodeposPerusahaanController.text.trim();
    if (kodePos.isNotEmpty) payload['kode_pos_company'] = kodePos;
    final telpCompany = telpPerusahaanController.text.trim();
    if (telpCompany.isNotEmpty) payload['telp_company'] = telpCompany;
    final emailCompany = emailPerusahaanController.text.trim();
    if (emailCompany.isNotEmpty) payload['email_company'] = emailCompany;
    return payload;
  }

  /// Publik (belum login): POST ensure-asesi → JWT.
  /// Returns true if session was just created/logged-in from public (need splash restart).
  Future<bool> ensureAsesiSession(Map<String, dynamic> dataPribadi) async {
    final token = await TokenStorage.instance.getAccessToken();
    final role = AuthRepository.currentUserInstance?.role;
    final hasRealJwt = token != null &&
        token.isNotEmpty &&
        !token.startsWith('fake-');

    // Sudah login asesi → langsung daftar
    if (hasRealJwt && (role == null || role == 'asesi')) {
      return false;
    }

    final nik = (dataPribadi['nik']?.toString() ?? '').trim();
    final email = (dataPribadi['email']?.toString() ?? '').trim();
    final nama = (dataPribadi['nama_lengkap']?.toString() ?? '').trim();
    final telp = (dataPribadi['telp']?.toString() ?? '').trim();

    var account = nik;
    if (account.isEmpty && email.contains('@')) {
      account = email.split('@').first;
    }
    if (account.isEmpty) {
      throw Exception(
        'NIK wajib diisi untuk membuat akun login (password default 123456).',
      );
    }
    if (account.length > 18) account = account.substring(0, 18);

    final auth = AuthRepository(
      dio: ApiClient.dio,
      tokenStorage: TokenStorage.instance,
    );
    await auth.ensureAsesi(
      account: account,
      password: '123456',
      namaLengkap: nama,
      email: email.isNotEmpty ? email : null,
      hp: telp.isNotEmpty ? telp : null,
      platform: 'mobile',
    );
    // Register FCM under new asesi session
    try {
      NotificationService.instance.registerCurrentToken();
    } catch (_) {}
    return true;
  }

  /// Freeze UI then hard-restart via Splash so MainNavigator rebuilds as asesi.
  Future<void> freezeAndRestartSplash({String message = 'Menyiapkan sesi Asesi...'}) async {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white,
      useRootNavigator: true,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: Material(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mohon tunggu sebentar…',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Brief freeze so user sees clean transition (avoids weird mixed guest/asesi UI)
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    mainNavigatorKey = GlobalKey<MainNavigatorState>();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
      (_) => false,
    );
  }

  Future<void> fetchProvinsi() async {
    setState(() {
      isLoadingProvinsi = true;
    });
    try {
      final list = await ApiService.getProvinsiList();
      if (mounted) {
        setState(() {
          listProvinsi = list;
        });
      }
    } catch (e) {
      debugPrint('Error fetching provinsi: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingProvinsi = false;
        });
      }
    }
  }

  Future<void> fetchKabupaten(String provinceId) async {
    setState(() {
      isLoadingKabupaten = true;
      listKabupaten = [];
      listKecamatan = [];
    });
    try {
      final list = await ApiService.getKabupatenList(provinceId);
      if (mounted) {
        setState(() {
          listKabupaten = list;
        });
      }
    } catch (e) {
      debugPrint('Error fetching kabupaten: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingKabupaten = false;
        });
      }
    }
  }

  Future<void> fetchKecamatan(String kabupatenId) async {
    setState(() {
      isLoadingKecamatan = true;
      listKecamatan = [];
    });
    try {
      final list = await ApiService.getKecamatanList(kabupatenId);
      if (mounted) {
        setState(() {
          listKecamatan = list;
        });
      }
    } catch (e) {
      debugPrint('Error fetching kecamatan: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingKecamatan = false;
        });
      }
    }
  }

  Future<void> fetchMasterSumberAnggaran() async {
    setState(() {
      isLoadingSumberAnggaran = true;
    });
    try {
      final list = await ApiService.getMasterSumberAnggaranList();
      if (mounted) {
        setState(() {
          masterSumberAnggaranList = list;
          isLoadingSumberAnggaran = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master sumber anggaran: $e');
      if (mounted) {
        setState(() {
          isLoadingSumberAnggaran = false;
        });
      }
    }
  }

  Future<void> fetchMasterPemberiAnggaran(int idSumberAnggaran) async {
    setState(() {
      isLoadingPemberiAnggaran = true;
      masterPemberiAnggaranList = [];
    });
    try {
      final list = await ApiService.getMasterPemberiAnggaranList(
        idSumberAnggaran: idSumberAnggaran,
      );
      if (mounted) {
        setState(() {
          masterPemberiAnggaranList = list;
          isLoadingPemberiAnggaran = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master pemberi anggaran: $e');
      if (mounted) {
        setState(() {
          isLoadingPemberiAnggaran = false;
        });
      }
    }
  }

  // Current active step
  int currentStep = 0;
  bool isSubmitting = false;

  // Step 2: Profil Peserta - Data Pribadi State
  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaLengkapController = TextEditingController();
  String jenisKelamin = 'Laki-Laki';
  final TextEditingController tempatLahirController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController alamatDomisiliController = TextEditingController();
  String? selectedProvinsi;
  String? selectedKota;
  String? selectedKecamatan;

  // Master lists and loading indicators for Profil Peserta dynamic dropdowns
  List<MasterItem> listProvinsi = [];
  List<MasterItem> listKabupaten = [];
  List<MasterItem> listKecamatan = [];
  bool isLoadingProvinsi = false;
  bool isLoadingKabupaten = false;
  bool isLoadingKecamatan = false;
  final TextEditingController noTelpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  int? selectedPendidikanId;
  List<MasterPendidikan> listPendidikan = [];
  bool isLoadingPendidikan = false;
  final TextEditingController namaSekolahController = TextEditingController();
  final TextEditingController jurusanController = TextEditingController();

  // Step 3: Profil Peserta - Data Pekerjaan State
  int? selectedPekerjaanId;
  List<MasterPekerjaan> listPekerjaan = [];
  bool isLoadingPekerjaan = false;
  final TextEditingController namaPerusahaanController = TextEditingController();
  final TextEditingController jabatanController = TextEditingController();
  final TextEditingController alamatPerusahaanController = TextEditingController();
  final TextEditingController kodeposPerusahaanController = TextEditingController();
  final TextEditingController telpPerusahaanController = TextEditingController();
  final TextEditingController emailPerusahaanController = TextEditingController();
}
