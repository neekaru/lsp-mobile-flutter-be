// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/pengajuan/step_indicator.dart';
import '../../widgets/pengajuan/data_pengajuan_form.dart';
import '../../widgets/pengajuan/data_pribadi_form.dart';
import '../../widgets/pengajuan/data_pekerjaan_form.dart';
import '../../widgets/pengajuan/dokumen_portofolio_form.dart';
import '../../widgets/pengajuan/asesmen_mandiri_form.dart';
import '../../widgets/pengajuan/unit_kompetensi_detail.dart';
import '../../widgets/pengajuan/dokumen_persyaratan_form.dart';
import 'bukti_portofolio_screen.dart';
import 'asesmen_mandiri_uji_screen.dart';
import '../../models/master_models.dart';

class PengajuanSertifikatScreen extends StatefulWidget {
  const PengajuanSertifikatScreen({super.key});

  @override
  State<PengajuanSertifikatScreen> createState() => _PengajuanSertifikatScreenState();
}

class _PengajuanSertifikatScreenState extends State<PengajuanSertifikatScreen> {
  // Lists of schemas and schedules loaded dynamically from the API/Database
  List<String> _listSkema = [
    'Pemasaran Digital',
    'Programmer (Web & Mobile Developer)',
    'Cloud Computing Administrator',
    'Digital Marketing Specialist',
    'Network Security Engineer',
    'Data Analyst Specialist',
  ];

  List<String> _listJadwal = [
    'Sertifikasi Kompetensi TIK Programmer - Batch 2 (TUK Campus Digital)',
    'Asesmen Cloud Computing - Batch 1 (TUK Sewaktu LSP)',
    'Digital Marketing Sertifikasi - Batch 3 (TUK Borneo Engineer)',
  ];

  @override
  void initState() {
    super.initState();
    _cachedUnitKompetensi = _getUnitKompetensi();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Wait for route transition animation to finish before making network calls
    await Future.delayed(const Duration(milliseconds: 375));
    if (!mounted) return;

    // Collect all fetched data FIRST, then batch into a single setState.
    // This prevents 3 separate full-tree rebuilds during init.
    List<String>? newSkema;
    List<String>? newJadwal;

    try {
      final skemaRes = await ApiService.getSertifikatPerSkema(limit: 100);
      if (skemaRes.data.isNotEmpty) {
        final fetched = skemaRes.data
            .map((item) => item.skema)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
        if (fetched.isNotEmpty) newSkema = fetched;
      }
    } catch (e) {
      debugPrint('Error loading skemas from API: $e');
    }

    try {
      final activeJadwal = await ApiService.getJadwalList(limit: 100);
      if (activeJadwal.isNotEmpty) {
        final fetched = activeJadwal
            .map((item) => item.skema)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
        if (fetched.isNotEmpty) newJadwal = fetched;
      } else {
        final jadwalBaruList = await ApiService.getJadwalBaru();
        if (jadwalBaruList.isNotEmpty) {
          final fetched = jadwalBaruList
              .map((item) => item.jadwal)
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList();
          if (fetched.isNotEmpty) newJadwal = fetched;
        }
      }
    } catch (e) {
      debugPrint('Error loading schedules from API: $e');
    }

    // Single setState: one rebuild instead of three
    if (!mounted) return;
    setState(() {
      if (newSkema != null) _listSkema = newSkema;
      if (newJadwal != null) _listJadwal = newJadwal;
      if (_selectedSkema != null && !_listSkema.contains(_selectedSkema)) {
        _listSkema.add(_selectedSkema!);
      }
      if (_selectedJadwal != null && !_listJadwal.contains(_selectedJadwal)) {
        _selectedJadwal = null;
      }
    });

    // Fetch master data for Provinsi dropdown
    _fetchProvinsi();

    // Fetch master data for Skema dropdown
    _fetchMasterSkema();
  }

