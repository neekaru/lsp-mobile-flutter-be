// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

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
    _cachedUnitKompetensi = [];
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

    // Fetch master sumber anggaran (pemberi di-load cascade saat sumber dipilih)
    _fetchMasterSumberAnggaran();

    // FR.APL.01: master pendidikan/pekerjaan + prefill profile
    _fetchMasterPendidikan();
    _fetchMasterPekerjaan();
    _loadAsesiProfile();
  }

  Future<void> _fetchMasterPekerjaan() async {
    setState(() => _isLoadingPekerjaan = true);
    try {
      final list = await ApiService.getMasterPekerjaanList();
      if (mounted) {
        setState(() {
          _listPekerjaan = list;
          _isLoadingPekerjaan = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master pekerjaan: $e');
      if (mounted) setState(() => _isLoadingPekerjaan = false);
    }
  }

  Future<void> _fetchMasterPendidikan() async {
    setState(() => _isLoadingPendidikan = true);
    try {
      final list = await ApiService.getMasterPendidikanList();
      if (mounted) {
        setState(() {
          _listPendidikan = list;
          _isLoadingPendidikan = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master pendidikan: $e');
      if (mounted) setState(() => _isLoadingPendidikan = false);
    }
  }

  Future<void> _loadAsesiProfile() async {
    try {
      final profile = await AsesiService.getProfile();
      if (profile == null || !mounted) return;
      setState(() {
        if ((profile['nik']?.toString() ?? '').isNotEmpty) {
          _nikController.text = profile['nik'].toString();
        }
        if ((profile['nama_lengkap']?.toString() ?? '').isNotEmpty) {
          _namaLengkapController.text = profile['nama_lengkap'].toString();
        }
        final jk = profile['jenis_kelamin']?.toString() ?? '';
        if (jk == '1' || jk.toLowerCase().contains('laki')) {
          _jenisKelamin = 'Laki-Laki';
        } else if (jk == '2' || jk.toLowerCase().contains('perempuan')) {
          _jenisKelamin = 'Perempuan';
        }
        if ((profile['tempat_lahir']?.toString() ?? '').isNotEmpty) {
          _tempatLahirController.text = profile['tempat_lahir'].toString();
        }
        if ((profile['tgl_lahir']?.toString() ?? '').isNotEmpty) {
          _tanggalLahirController.text =
              AsesiService.normalizeTglLahir(profile['tgl_lahir'].toString());
        }
        if ((profile['alamat']?.toString() ?? '').isNotEmpty) {
          _alamatDomisiliController.text = profile['alamat'].toString();
        }
        if (profile['id_provinsi'] != null) {
          _selectedProvinsi = profile['id_provinsi'].toString();
        }
        if (profile['id_kabupaten'] != null) {
          _selectedKota = profile['id_kabupaten'].toString();
        }
        if ((profile['id_kecamatan']?.toString() ?? '').isNotEmpty) {
          _selectedKecamatan = profile['id_kecamatan'].toString();
        }
        if ((profile['telp']?.toString() ?? '').isNotEmpty) {
          _noTelpController.text = profile['telp'].toString();
        }
        if ((profile['email']?.toString() ?? '').isNotEmpty) {
          _emailController.text = profile['email'].toString();
        }
        if (profile['id_pendidikan'] != null) {
          _selectedPendidikanId =
              int.tryParse(profile['id_pendidikan'].toString());
        }
        if ((profile['nama_sekolah']?.toString() ?? '').isNotEmpty) {
          _namaSekolahController.text = profile['nama_sekolah'].toString();
        }
        if ((profile['jurusan']?.toString() ?? '').isNotEmpty) {
          _jurusanController.text = profile['jurusan'].toString();
        }
        if (profile['id_pekerjaan'] != null) {
          _selectedPekerjaanId =
              int.tryParse(profile['id_pekerjaan'].toString());
        }
        if ((profile['organisasi']?.toString() ?? '').isNotEmpty) {
          _namaPerusahaanController.text = profile['organisasi'].toString();
        }
        if ((profile['jabatan']?.toString() ?? '').isNotEmpty) {
          _jabatanController.text = profile['jabatan'].toString();
        }
        if ((profile['alamat_company']?.toString() ?? '').isNotEmpty) {
          _alamatPerusahaanController.text =
              profile['alamat_company'].toString();
        }
        if ((profile['kode_pos_company']?.toString() ?? '').isNotEmpty) {
          _kodeposPerusahaanController.text =
              profile['kode_pos_company'].toString();
        }
        if ((profile['telp_company']?.toString() ?? '').isNotEmpty) {
          _telpPerusahaanController.text = profile['telp_company'].toString();
        }
        if ((profile['email_company']?.toString() ?? '').isNotEmpty) {
          _emailPerusahaanController.text =
              profile['email_company'].toString();
        }
      });
      if (_selectedProvinsi != null) {
        await _fetchKabupaten(_selectedProvinsi!);
        if (_selectedKota != null) {
          await _fetchKecamatan(_selectedKota!);
        }
      }
    } catch (e) {
      debugPrint('Error loading asesi profile: $e');
    }
  }

  Map<String, dynamic> _buildDataPribadiPayload() {
    final payload = <String, dynamic>{
      'nik': _nikController.text.trim(),
      'nama_lengkap': _namaLengkapController.text.trim(),
      'jenis_kelamin': AsesiService.mapJenisKelamin(_jenisKelamin),
      'tempat_lahir': _tempatLahirController.text.trim(),
      'tgl_lahir': AsesiService.normalizeTglLahir(_tanggalLahirController.text),
      'alamat': _alamatDomisiliController.text.trim(),
      'telp': _noTelpController.text.trim(),
      'email': _emailController.text.trim(),
      'nama_sekolah': _namaSekolahController.text.trim(),
      'jurusan': _jurusanController.text.trim(),
    };
    final idProv = int.tryParse(_selectedProvinsi ?? '');
    if (idProv != null) payload['id_provinsi'] = idProv;
    final idKab = int.tryParse(_selectedKota ?? '');
    if (idKab != null) payload['id_kabupaten'] = idKab;
    if ((_selectedKecamatan ?? '').isNotEmpty) {
      payload['id_kecamatan'] = _selectedKecamatan;
    }
    if (_selectedPendidikanId != null) {
      payload['id_pendidikan'] = _selectedPendidikanId;
    }
    if (_selectedSumberAnggaranId != null) {
      payload['id_sumber_anggaran'] = _selectedSumberAnggaranId;
    }
    if (_selectedPemberiAnggaranId != null) {
      payload['id_instansi_anggaran'] = _selectedPemberiAnggaranId;
    }
    if (_selectedPekerjaanId != null) {
      payload['id_pekerjaan'] = _selectedPekerjaanId;
    }
    final organisasi = _namaPerusahaanController.text.trim();
    if (organisasi.isNotEmpty) payload['organisasi'] = organisasi;
    final jabatan = _jabatanController.text.trim();
    if (jabatan.isNotEmpty) payload['jabatan'] = jabatan;
    final alamatCompany = _alamatPerusahaanController.text.trim();
    if (alamatCompany.isNotEmpty) payload['alamat_company'] = alamatCompany;
    final kodePos = _kodeposPerusahaanController.text.trim();
    if (kodePos.isNotEmpty) payload['kode_pos_company'] = kodePos;
    final telpCompany = _telpPerusahaanController.text.trim();
    if (telpCompany.isNotEmpty) payload['telp_company'] = telpCompany;
    final emailCompany = _emailPerusahaanController.text.trim();
    if (emailCompany.isNotEmpty) payload['email_company'] = emailCompany;
    return payload;
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

  Future<void> _fetchMasterSumberAnggaran() async {
    setState(() {
      _isLoadingSumberAnggaran = true;
    });
    try {
      final list = await ApiService.getMasterSumberAnggaranList();
      if (mounted) {
        setState(() {
          _masterSumberAnggaranList = list;
          _isLoadingSumberAnggaran = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master sumber anggaran: $e');
      if (mounted) {
        setState(() {
          _isLoadingSumberAnggaran = false;
        });
      }
    }
  }

  Future<void> _fetchMasterPemberiAnggaran(int idSumberAnggaran) async {
    setState(() {
      _isLoadingPemberiAnggaran = true;
      _masterPemberiAnggaranList = [];
    });
    try {
      final list = await ApiService.getMasterPemberiAnggaranList(
        idSumberAnggaran: idSumberAnggaran,
      );
      if (mounted) {
        setState(() {
          _masterPemberiAnggaranList = list;
          _isLoadingPemberiAnggaran = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching master pemberi anggaran: $e');
      if (mounted) {
        setState(() {
          _isLoadingPemberiAnggaran = false;
        });
      }
    }
  }

  // Current active step
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1: Data Pengajuan State
  int? _selectedSkemaId;
  int? _selectedJadwalId;
  int? _selectedSumberAnggaranId;
  int? _selectedPemberiAnggaranId;
  String? _selectedSkema;
  String? _selectedJadwal;
  String? _selectedSumberAnggaran;
  String? _selectedPemberiAnggaran;

  List<MasterSkema> _masterSkemaList = [];
  List<MasterJadwal> _masterJadwalList = [];
  List<MasterSumberAnggaran> _masterSumberAnggaranList = [];
  List<MasterPemberiAnggaran> _masterPemberiAnggaranList = [];
  bool _isLoadingSkema = false;
  bool _isLoadingJadwal = false;
  bool _isLoadingSumberAnggaran = false;
  bool _isLoadingPemberiAnggaran = false;

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
  int? _selectedPendidikanId;
  List<MasterPendidikan> _listPendidikan = [];
  bool _isLoadingPendidikan = false;
  final TextEditingController _namaSekolahController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();

  // Step 3: Profil Peserta - Data Pekerjaan State
  int? _selectedPekerjaanId;
  List<MasterPekerjaan> _listPekerjaan = [];
  bool _isLoadingPekerjaan = false;
  final TextEditingController _namaPerusahaanController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _alamatPerusahaanController = TextEditingController();
  final TextEditingController _kodeposPerusahaanController = TextEditingController();
  final TextEditingController _telpPerusahaanController = TextEditingController();
  final TextEditingController _emailPerusahaanController = TextEditingController();

  // FR.APL.01 persyaratan upload — keyed by portofolio `key` (slug)
  final Map<String, bool> _uploadedDocs = {};
  final Map<String, String?> _uploadedFileNames = {};
  final Map<String, String?> _uploadedFilePaths = {};

  int? _activeUnitDetailIndex;
  final Map<String, bool?> _kukAssessments = {};
  final Map<String, String?> _kukEvidence = {};

  // Unit kompetensi from GET /api/master/skema/:id/unit-persyaratan
  List<Map<String, dynamic>> _cachedUnitKompetensi = [];

  // FR.APL.01 bagian 2 — unit + persyaratan from API (by id_skema)
  List<Map<String, String>> _persyaratanDasar = [];
  List<Map<String, String>> _persyaratanAdministratif = const [
    {'key': 'pasfoto', 'label': 'Pasfoto*'},
    {
      'key': 'identitas-pribadi-ktp-kartu-pelajar',
      'label': 'Identitas pribadi (KTP/Kartu Pelajar)*'
    },
  ];
  bool _isLoadingUnitPersyaratan = false;

  Future<void> _fetchSkemaUnitPersyaratan(int idSkema) async {
    setState(() {
      _isLoadingUnitPersyaratan = true;
      _cachedUnitKompetensi = [];
      _persyaratanDasar = [];
      _uploadedDocs.clear();
      _uploadedFileNames.clear();
      _uploadedFilePaths.clear();
    });
    try {
      final data = await ApiService.getSkemaUnitPersyaratan(idSkema);
      if (!mounted) return;
      if (data != null) {
        setState(() {
          _cachedUnitKompetensi =
              data.unitKompetensi.map((u) => u.toUnitMap()).toList();
          _persyaratanDasar = data.persyaratanDasar
              .map((p) => {
                    'key': p.key,
                    'label': p.label,
                  })
              .toList();
          if (data.persyaratanAdministratif.isNotEmpty) {
            _persyaratanAdministratif = data.persyaratanAdministratif
                .map((p) => {
                      'key': p.key,
                      'label': p.label,
                    })
                .toList();
          }
          if (_selectedSkema == null || _selectedSkema!.isEmpty) {
            _selectedSkema = data.namaSkema;
          }
          _isLoadingUnitPersyaratan = false;
        });
      } else {
        setState(() {
          _isLoadingUnitPersyaratan = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching skema unit-persyaratan: $e');
      if (mounted) {
        setState(() {
          _isLoadingUnitPersyaratan = false;
        });
      }
    }
  }

  void _clearUnitPersyaratan() {
    _cachedUnitKompetensi = [];
    _persyaratanDasar = [];
    _persyaratanAdministratif = const [
      {'key': 'pasfoto', 'label': 'Pasfoto*'},
      {
        'key': 'identitas-pribadi-ktp-kartu-pelajar',
        'label': 'Identitas pribadi (KTP/Kartu Pelajar)*'
      },
    ];
    _uploadedDocs.clear();
    _uploadedFileNames.clear();
    _uploadedFilePaths.clear();
  }

  void _onPersyaratanUpload(
    String key,
    String label,
    bool isUploaded,
    String? fileName,
    String? filePath,
  ) {
    setState(() {
      _uploadedDocs[key] = isUploaded;
      _uploadedFileNames[key] = fileName;
      _uploadedFilePaths[key] = filePath;
    });
  }

  @override
  void dispose() {
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
  Future<void> _nextStep() async {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final skemaId = _selectedSkemaId ?? 1;
        final jadwalId = _selectedJadwalId;

        // 1. Register certification (FR.APL.01 data pribadi + anggaran)
        final regRes = await AsesiService.daftarSertifikasi(
          skemaId: skemaId,
          jadwalId: jadwalId,
          dataPribadi: _buildDataPribadiPayload(),
        );

        if (regRes == null) {
          throw Exception('Gagal melakukan pendaftaran sertifikasi.');
        }

        final sertifikasiId = regRes['sertifikasi_id'] ?? regRes['id'];
        if (sertifikasiId == null) {
          throw Exception('ID Sertifikasi tidak valid.');
        }

        // 2. Upload persyaratan (key = slug from API, path = local file)
        for (final entry in _uploadedFilePaths.entries) {
          final docKey = entry.key;
          final filePath = entry.value;
          if (filePath != null &&
              filePath.isNotEmpty &&
              !filePath.startsWith('http')) {
            await AsesiService.uploadPortofolio(
              sertifikasiId is int
                  ? sertifikasiId
                  : int.parse(sertifikasiId.toString()),
              docKey,
              filePath,
            );
          }
        }

        // 3. Submit Pra-Asesmen
        final List<Map<String, dynamic>> evaluasi = [];
        _kukAssessments.forEach((key, isKompeten) {
          evaluasi.add({
            'id_elemen': key.hashCode.abs() % 10000,
            'nilai': isKompeten == true ? 'K' : 'KB',
          });
        });

        // Fallback if empty evaluation
        if (evaluasi.isEmpty) {
          evaluasi.add({'id_elemen': 1, 'nilai': 'K'});
        }

        final submitRes = await AsesiService.submitPraAsesmen(skemaId, evaluasi);
        if (!submitRes) {
          throw Exception('Gagal submit evaluasi pra-asesmen.');
        }

        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        debugPrint('Error during submission flow: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
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
    return CustomAppBar(
      title: _appBarTitle,
      onBack: _previousStep,
    );
  }

  Widget _buildCurrentFormStep() {
    switch (_currentStep) {
      case 0:
        return DataPengajuanForm(
          selectedSkema: _selectedSkemaId,
          selectedJadwal: _selectedJadwalId,
          selectedSumberAnggaran: _selectedSumberAnggaranId,
          selectedPemberiAnggaran: _selectedPemberiAnggaranId,
          listSkema: _masterSkemaList,
          listJadwal: _masterJadwalList,
          listSumberAnggaran: _masterSumberAnggaranList,
          listPemberiAnggaran: _masterPemberiAnggaranList,
          isLoadingSkema: _isLoadingSkema,
          isLoadingJadwal: _isLoadingJadwal,
          isLoadingSumberAnggaran: _isLoadingSumberAnggaran,
          isLoadingPemberiAnggaran: _isLoadingPemberiAnggaran,
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
                _clearUnitPersyaratan();
              } else {
                _selectedSkema = null;
                _clearUnitPersyaratan();
              }
            });
            if (val != null) {
              _fetchMasterJadwal(val);
              _fetchSkemaUnitPersyaratan(val);
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
          onSumberAnggaranChanged: (val) {
            setState(() {
              _selectedSumberAnggaranId = val;
              _selectedPemberiAnggaranId = null;
              _selectedPemberiAnggaran = null;
              _masterPemberiAnggaranList = [];
              if (val != null) {
                try {
                  final selected = _masterSumberAnggaranList.firstWhere((item) => item.id == val);
                  _selectedSumberAnggaran = selected.jenisAnggaran;
                } catch (_) {
                  _selectedSumberAnggaran = null;
                }
              } else {
                _selectedSumberAnggaran = null;
              }
            });
            if (val != null) {
              _fetchMasterPemberiAnggaran(val);
            }
          },
          onPemberiAnggaranChanged: (val) {
            setState(() {
              _selectedPemberiAnggaranId = val;
              if (val != null) {
                try {
                  final selected =
                      _masterPemberiAnggaranList.firstWhere((item) => item.id == val);
                  _selectedPemberiAnggaran = selected.instansiPemberiAnggaran;
                } catch (_) {
                  _selectedPemberiAnggaran = null;
                }
              } else {
                _selectedPemberiAnggaran = null;
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
          selectedPendidikanId: _selectedPendidikanId,
          namaSekolahController: _namaSekolahController,
          jurusanController: _jurusanController,
          listProvinsi: _listProvinsi,
          listKabupaten: _listKabupaten,
          listKecamatan: _listKecamatan,
          listPendidikan: _listPendidikan,
          isLoadingProvinsi: _isLoadingProvinsi,
          isLoadingKabupaten: _isLoadingKabupaten,
          isLoadingKecamatan: _isLoadingKecamatan,
          isLoadingPendidikan: _isLoadingPendidikan,
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
              _selectedPendidikanId = val;
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
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              });
            }
          },
        );
      case 2:
        return DataPekerjaanForm(
          selectedPekerjaanId: _selectedPekerjaanId,
          listPekerjaan: _listPekerjaan,
          isLoadingPekerjaan: _isLoadingPekerjaan,
          namaPerusahaanController: _namaPerusahaanController,
          jabatanController: _jabatanController,
          alamatPerusahaanController: _alamatPerusahaanController,
          kodeposPerusahaanController: _kodeposPerusahaanController,
          telpPerusahaanController: _telpPerusahaanController,
          emailPerusahaanController: _emailPerusahaanController,
          onPekerjaanChanged: (val) {
            setState(() {
              _selectedPekerjaanId = val;
            });
          },
        );
      case 3:
        return DokumenPersyaratanForm(
          selectedSkema: _selectedSkema ?? 'Pilih skema dulu',
          unitKompetensi: _cachedUnitKompetensi,
          persyaratanDasar: _persyaratanDasar,
          persyaratanAdministratif: _persyaratanAdministratif,
          isLoading: _isLoadingUnitPersyaratan,
          uploadedDocs: _uploadedDocs,
          uploadedFileNames: _uploadedFileNames,
          onUploadChanged: _onPersyaratanUpload,
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
                    onPressed: _isSubmitting ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
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
