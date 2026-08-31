// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart';

import '../../services/api_service.dart';
import '../../services/auth/token_storage.dart';
import '../../models/master_models.dart';
import 'pengajuan_sertifikat_screen.dart';

// ============================================================================
// PengajuanSertifikatSkemaLogic
//
// State fields + logika skema/unit/persyaratan (FR.APL.01 & FR.APL.02)
// untuk PengajuanSertifikatScreen: pilih skema, jadwal, unit kompetensi,
// persyaratan upload, dan evaluasi KUK.
// Dipisah dari screen agar file screen tetap ringkas.
// ============================================================================

mixin PengajuanSertifikatSkemaLogic on State<PengajuanSertifikatScreen> {
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
  /// true when the last kompetensi fetch failed (null/non-200/exception),
  /// so UI can show a real error + retry instead of a silent "0 unit".
  bool kompetensiLoadFailed = false;

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
      kompetensiLoadFailed = false;
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
        // API gagal (null/non-200/exception): jangan diam-diam tampil 0.
        // Tandai gagal agar UI munculkan pesan error + tombol coba lagi.
        setState(() {
          asesmenUnits = unitsFromCacheOnly();
          kompetensiHasDetail = false;
          kompetensiLoadFailed = true;
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
        // Sukses 200 tapi elemen/KUK 0 → anggap perlu retry, bukan gagal keras.
        kompetensiLoadFailed = false;
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
          kompetensiLoadFailed = true;
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
    kompetensiLoadFailed = false;
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

  void checkAllKompeten() {
    setState(() {
      for (final unit in asesmenUnits) {
        final groups = unit['elemen'];
        if (groups is! List) continue;
        for (final group in groups) {
          if (group is! Map) continue;
          final items = group['items'];
          if (items is List && items.isNotEmpty) {
            for (final item in items) {
              if (item is Map) {
                final key = item['key']?.toString() ?? '';
                if (key.isNotEmpty) {
                  kukAssessments[key] = true;
                }
              }
            }
          } else {
            final idElemen = group['id_elemen']?.toString() ?? '';
            if (idElemen.isNotEmpty) {
              kukAssessments['e:$idElemen'] = true;
            }
          }
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua unit telah dinilai Kompeten (K).'),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool isAllKompeten() {
    if (asesmenUnits.isEmpty) return false;
    for (final unit in asesmenUnits) {
      final groups = unit['elemen'];
      if (groups is! List || groups.isEmpty) return false;
      for (final group in groups) {
        if (group is! Map) continue;
        final items = group['items'];
        if (items is List && items.isNotEmpty) {
          for (final item in items) {
            if (item is Map) {
              final key = item['key']?.toString() ?? '';
              if (key.isNotEmpty && kukAssessments[key] != true) {
                return false;
              }
            }
          }
        } else {
          final idElemen = group['id_elemen']?.toString() ?? '';
          if (idElemen.isNotEmpty && kukAssessments['e:$idElemen'] != true) {
            return false;
          }
        }
      }
    }
    return true;
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