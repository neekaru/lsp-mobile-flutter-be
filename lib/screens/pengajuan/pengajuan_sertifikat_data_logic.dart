// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../core/navigation/main_navigator.dart' show mainNavigatorKey, MainNavigatorState;
import '../../services/api_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/common/notification_service.dart';
import '../../services/auth/token_storage.dart';
import '../../models/master_models.dart';
import '../auth/splash_screen.dart';
import 'pengajuan_sertifikat_screen.dart';

// ============================================================================
// PengajuanSertifikatDataLogic
//
// State fields + data fetching untuk PengajuanSertifikatScreen.
// Dipisah dari screen agar file screen tetap ringkas.
// ============================================================================

mixin PengajuanSertifikatDataLogic on State<PengajuanSertifikatScreen> {
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

  Future<void> fetchMasterSkema() async {
    setState(() {
      isLoadingSkema = true;
    });
    try {
      final list = await ApiService.getMasterSkemaList();
      if (mounted) {
        setState(() {
          masterSkemaList = list;
          isLoadingSkema = false;
        });
        await applyInitialSkema();
      }
    } catch (e) {
      debugPrint('Error fetching master skema: $e');
      if (mounted) {
        setState(() {
          isLoadingSkema = false;
        });
      }
    }
  }

  /// Auto-select skema from Detail Skema so user tidak perlu cari manual.
  Future<void> applyInitialSkema() async {
    final id = widget.initialSkemaId;
    if (id == null || id <= 0) return;
    if (selectedSkemaId != null) return;

    MasterSkema? match;
    try {
      match = masterSkemaList.firstWhere((s) => s.id == id);
    } catch (_) {
      match = null;
    }

    final name = match?.namaSkema ??
        (widget.initialSkemaName?.trim().isNotEmpty == true
            ? widget.initialSkemaName!.trim()
            : null);

    if (match == null && name != null) {
      // Pastikan muncul di dropdown walau belum ada di master list
      masterSkemaList = [
        ...masterSkemaList,
        MasterSkema(
          id: id,
          kodeSkema: '',
          namaSkema: name,
        ),
      ];
    } else if (match == null) {
      return;
    }

    setState(() {
      selectedSkemaId = id;
      selectedSkema = name ?? match?.namaSkema;
      selectedJadwalId = null;
      masterJadwalList = [];
      clearUnitPersyaratan();
    });

    // Cek duplicate di FE (sama seperti onSkemaChanged)
    final already = await isAlreadyRegisteredOnSkema(id);
    if (already && mounted) {
      await showAlreadyRegisteredWarning(skemaName: selectedSkema);
      return;
    }

    if (mounted && selectedSkemaId == id) {
      fetchMasterJadwal(id);
      fetchSkemaUnitPersyaratan(id);
    }
  }

  Future<void> fetchMasterJadwal(int idSkema) async {
    setState(() {
      isLoadingJadwal = true;
      masterJadwalList = [];
    });
    try {
      final list = await ApiService.getMasterJadwalList(idSkema);
      if (mounted) {
        setState(() {
          masterJadwalList = list;
          isLoadingJadwal = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master jadwal: $e');
      if (mounted) {
        setState(() {
          isLoadingJadwal = false;
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

  // Step 1: Data Pengajuan State
  int? selectedSkemaId;
  int? selectedJadwalId;
  int? selectedSumberAnggaranId;
  int? selectedPemberiAnggaranId;
  String? selectedSkema;

  List<MasterSkema> masterSkemaList = [];
  List<MasterJadwal> masterJadwalList = [];
  List<MasterSumberAnggaran> masterSumberAnggaranList = [];
  List<MasterPemberiAnggaran> masterPemberiAnggaranList = [];
  bool isLoadingSkema = false;
  bool isLoadingJadwal = false;
  bool isLoadingSumberAnggaran = false;
  bool isLoadingPemberiAnggaran = false;

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

  // FR.APL.01 persyaratan upload — keyed by portofolio `key` (slug)
  final Map<String, bool> uploadedDocs = {};
  final Map<String, String?> uploadedFileNames = {};
  final Map<String, String?> uploadedFilePaths = {};

  int? activeUnitDetailIndex;
  /// key = id_elemen as String → K/KB
  final Map<String, bool?> kukAssessments = {};
  final Map<String, String?> kukEvidence = {};

  // Unit list for dokumen persyaratan (FR.APL.01) — no elemen/KUK
  List<Map<String, dynamic>> cachedUnitKompetensi = [];
  // FR.APL.02 — unit + elemen/KUK from GET /api/pra-asesmen/skema/:id/kompetensi
  List<Map<String, dynamic>> asesmenUnits = [];
  bool isLoadingKompetensi = false;

  // FR.APL.01 bagian 2 — unit + persyaratan from API (by id_skema)
  List<Map<String, String>> persyaratanDasar = [];
  // Default admin keys always present for upload; API can replace/extend.
  List<Map<String, String>> persyaratanAdministratif = const [
    {
      'key': 'pasfoto',
      'label': 'Pasfoto*',
      'section': 'a',
      'mandatory': '1',
    },
    {
      'key': 'identitas-pribadi-ktp-kartu-pelajar',
      'label': 'Identitas pribadi (KTP/Kartu Pelajar)*',
      'section': 'a',
      'mandatory': '1',
    },
  ];
  bool isLoadingUnitPersyaratan = false;
  int? sertifikasiId;
  int? kompetensiSkemaId;
  /// true only when pra-asesmen kompetensi API returned nested elemen/KUK
  bool kompetensiHasDetail = false;

  String sectionFromJenisBukti(String jenis, String key, String label) {
    final j = jenis.toLowerCase().trim();
    if (j == 'a' ||
        j == 'admin' ||
        j == 'administratif' ||
        j == 'identitas') {
      return 'a';
    }
    if (j == 'c' ||
        j == 'bukti_pelatihan' ||
        j == 'pelatihan' ||
        j == 'karya' ||
        j == 'kompetensi' ||
        j == 'portofolio') {
      return 'c';
    }
    if (j == 'b' ||
        j == 'pendidikan' ||
        j == 'bukti_bekerja' ||
        j == 'bukti_pekerja' ||
        j == 'pekerjaan' ||
        j == 'kerja') {
      return 'b';
    }
    final t = '${key.toLowerCase()} ${label.toLowerCase()}';
    bool has(List<String> xs) => xs.any(t.contains);
    if (has([
      'ktp',
      'identitas',
      'pasfoto',
      'pas-foto',
      'pas foto',
      'kartu pelajar',
      'foto 4x6',
      '4x6',
    ])) {
      return 'a';
    }
    if (has([
      'github',
      'portofolio',
      'karya',
      'sertifikat',
      'pelatihan',
      'kompetensi teknis',
      'tautan',
      'url',
    ])) {
      return 'c';
    }
    return 'b';
  }

  Future<void> fetchSkemaUnitPersyaratan(int idSkema) async {
    setState(() {
      isLoadingUnitPersyaratan = true;
      cachedUnitKompetensi = [];
      persyaratanDasar = [];
      uploadedDocs.clear();
      uploadedFileNames.clear();
      uploadedFilePaths.clear();
    });
    try {
      final data = await ApiService.getSkemaUnitPersyaratan(idSkema);
      if (!mounted) return;
      if (data != null) {
        setState(() {
          cachedUnitKompetensi =
              data.unitKompetensi.map((u) => u.toUnitMap()).toList();
          persyaratanDasar = data.persyaratanDasar
              .map((p) => {
                    'key': p.key,
                    'label': p.label,
                    'jenis_bukti': p.jenisBukti,
                    'mandatory': p.mandatory ? '1' : '0',
                    'section': sectionFromJenisBukti(
                      p.jenisBukti,
                      p.key,
                      p.label,
                    ),
                  })
              .toList();
          // Merge API admin list with defaults — never drop pasfoto/KTP keys.
          const defaults = [
            {
              'key': 'pasfoto',
              'label': 'Pasfoto*',
              'section': 'a',
              'mandatory': '1',
            },
            {
              'key': 'identitas-pribadi-ktp-kartu-pelajar',
              'label': 'Identitas pribadi (KTP/Kartu Pelajar)*',
              'section': 'a',
              'mandatory': '1',
            },
          ];
          final fromApi = data.persyaratanAdministratif
              .map((p) => {
                    'key': p.key,
                    'label': p.label,
                    'section': 'a',
                    'mandatory': '1',
                  })
              .toList();
          final byKey = <String, Map<String, String>>{};
          for (final d in defaults) {
            byKey[d['key']!] = Map<String, String>.from(d);
          }
          for (final p in fromApi) {
            final k = p['key'] ?? '';
            if (k.isEmpty) continue;
            byKey[k] = p;
          }
          persyaratanAdministratif = byKey.values.toList();
          if (selectedSkema == null || selectedSkema!.isEmpty) {
            selectedSkema = data.namaSkema;
          }
          isLoadingUnitPersyaratan = false;
        });
      } else {
        setState(() {
          isLoadingUnitPersyaratan = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching skema unit-persyaratan: $e');
      if (mounted) {
        setState(() {
          isLoadingUnitPersyaratan = false;
        });
      }
    }
    // FR.APL.02 kompetensi (unit → elemen/KUK)
    await fetchPraAsesmenKompetensi(idSkema);
  }

  int countElemen(List<Map<String, dynamic>> units) {
    var n = 0;
    for (final u in units) {
      final el = u['elemen'];
      if (el is List) n += el.length;
    }
    return n;
  }

  List<Map<String, dynamic>> unitsFromCacheOnly() {
    return cachedUnitKompetensi
        .map((u) => {
              'kode': u['kode']?.toString() ?? '',
              'judul': u['judul']?.toString() ?? '',
              'kuk_count': '0 item',
              'elemen': <Map<String, dynamic>>[],
            })
        .toList();
  }

  Future<void> fetchPraAsesmenKompetensi(int idSkema) async {
    setState(() {
      isLoadingKompetensi = true;
      asesmenUnits = [];
      kompetensiHasDetail = false;
      kukAssessments.clear();
      kukEvidence.clear();
      kompetensiSkemaId = idSkema;
    });
    try {
      final komp = await SertifikatService.getPraAsesmenKompetensi(
        idSkema,
        selectedSkema ?? '',
      );
      if (!mounted) return;
      // Ignore stale response if user switched skema mid-flight
      if (kompetensiSkemaId != idSkema) return;

      if (komp == null) {
        // Temporary shell only — kompetensiHasDetail stays false so we retry
        setState(() {
          asesmenUnits = unitsFromCacheOnly();
          kompetensiHasDetail = false;
          isLoadingKompetensi = false;
        });
        return;
      }

      if (komp.namaSkema.isNotEmpty &&
          (selectedSkema == null || selectedSkema!.isEmpty)) {
        selectedSkema = komp.namaSkema;
      }

      final units = komp.unitKompetensi.map((u) {
        final elemenGroups = u.elemen.map((e) {
          final items = e.assessableItems;
          return {
            'id_elemen': e.idElemen,
            'title': e.elemenKompetensi.isNotEmpty
                ? e.elemenKompetensi
                : e.pertanyaanKuk,
            'kuk_count': '${items.length} item',
            'items': items,
          };
        }).toList();
        var total = 0;
        for (final g in elemenGroups) {
          final items = g['items'];
          if (items is List) total += items.length;
        }
        return {
          'kode': u.kodeUnit,
          'judul': u.judulUnit,
          'kuk_count': '$total item',
          'elemen': elemenGroups,
        };
      }).toList();

      final hasDetail = units.isNotEmpty && countElemen(units) > 0;
      final resolved = units.isNotEmpty ? units : unitsFromCacheOnly();

      setState(() {
        asesmenUnits = resolved;
        // Only mark complete when API nested elemen/KUK present
        kompetensiHasDetail = hasDetail;
        isLoadingKompetensi = false;
      });

      debugPrint(
        'pra-asesmen kompetensi skema=$idSkema units=${resolved.length} '
        'elemen=${countElemen(resolved)} hasDetail=$hasDetail',
      );
    } catch (e) {
      debugPrint('Error fetching pra-asesmen kompetensi: $e');
      if (mounted && kompetensiSkemaId == idSkema) {
        setState(() {
          if (asesmenUnits.isEmpty) {
            asesmenUnits = unitsFromCacheOnly();
          }
          kompetensiHasDetail = false;
          isLoadingKompetensi = false;
        });
      }
    }
  }

  Future<void> ensureKompetensiLoaded() async {
    final id = selectedSkemaId;
    if (id == null) return;
    if (isLoadingKompetensi) return;
    // Retry when only unit shell loaded (elemen/KUK still 0) — e.g. Desainer Grafis Muda
    if (kompetensiSkemaId == id &&
        kompetensiHasDetail &&
        asesmenUnits.isNotEmpty) {
      return;
    }
    await fetchPraAsesmenKompetensi(id);
  }

  void clearUnitPersyaratan() {
    cachedUnitKompetensi = [];
    asesmenUnits = [];
    kompetensiSkemaId = null;
    kompetensiHasDetail = false;
    persyaratanDasar = [];
    persyaratanAdministratif = const [
      {
        'key': 'pasfoto',
        'label': 'Pasfoto*',
        'section': 'a',
        'mandatory': '1',
      },
      {
        'key': 'identitas-pribadi-ktp-kartu-pelajar',
        'label': 'Identitas pribadi (KTP/Kartu Pelajar)*',
        'section': 'a',
        'mandatory': '1',
      },
    ];
    uploadedDocs.clear();
    uploadedFileNames.clear();
    uploadedFilePaths.clear();
    kukAssessments.clear();
    kukEvidence.clear();
  }

  void onPersyaratanUpload(
    String key,
    String label,
    bool isUploaded,
    String? fileName,
    String? filePath,
  ) {
    setState(() {
      uploadedDocs[key] = isUploaded;
      uploadedFileNames[key] = fileName;
      uploadedFilePaths[key] = filePath;
    });
  }

  List<Map<String, dynamic>> buildPortofolioDocuments() {
    final seen = <String>{};
    final docs = <Map<String, dynamic>>[];
    void add(
      String key,
      String label, {
      bool required = true,
      String section = 'b',
      String jenisBukti = '',
    }) {
      if (key.isEmpty || seen.contains(key)) return;
      seen.add(key);
      docs.add({
        'key': key,
        'label': label,
        'section': section,
        'jenis_bukti': jenisBukti,
        'is_required': required,
        'status': uploadedDocs[key] == true
            ? 'Menunggu Verifikasi'
            : 'Belum Diunggah',
        'file_name': uploadedFileNames[key],
      });
    }

    // Same list as GET /portofolio: admin defaults + skema_syarat (mandatory flag from DB)
    for (final p in persyaratanAdministratif) {
      add(
        p['key'] ?? '',
        p['label'] ?? '',
        required: true,
        section: p['section'] ?? 'a',
        jenisBukti: 'administratif',
      );
    }
    for (final p in persyaratanDasar) {
      final key = p['key'] ?? '';
      final label = p['label'] ?? '';
      final jenis = p['jenis_bukti'] ?? '';
      final section = p['section'] ??
          sectionFromJenisBukti(jenis, key, label);
      final mand = (p['mandatory'] ?? '').toLowerCase();
      add(
        key,
        label,
        required: mand == '1' || mand == 'true',
        section: section,
        jenisBukti: jenis,
      );
    }
    for (final entry in uploadedDocs.entries) {
      if (entry.value == true && !seen.contains(entry.key)) {
        add(
          entry.key,
          entry.key,
          required: false,
          section: sectionFromJenisBukti('', entry.key, entry.key),
        );
      }
    }
    return docs;
  }
  Future<bool> isAlreadyRegisteredOnSkema(int skemaId) async {
    if (skemaId <= 0) return false;
    final token = await TokenStorage.instance.getAccessToken();
    if (token == null || token.isEmpty || token.startsWith('fake-')) {
      return false; // belum login → biar ensure-asesi dulu
    }
    final status = await AsesiService.getSertifikasiStatus(skemaId);
    if (status == null) return false;
    final terdaftar = status['terdaftar'] == true ||
        status['terdaftar'] == 1 ||
        status['terdaftar']?.toString() == 'true';
    final st = (status['status_pendaftaran']?.toString() ?? '').toLowerCase();
    if (terdaftar) return true;
    if (st.isNotEmpty && st != 'belum_terdaftar') return true;
    return false;
  }

  void clearSkemaAndJadwal() {
    selectedSkemaId = null;
    selectedSkema = null;
    selectedJadwalId = null;
    masterJadwalList = [];
    selectedSumberAnggaranId = null;
    selectedPemberiAnggaranId = null;
    masterPemberiAnggaranList = [];
    clearUnitPersyaratan();
  }

  Future<void> showAlreadyRegisteredWarning({
    String? skemaName,
    String? beMessage,
  }) async {
    if (!mounted) return;
    final name = (skemaName ?? selectedSkema ?? 'skema ini').trim();
    final body = (beMessage != null && beMessage.trim().isNotEmpty)
        ? beMessage.trim()
        : 'Skema "$name" sudah terisi / sudah Anda daftarkan. '
            'Silakan pilih skema lain untuk melanjutkan pendaftaran.';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
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
                  'Sudah Terdaftar',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
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

    // Setelah warning: null-kan skema + kosongkan jadwal, jadwal tidak bisa dipilih
    if (mounted) {
      setState(clearSkemaAndJadwal);
    }
  }
}