  Future<void> _fetchProvinsi() async {
    setState(() {
      _isLoadingProvinsi = true;
    });
    try {
      final list = await ApiService.getProvinsiList();
      if (mounted) {
        setState(() {
          _listProvinsi = list;
        });
      }
    } catch (e) {
      debugPrint('Error fetching provinsi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProvinsi = false;
        });
      }
    }
  }

  Future<void> _fetchKabupaten(String provinceId) async {
    setState(() {
      _isLoadingKabupaten = true;
      _listKabupaten = [];
      _listKecamatan = [];
    });
    try {
      final list = await ApiService.getKabupatenList(provinceId);
      if (mounted) {
        setState(() {
          _listKabupaten = list;
        });
      }
    } catch (e) {
      debugPrint('Error fetching kabupaten: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingKabupaten = false;
        });
      }
    }
  }

  Future<void> _fetchKecamatan(String kabupatenId) async {
    setState(() {
      _isLoadingKecamatan = true;
      _listKecamatan = [];
    });
    try {
      final list = await ApiService.getKecamatanList(kabupatenId);
      if (mounted) {
        setState(() {
          _listKecamatan = list;
        });
      }
    } catch (e) {
      debugPrint('Error fetching kecamatan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingKecamatan = false;
        });
      }
    }
  }

  Future<void> _fetchMasterSkema() async {
    setState(() {
      _isLoadingSkema = true;
    });
    try {
      final list = await ApiService.getMasterSkemaList();
      if (mounted) {
        setState(() {
          _masterSkemaList = list;
          _isLoadingSkema = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master skema: $e');
      if (mounted) {
        setState(() {
          _isLoadingSkema = false;
        });
      }
    }
  }

  Future<void> _fetchMasterJadwal(int idSkema) async {
    setState(() {
      _isLoadingJadwal = true;
      _masterJadwalList = [];
    });
    try {
      final list = await ApiService.getMasterJadwalList(idSkema);
      if (mounted) {
        setState(() {
          _masterJadwalList = list;
          _isLoadingJadwal = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master jadwal: $e');
      if (mounted) {
        setState(() {
          _isLoadingJadwal = false;
        });
      }
    }
  }

  // Current active step
  int _currentStep = 0;

  // Step 1: Data Pengajuan State
  int? _selectedSkemaId;
  int? _selectedJadwalId;
  String? _selectedSkema;
  String? _selectedJadwal;
  final TextEditingController _sumberAnggaranController = TextEditingController();
  final TextEditingController _pemberiAnggaranController = TextEditingController();

  List<MasterSkema> _masterSkemaList = [];
  List<MasterJadwal> _masterJadwalList = [];
  bool _isLoadingSkema = false;
  bool _isLoadingJadwal = false;

  // Step 2: Profil Peserta - Data Pribadi State
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  String _jenisKelamin = 'Laki-Laki';
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _alamatDomisiliController = TextEditingController();
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedKecamatan;

  // Master lists and loading indicators for Profil Peserta dynamic dropdowns
  List<MasterItem> _listProvinsi = [];
  List<MasterItem> _listKabupaten = [];
  List<MasterItem> _listKecamatan = [];
  bool _isLoadingProvinsi = false;
  bool _isLoadingKabupaten = false;
  bool _isLoadingKecamatan = false;
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedPendidikan;
  final TextEditingController _namaSekolahController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();

  // Step 3: Profil Peserta - Data Pekerjaan State
  String? _selectedPekerjaan;
  final TextEditingController _namaPerusahaanController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _alamatPerusahaanController = TextEditingController();
  final TextEditingController _kodeposPerusahaanController = TextEditingController();
  final TextEditingController _telpPerusahaanController = TextEditingController();
  final TextEditingController _emailPerusahaanController = TextEditingController();

  // Step 4: Dokumen Portofolio State (Simulated upload status)
  final Map<String, bool> _uploadedDocs = {
    'Ijazah Terakhir / SMA / Sederajat': true,
    'Sertifikat Pelatihan Berbasis Kompetensi': true,
    'Surat Keterangan Pengalaman Kerja': false,
    'Pasfoto': true,
    'Identitas Pribadi (KTP/Kartu Pelajar)': true,
    'Link Portofolio / GitHub': true,
  };

  final Map<String, String?> _uploadedFileNames = {
    'Ijazah Terakhir / SMA / Sederajat': 'Ijasah_S1_Teknik_Informatika.PDF',
    'Sertifikat Pelatihan Berbasis Kompetensi': 'Sertifikat_digital_marketing.PDF',
    'Surat Keterangan Pengalaman Kerja': null,
    'Pasfoto': 'Pas_foto_Hanafi.JPG',
    'Identitas Pribadi (KTP/Kartu Pelajar)': 'KTP_Hanafi.PDF',
    'Link Portofolio / GitHub': 'https://github.com/MuhammadHanafi',
  };

  int? _activeUnitDetailIndex;
  final Map<String, bool?> _kukAssessments = {};
  final Map<String, String?> _kukEvidence = {};

  // PERF: Cached unit kompetensi list — recomputed only when skema changes,
  // not on every build() call. Previously _getUnitKompetensi() ran loop +
  // string normalization + map mutation on every setState (e.g. radio tap).
  List<Map<String, dynamic>> _cachedUnitKompetensi = [];

  // Step 5: Asesmen Mandiri State (Dynamic unit kompetensi based on selected schema)
  final Map<String, List<Map<String, dynamic>>> _schemaUnits = {
    'Pemasaran Digital': [
      {'kode': 'M.70MKT00.010.2', 'judul': 'Mengolah Data Riset', 'kompeten': true},
      {'kode': 'M.70MKT00.013.1', 'judul': 'Melaksanakan Kegiatan Analisis di Media Sosial dan Media Bisnis Digital', 'kompeten': true},
      {'kode': 'G.46RIT00.055.1', 'judul': 'Melakukan Aktivitas Pemasaran Digital untuk Bisnis Ritel', 'kompeten': true},
      {'kode': 'M.70MKT00.012.1', 'judul': 'Menggunakan Media Sosial dan Aplikasi Daring(Online Tools)', 'kompeten': true},
      {'kode': 'M.70MKT00.014.1', 'judul': 'Mempersiapkan Konten Digital', 'kompeten': true},
      {'kode': 'M.70MKT00.009.1', 'judul': 'Merancang Strategi Pemasaran Digital', 'kompeten': true},
      {'kode': 'M.70MKT00.015.1', 'judul': 'Mengelola Hubungan Pelanggan secara Digital', 'kompeten': true},
      {'kode': 'M.70MKT00.016.1', 'judul': 'Mengukur Efektivitas Pemasaran Digital', 'kompeten': true},
    ],
    'Programmer (Web & Mobile Developer)': [
      {'kode': 'J.620100.001.01', 'judul': 'Mengimplementasikan Algoritma Pemrograman', 'kompeten': true},
      {'kode': 'J.620100.002.01', 'judul': 'Menggunakan Struktur Data', 'kompeten': true},
      {'kode': 'J.620100.003.01', 'judul': 'Menulis Kode dengan Prinsip Pemrograman Berorientasi Objek', 'kompeten': true},
      {'kode': 'J.620100.004.01', 'judul': 'Melakukan Debugging dan Pengujian Unit', 'kompeten': true},
    ],
    'Cloud Computing Administrator': [
      {'kode': 'C.620200.001.02', 'judul': 'Merancang Infrastruktur Cloud', 'kompeten': true},
      {'kode': 'C.620200.002.02', 'judul': 'Mengelola VM Instance dan Container', 'kompeten': true},
      {'kode': 'C.620200.003.02', 'judul': 'Konfigurasi Virtual Private Network (VPC)', 'kompeten': true},
    ],
    'Digital Marketing Specialist': [
      {'kode': 'M.70MKT00.010.2', 'judul': 'Mengolah Data Riset', 'kompeten': true},
      {'kode': 'M.70MKT00.013.1', 'judul': 'Melaksanakan Kegiatan Analisis di Media Sosial dan Media Bisnis Digital', 'kompeten': true},
      {'kode': 'G.46RIT00.055.1', 'judul': 'Melakukan Aktivitas Pemasaran Digital untuk Bisnis Ritel', 'kompeten': true},
      {'kode': 'M.70MKT00.012.1', 'judul': 'Menggunakan Media Sosial dan Aplikasi Daring(Online Tools)', 'kompeten': true},
      {'kode': 'M.70MKT00.014.1', 'judul': 'Mempersiapkan Konten Digital', 'kompeten': true},
      {'kode': 'M.70MKT00.009.1', 'judul': 'Merancang Strategi Pemasaran Digital', 'kompeten': true},
    ],
    'Network Security Engineer': [
      {'kode': 'N.620400.001.03', 'judul': 'Mengonfigurasi Firewalls dan IDS/IPS', 'kompeten': true},
      {'kode': 'N.620400.002.03', 'judul': 'Melakukan Audit Keamanan Jaringan', 'kompeten': true},
      {'kode': 'N.620400.003.03', 'judul': 'Merespon Insiden Keamanan Siber', 'kompeten': true},
    ],
    'Data Analyst Specialist': [
      {'kode': 'DA.620500.001.01', 'judul': 'Melakukan Pra-pemrosesan Data (Cleaning)', 'kompeten': true},
      {'kode': 'DA.620500.002.01', 'judul': 'Memvisualisasikan Data Interaktif', 'kompeten': true},
      {'kode': 'DA.620500.003.01', 'judul': 'Melakukan Analisis Statistik Deskriptif', 'kompeten': true},
    ],
  };

  List<Map<String, dynamic>> _getUnitKompetensi() {
    final String targetSkema = _selectedSkema ?? 'Pemasaran Digital';
    
    // Check exact key first
    if (_schemaUnits.containsKey(targetSkema)) {
      return _schemaUnits[targetSkema]!;
    }
    
    // Check normalized/contained keys
    final normalizedTarget = targetSkema.toLowerCase();
    for (var key in _schemaUnits.keys) {
      final normalizedKey = key.toLowerCase();
      if (normalizedTarget == normalizedKey ||
          normalizedTarget.contains(normalizedKey) ||
          normalizedKey.contains(normalizedTarget) ||
          (normalizedKey.contains('pemasaran') && normalizedTarget.contains('marketing')) ||
          (normalizedKey.contains('marketing') && normalizedTarget.contains('pemasaran')) ||
          (normalizedKey.contains('programmer') && normalizedTarget.contains('developer')) ||
          (normalizedKey.contains('developer') && normalizedTarget.contains('programmer'))) {
        return _schemaUnits[key]!;
      }
    }

    // Generate dynamically based on the selected schema name if not predefined
    final String name = targetSkema;
    final List<String> words = name.split(' ');
    final String prefix = words.isNotEmpty ? words.first.substring(0, words.first.length > 2 ? 3 : words.first.length).toUpperCase() : 'SKM';

    final generated = [
      {'kode': '$prefix.620100.001.01', 'judul': 'Mempersiapkan Lingkungan Kerja untuk $name', 'kompeten': true},
      {'kode': '$prefix.620100.002.01', 'judul': 'Mengimplementasikan Fitur Utama pada $name', 'kompeten': true},
      {'kode': '$prefix.620100.003.01', 'judul': 'Melakukan Pengujian dan Dokumentasi Hasil Kerja $name', 'kompeten': true},
      {'kode': '$prefix.620100.004.01', 'judul': 'Mengelola Keamanan Sistem Informasi untuk $name', 'kompeten': true},
      {'kode': '$prefix.620100.005.01', 'judul': 'Melakukan Pemeliharaan Rutin pada Sistem $name', 'kompeten': true},
      {'kode': '$prefix.620100.006.01', 'judul': 'Menganalisis Kebutuhan Operasional Terkait $name', 'kompeten': true},
      {'kode': '$prefix.620100.007.01', 'judul': 'Mengevaluasi Kinerja dan Integritas Sistem $name', 'kompeten': true},
      {'kode': '$prefix.620100.008.01', 'judul': 'Menyusun Dokumen Akhir Penerapan $name', 'kompeten': true},
    ];

    _schemaUnits[name] = generated;
    return generated;
  }

  /// PERF: Refresh the cached unit list. Call this only when _selectedSkema changes.
  void _refreshUnitKompetensiCache() {
    _cachedUnitKompetensi = _getUnitKompetensi();
  }

  @override
  void dispose() {
    _sumberAnggaranController.dispose();
    _pemberiAnggaranController.dispose();
    _nikController.dispose();
    _namaLengkapController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatDomisiliController.dispose();
    _noTelpController.dispose();
    _emailController.dispose();
    _namaSekolahController.dispose();
    _jurusanController.dispose();
    _namaPerusahaanController.dispose();
    _jabatanController.dispose();
    _alamatPerusahaanController.dispose();
    _kodeposPerusahaanController.dispose();
    _telpPerusahaanController.dispose();
    _emailPerusahaanController.dispose();
    super.dispose();
  }

  // Get screen title based on current step
  String get _appBarTitle {
    switch (_currentStep) {
      case 0:
        return 'Pengajuan Sertifikat';
      case 1:
      case 2:
      case 3:
        return 'Profil Peserta';
      case 4:
        return 'Dokumen Portofolio';
      case 5:
        return _activeUnitDetailIndex != null ? 'Detail Uji Kompetensi' : 'Asesmen Mandiri';
      default:
        return 'Pengajuan Sertifikat';
    }
  }

  void _navigateToBuktiPortofolio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuktiPortofolioScreen(
          selectedSkema: _selectedSkema ?? 'Pemasaran Digital',
          uploadedDocs: _uploadedDocs,
          uploadedFileNames: _uploadedFileNames,
          onUploadChanged: (docName, isUploaded, fileName) {
            setState(() {
              _uploadedDocs[docName] = isUploaded;
              _uploadedFileNames[docName] = fileName;
            });
          },
        ),
      ),
    );
  }

  // Progress to next step with validation (bypassed for testing)
  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      _showSuccessDialog();
    }
  }

  void _previousStep() {
    if (_currentStep == 5 && _activeUnitDetailIndex != null) {
      setState(() {
        _activeUnitDetailIndex = null;
      });
      return;
    }
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  // ignore: unused_element
  void _showErrorSnackBar(String message) {
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

  void _showSuccessDialog() {
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
                      Navigator.of(context).pop(); // Return from Screen
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

  @override
  Widget build(BuildContext context) {
    // PERF: paddingOf only subscribes to padding changes (status bar).
    // MediaQuery.of(context) subscribes to ALL changes including keyboard
    // viewInsets — causing a full tree rebuild (15+ fields) on every
    // keyboard open/close. That was the #1 cause of lag.
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          if (_currentStep != 5 || _activeUnitDetailIndex == null)
            StepIndicator(currentStep: _currentStep),
          Expanded(
            child: RepaintBoundary(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A000000), // black with 4% opacity
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildCurrentFormStep(),
                ),
              ),
            ),
          ),
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _previousStep,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Text(
            _appBarTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const Icon(Icons.more_horiz_rounded, color: Colors.black, size: 24),
        ],
      ),
    );
  }

  Widget _buildCurrentFormStep() {
    switch (_currentStep) {
      case 0:
        return DataPengajuanForm(
          selectedSkema: _selectedSkemaId,
          selectedJadwal: _selectedJadwalId,
          sumberAnggaranController: _sumberAnggaranController,
          pemberiAnggaranController: _pemberiAnggaranController,
          listSkema: _masterSkemaList,
          listJadwal: _masterJadwalList,
          isLoadingSkema: _isLoadingSkema,
          isLoadingJadwal: _isLoadingJadwal,
          onSkemaChanged: (val) {
            setState(() {
              _selectedSkemaId = val;
              _selectedJadwalId = null;
              _selectedJadwal = null;
              _masterJadwalList = [];
              if (val != null) {
                try {
                  final selected = _masterSkemaList.firstWhere((item) => item.id == val);
                  _selectedSkema = selected.namaSkema;
                } catch (_) {
                  _selectedSkema = null;
                }
              } else {
                _selectedSkema = null;
              }
              _refreshUnitKompetensiCache();
            });
            if (val != null) {
              _fetchMasterJadwal(val);
            }
          },
          onJadwalChanged: (val) {
            setState(() {
              _selectedJadwalId = val;
              if (val != null) {
                try {
                  final selected = _masterJadwalList.firstWhere((item) => item.id == val);
                  _selectedJadwal = selected.displayName;
                } catch (_) {
                  _selectedJadwal = null;
                }
              } else {
                _selectedJadwal = null;
              }
            });
          },
        );
      case 1:
        return DataPribadiForm(
          nikController: _nikController,
          namaLengkapController: _namaLengkapController,
          jenisKelamin: _jenisKelamin,
          tempatLahirController: _tempatLahirController,
          tanggalLahirController: _tanggalLahirController,
          alamatDomisiliController: _alamatDomisiliController,
          selectedProvinsi: _selectedProvinsi,
          selectedKota: _selectedKota,
          selectedKecamatan: _selectedKecamatan,
          noTelpController: _noTelpController,
          emailController: _emailController,
          selectedPendidikan: _selectedPendidikan,
          namaSekolahController: _namaSekolahController,
          jurusanController: _jurusanController,
          listProvinsi: _listProvinsi,
          listKabupaten: _listKabupaten,
          listKecamatan: _listKecamatan,
          isLoadingProvinsi: _isLoadingProvinsi,
          isLoadingKabupaten: _isLoadingKabupaten,
          isLoadingKecamatan: _isLoadingKecamatan,
          onJenisKelaminChanged: (val) {
            setState(() {
              _jenisKelamin = val!;
            });
          },
          onProvinsiChanged: (val) {
            setState(() {
              _selectedProvinsi = val;
              _selectedKota = null;
              _selectedKecamatan = null;
              _listKabupaten = [];
              _listKecamatan = [];
            });
            if (val != null) {
              _fetchKabupaten(val);
            }
          },
          onKotaChanged: (val) {
            setState(() {
              _selectedKota = val;
              _selectedKecamatan = null;
              _listKecamatan = [];
            });
            if (val != null) {
              _fetchKecamatan(val);
            }
          },
          onKecamatanChanged: (val) {
            setState(() {
              _selectedKecamatan = val;
            });
          },
          onPendidikanChanged: (val) {
            setState(() {
              _selectedPendidikan = val;
            });
          },
          onTanggalLahirTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                _tanggalLahirController.text =
                    "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
              });
            }
          },
        );
      case 2:
        return DataPekerjaanForm(
          selectedPekerjaan: _selectedPekerjaan,
          namaPerusahaanController: _namaPerusahaanController,
          jabatanController: _jabatanController,
          alamatPerusahaanController: _alamatPerusahaanController,
          kodeposPerusahaanController: _kodeposPerusahaanController,
          telpPerusahaanController: _telpPerusahaanController,
          emailPerusahaanController: _emailPerusahaanController,
          onPekerjaanChanged: (val) {
            setState(() {
              _selectedPekerjaan = val;
            });
          },
        );
      case 3:
        return DokumenPersyaratanForm(
          selectedSkema: _selectedSkema ?? 'Pemasaran Digital',
          unitKompetensi: _cachedUnitKompetensi,
          uploadedDocs: _uploadedDocs,
          uploadedFileNames: _uploadedFileNames,
          onUploadChanged: (docName, isUploaded, fileName) {
            setState(() {
              _uploadedDocs[docName] = isUploaded;
              _uploadedFileNames[docName] = fileName;
            });
          },
        );
      case 4:
        return DokumenPortofolioForm(
          selectedSkema: _selectedSkema ?? 'Pemasaran Digital',
          onBuktiTap: _navigateToBuktiPortofolio,
          onUnitTap: () async {
            final completed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => AsesmenMandiriUjiScreen(
                  selectedSkema: _selectedSkema ?? 'Pemasaran Digital',
                  unitKompetensi: _cachedUnitKompetensi,
                  uploadedFileNames: _uploadedFileNames,
                  kukAssessments: _kukAssessments,
                  kukEvidence: _kukEvidence,
                  onAssessmentChanged: (kuk, isK) {
                    setState(() {
                      _kukAssessments[kuk] = isK;
                    });
                  },
                  onEvidenceChanged: (kuk, fileName) {
                    setState(() {
                      _kukEvidence[kuk] = fileName;
                    });
                  },
                ),
              ),
            );
            if (completed == true) {
              setState(() {
                _currentStep = 5;
              });
            }
          },
        );
      case 5:
        if (_activeUnitDetailIndex != null) {
          final unit = _cachedUnitKompetensi[_activeUnitDetailIndex!];
          final String kode = unit['kode'] as String? ?? '';
          final String judul = unit['judul'] as String? ?? '';
          String kukCount = '11 KUK';
          if (kode.contains('001')) {
            kukCount = '8 KUK';
          } else if (kode.contains('002')) {
            kukCount = '10 KUK';
          } else if (kode.contains('003')) {
            kukCount = '12 KUK';
          } else if (kode.contains('007')) {
            kukCount = '13 KUK';
          }

          return UnitKompetensiDetail(
            unitKode: kode,
            unitJudul: judul,
            kukCount: kukCount,
            uploadedFileNames: _uploadedFileNames,
            kukAssessments: _kukAssessments,
            kukEvidence: _kukEvidence,
            onAssessmentChanged: (kuk, isK) {
              setState(() {
                _kukAssessments[kuk] = isK;
              });
            },
            onEvidenceChanged: (kuk, fileName) {
              setState(() {
                _kukEvidence[kuk] = fileName;
              });
            },
            onKembali: () {
              setState(() {
                _activeUnitDetailIndex = null;
              });
            },
            onSelesai: () {
              setState(() {
                _activeUnitDetailIndex = null;
              });
            },
          );
        }

        return AsesmenMandiriForm(
          selectedSkema: _selectedSkema ?? 'Pemasaran Digital',
          unitKompetensi: _cachedUnitKompetensi,
          onUnitTap: (index) {
            setState(() {
              _activeUnitDetailIndex = index;
            });
          },
          onBuktiTap: _navigateToBuktiPortofolio,
        );
      default:
        return Container();
    }
  }

  Widget _buildBottomActionButtons() {
    if (_currentStep == 5 && _activeUnitDetailIndex != null) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _activeUnitDetailIndex = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      backgroundColor: const Color(0xFFE2E8F0),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _activeUnitDetailIndex = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Selesai dan Kirim',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool isStep4 = _currentStep == 4;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      backgroundColor: const Color(0xFFE2E8F0),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (!isStep4) ...[
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 5 ? 'Kirim Pengajuan' : 'Selanjutnya',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentStep < 5) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
