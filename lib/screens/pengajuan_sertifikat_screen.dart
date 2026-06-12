// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/pengajuan/step_indicator.dart';
import '../widgets/pengajuan/data_pengajuan_form.dart';
import '../widgets/pengajuan/data_pribadi_form.dart';
import '../widgets/pengajuan/data_pekerjaan_form.dart';
import '../widgets/pengajuan/dokumen_portofolio_form.dart';
import '../widgets/pengajuan/asesmen_mandiri_form.dart';

class PengajuanSertifikatScreen extends StatefulWidget {
  const PengajuanSertifikatScreen({super.key});

  @override
  State<PengajuanSertifikatScreen> createState() => _PengajuanSertifikatScreenState();
}

class _PengajuanSertifikatScreenState extends State<PengajuanSertifikatScreen> {
  // Lists of schemas and schedules loaded dynamically from the API/Database
  List<String> _listSkema = [
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
        _selectedSkema = null;
      }
      if (_selectedJadwal != null && !_listJadwal.contains(_selectedJadwal)) {
        _selectedJadwal = null;
      }
    });
  }

  // Current active step
  int _currentStep = 0;

  // Step 1: Data Pengajuan State
  String? _selectedSkema;
  String? _selectedJadwal;
  final TextEditingController _sumberAnggaranController = TextEditingController();
  final TextEditingController _pemberiAnggaranController = TextEditingController();

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
    'KTP / Paspor': false,
    'CV / Daftar Riwayat Hidup': false,
    'Ijazah Terakhir': false,
    'Surat Rekomendasi / Keterangan Kerja': false,
    'Sertifikat Pelatihan Terkait': false,
  };

  // Step 5: Asesmen Mandiri State (Dynamic unit kompetensi based on selected schema)
  final Map<String, List<Map<String, dynamic>>> _schemaUnits = {
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
      {'kode': 'D.620300.001.01', 'judul': 'Merencanakan Strategi Kampanye Digital', 'kompeten': true},
      {'kode': 'D.620300.002.01', 'judul': 'Mengoptimalkan Media Sosial untuk Bisnis', 'kompeten': true},
      {'kode': 'D.620300.003.01', 'judul': 'Menganalisis Kinerja Search Engine Optimization (SEO)', 'kompeten': true},
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
    if (_selectedSkema == null) {
      return [];
    }
    if (_schemaUnits.containsKey(_selectedSkema)) {
      return _schemaUnits[_selectedSkema]!;
    }

    // Generate dynamically based on the selected schema name if not predefined
    final String name = _selectedSkema!;
    final List<String> words = name.split(' ');
    final String prefix = words.isNotEmpty ? words.first.substring(0, words.first.length > 2 ? 3 : words.first.length).toUpperCase() : 'SKM';

    final generated = [
      {'kode': '$prefix.620100.001.01', 'judul': 'Mempersiapkan Lingkungan Kerja untuk $name', 'kompeten': true},
      {'kode': '$prefix.620100.002.01', 'judul': 'Mengimplementasikan Fitur Utama pada $name', 'kompeten': true},
      {'kode': '$prefix.620100.003.01', 'judul': 'Melakukan Pengujian dan Dokumentasi Hasil Kerja $name', 'kompeten': true},
    ];

    _schemaUnits[name] = generated;
    return generated;
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
        return 'Profil Peserta';
      case 3:
        return 'Dokumen Portofolio';
      case 4:
        return 'Asesmen Mandiri';
      default:
        return 'Pengajuan Sertifikat';
    }
  }

  // Progress to next step with validation
  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedSkema == null || _selectedJadwal == null || 
          _sumberAnggaranController.text.trim().isEmpty || 
          _pemberiAnggaranController.text.trim().isEmpty) {
        _showErrorSnackBar('Semua data wajib diisi.');
        return;
      }
    } else if (_currentStep == 1) {
      if (_nikController.text.trim().isEmpty ||
          _namaLengkapController.text.trim().isEmpty ||
          _tempatLahirController.text.trim().isEmpty ||
          _tanggalLahirController.text.trim().isEmpty ||
          _alamatDomisiliController.text.trim().isEmpty ||
          _selectedProvinsi == null ||
          _selectedKota == null ||
          _selectedKecamatan == null ||
          _noTelpController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _selectedPendidikan == null ||
          _namaSekolahController.text.trim().isEmpty ||
          _jurusanController.text.trim().isEmpty) {
        _showErrorSnackBar('Semua data pribadi wajib diisi.');
        return;
      }
    } else if (_currentStep == 2) {
      if (_selectedPekerjaan == null ||
          _namaPerusahaanController.text.trim().isEmpty ||
          _jabatanController.text.trim().isEmpty ||
          _alamatPerusahaanController.text.trim().isEmpty ||
          _kodeposPerusahaanController.text.trim().isEmpty ||
          _telpPerusahaanController.text.trim().isEmpty ||
          _emailPerusahaanController.text.trim().isEmpty) {
        _showErrorSnackBar('Semua data pekerjaan wajib diisi.');
        return;
      }
    } else if (_currentStep == 3) {
      if (_uploadedDocs.values.contains(false)) {
        _showErrorSnackBar('Silakan unggah semua dokumen persyaratan.');
        return;
      }
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      _showSuccessDialog();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

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
          selectedSkema: _selectedSkema,
          selectedJadwal: _selectedJadwal,
          sumberAnggaranController: _sumberAnggaranController,
          pemberiAnggaranController: _pemberiAnggaranController,
          listSkema: _listSkema,
          listJadwal: _listJadwal,
          onSkemaChanged: (val) {
            setState(() {
              _selectedSkema = val;
              // Reset dependent fields/selections to keep form consistent
              _selectedJadwal = null;
            });
          },
          onJadwalChanged: (val) {
            setState(() {
              _selectedJadwal = val;
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
            });
          },
          onKotaChanged: (val) {
            setState(() {
              _selectedKota = val;
              _selectedKecamatan = null;
            });
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
        return DokumenPortofolioForm(
          uploadedDocs: _uploadedDocs,
          onToggleUpload: (docName) {
            setState(() {
              _uploadedDocs[docName] = !_uploadedDocs[docName]!;
            });
          },
        );
      case 4:
        return AsesmenMandiriForm(
          unitKompetensi: _getUnitKompetensi(),
          onKompetenChanged: (index, kompeten) {
            setState(() {
              _getUnitKompetensi()[index]['kompeten'] = kompeten;
            });
          },
        );
      default:
        return Container();
    }
  }

  Widget _buildBottomActionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                flex: 1,
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
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: 2,
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
                        _currentStep == 4 ? 'Kirim Pengajuan' : 'Selanjutnya',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_currentStep < 4) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
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
}
