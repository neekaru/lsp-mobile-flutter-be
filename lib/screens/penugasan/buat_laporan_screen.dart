import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/api_client.dart';
import '../../services/jadwal/jadwal_service.dart';
import '../../utils/api_routes.dart';
import '../../core/navigation/main_navigator.dart' show mainNavigatorKey;

import '../../widgets/penugasan/feedback_dialog.dart';
import '../../widgets/penugasan/participant_widgets.dart';
import '../../widgets/penugasan/file_upload_sheet.dart';
import '../../widgets/penugasan/buat_laporan_steps.dart';

class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  int _currentStep = 1;

  // Step 1 Controllers & State
  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedSkema = 'Desaign UI/Ux';
  String _selectedDate = '';
  String? _uploadedFileName;
  String? _uploadedFileUrl;
  final _linkController = TextEditingController();

  Future<String?> _uploadFileToApi(String filePath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF54A0EB)),
                ),
                SizedBox(height: 16),
                Text(
                  'Mengunggah file...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await AsesorService.uploadLampiran(filePath);
    if (!mounted) return null;
    Navigator.of(context, rootNavigator: true).pop();

    if (result != null) {
      final url = result['file_url']?.toString();
      showFeedbackDialog(context, isSuccess: true, message: 'Upload File Berhasil');
      return (url != null && url.isNotEmpty) ? url : null;
    }

    showFeedbackDialog(context,
      isSuccess: false,
      message: 'Ada Kesalahan, Periksa Kembali Dokumen Anda',
    );
    return null;
  }

  Future<void> _pickSuratTugas() async {
    final result = await showFileUploadSheet(
      context,
      title: 'Upload Surat Tugas',
      descriptionLabel: 'Berkas Surat Tugas',
      descriptionText:
          'Upload file PDF Surat Tugas resmi dari lembaga Anda.',
      allowedExtensions: const ['pdf'],
      formatInfo: 'Format : PDF. Maksimal 5MB',
      initialFileName: _uploadedFileName,
    );
    if (result == null || !mounted) return;
    final url = await _uploadFileToApi(result.path);
    if (!mounted || url == null) return;
    setState(() {
      _uploadedFileName = result.name;
      _uploadedFileUrl = url;
    });
  }

  Future<void> _pickLampiran() async {
    final result = await showFileUploadSheet(
      context,
      title: 'Upload Lampiran Pendukung',
      descriptionLabel: 'Dokumen Lampiran',
      descriptionText:
          'Upload berkas atau dokumen pendukung tambahan (opsional).',
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      formatInfo: 'Format : PDF, JPG, PNG. Maksimal 5MB',
    );
    if (result == null || !mounted) return;
    final url = await _uploadFileToApi(result.path);
    if (!mounted || url == null) return;
    setState(() {
      _attachments.add(url);
    });
  }

  // API State fields
  List<Map<String, dynamic>> _schedulesList = [];
  Map<String, dynamic>? _selectedSchedule;
  List<Map<String, dynamic>> _skemaTukList = [];
  Map<String, dynamic>? _selectedSkemaTuk;
  final bool _isUploadingAttachment = false;
  // ignore: unused_field
  bool _isLoadingSchedules = false;
  // ignore: unused_field
  bool _isLoadingDropdown = false;
  // ignore: unused_field
  bool _isSubmitting = false;

  // Step 2 State
  Timer? _searchDebounce;
  final _searchController = TextEditingController();
  final List<ParticipantItem> _participants = [];

  // Step 4 State
  final _notesController = TextEditingController();
  final List<String> _attachments = [];

  // Step 3 State
  bool _allKSelected = false;
  bool _allTKSelected = false;

  @override
  void initState() {
    super.initState();
    // Default name to current user's name
    final currentUser = AuthRepository.currentUserInstance;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
    }
    _loadSchedules();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    if (!mounted) return;
    setState(() {
      _isLoadingSchedules = true;
    });
    try {
      final response = await ApiClient.dio.get(
        '${ApiRoutes.asesorJadwal}?status_jadwal=1,4',
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data['data'] ?? [];
        _schedulesList = list
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading schedules: $e');
    }

    // Fallback if empty or fails
    if (_schedulesList.isEmpty) {
      _schedulesList = [
        {
          'id': 11152,
          'nama_jadwal': 'Sertifikasi Junior Web Developer',
          'tanggal': '2026-07-20',
          'tuk': 'SMK Media Informatika',
        },
        {
          'id': 11153,
          'nama_jadwal': 'Sertifikasi Junior Graphic Designer',
          'tanggal': '2026-07-22',
          'tuk': 'Politeknik Sampit',
        },
      ];
    }

    if (!mounted) return;
    setState(() {
      _selectedSchedule = _schedulesList.first;
      _selectedSkema = _selectedSchedule?['nama_jadwal'] ?? '';
      _selectedDate = _selectedSchedule?['tanggal'] ?? '';
      _isLoadingSchedules = false;
    });

    if (_selectedSchedule != null) {
      _loadParticipantsForSchedule(_selectedSchedule!['id']);
    }
  }

  Future<void> _loadDropdownData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingDropdown = true;
    });
    try {
      final list = await AsesorService.getSkemaTukDropdown();
      if (!mounted) return;
      setState(() {
        _skemaTukList = list;
        if (_skemaTukList.isNotEmpty) {
          _selectedSkemaTuk = _skemaTukList.first;
        }
      });
    } catch (e) {
      debugPrint('Error loading skema-tuk dropdown: $e');
    }
    if (!mounted) return;
    setState(() {
      _isLoadingDropdown = false;
    });
  }

  Future<void> _loadParticipantsForSchedule(int scheduleId) async {
    try {
      final res = await JadwalService.getAsesiList(scheduleId);
      if (res.data.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _participants.clear();
          for (var asesi in res.data) {
            _participants.add(
              ParticipantItem(
                name: asesi.namaLengkap,
                nim: asesi.id.toString(),
                isPresent: asesi.hasilRekomendasi != '-',
                isCompetent: asesi.hasilRekomendasi != 'BK',
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading participants: $e');
    }

    // Keep empty when API returns no asesi — never inject mock names
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_formKeyStep1.currentState?.validate() ?? false) {
        if (_selectedDate.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Silakan pilih Tanggal Pelaksanaan terlebih dahulu',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
        setState(() {
          _currentStep = 2;
        });
      }
    } else if (_currentStep == 2) {
      setState(() {
        _currentStep = 3;
      });
    } else if (_currentStep == 3) {
      setState(() {
        _currentStep = 4;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitLaporan() async {
    if (_uploadedFileUrl == null || _uploadedFileUrl!.isEmpty) {
      showFeedbackDialog(context,
        isSuccess: false,
        message: 'Ada Kesalahan, Periksa Kembali Dokumen Anda',
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = true;
    });

    final List<Map<String, dynamic>> participantList = _participants
        .map(
          (p) => {
            'nim': p.nim,
            'kehadiran': p.isPresent ? 'Hadir' : 'Absen',
            'is_kompeten': p.isCompetent,
          },
        )
        .toList();

    final response = await AsesorService.submitLaporan(
      jadwalId: _selectedSchedule?['id'] ?? 0,
      namaAsesor: _nameController.text,
      skemaId: _selectedSkemaTuk?['id'] ?? 0,
      tanggalPelaksanaan: _selectedDate,
      suratTugasUrl: _uploadedFileUrl ?? '',
      linkDokumentasi: _linkController.text,
      catatan: _notesController.text,
      daftarPeserta: participantList,
      lampiranPendukung: _attachments,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (response != null) {
      showFeedbackDialog(context,
        isSuccess: true,
        message: 'Laporan Tugas Berhasil Dibuat',
        onConfirm: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          mainNavigatorKey.currentState?.setTab(0);
        },
      );
    } else {
      showFeedbackDialog(context,
        isSuccess: false,
        message: 'Ada Kesalahan, Periksa Kembali Dokumen Anda',
      );
    }
  }

  void _selectSkema() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Jadwal Penugasan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_schedulesList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Tidak ada jadwal tersedia')),
                    )
                  else
                    ..._schedulesList.map((schedule) {
                      final isSelected =
                          schedule['id'] == _selectedSchedule?['id'];
                      return ListTile(
                        title: Text(
                          schedule['nama_jadwal'] ?? '',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF378CE7)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Text(
                          'TUK: ${schedule['tuk'] ?? ""} - ${schedule['tanggal'] ?? ""}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF378CE7),
                              )
                            : null,
                        onTap: () {
                          if (!mounted) return;
                          setState(() {
                            _selectedSchedule = schedule;
                            _selectedSkema = schedule['nama_jadwal'] ?? '';
                            _selectedDate = schedule['tanggal'] ?? '';
                          });
                          _loadParticipantsForSchedule(schedule['id']);
                          Navigator.pop(context);
                        },
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Buat Laporan Baru',
            onBack: () {
              if (_currentStep > 1) {
                _previousStep();
              } else {
                Navigator.pop(context);
              }
            },
          ),

          // Progress Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Text(
                      '$_currentStep / 4',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _currentStep / 4.0,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF378CE7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: RepaintBoundary(child: _buildCurrentStepContent()),
            ),
          ),

          // Bottom Action Buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Kembali Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFCBD5E1,
                        ), // Gray button background
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _currentStep > 1
                          ? _previousStep
                          : () => Navigator.pop(context),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Selanjutnya / Simpan Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF5B9FD8,
                        ), // Blue button background
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _currentStep < 4 ? _nextStep : _submitLaporan,
                      child: Text(
                        _currentStep < 4 ? 'Selanjutnya' : 'Kirim Laporan',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return BuatLaporanStep1Form(
          formKey: _formKeyStep1,
          nameController: _nameController,
          linkController: _linkController,
          selectedSkema: _selectedSkema,
          selectedDate: _selectedDate,
          uploadedFileName: _uploadedFileName,
          onSelectSkema: _selectSkema,
          onPickSuratTugas: _pickSuratTugas,
          onDatePicked: (picked) {
            final monthNames = [
              'Januari',
              'Februari',
              'Maret',
              'April',
              'Mei',
              'Juni',
              'Juli',
              'Agustus',
              'September',
              'Oktober',
              'November',
              'Desember',
            ];
            setState(() {
              _selectedDate =
                  '${picked.day} ${monthNames[picked.month - 1]} ${picked.year}';
            });
          },
          onLinkChanged: (val) {
            setState(() {});
          },
        );
      case 2:
        return BuatLaporanStep2Form(
          participants: _participants,
          selectedSkema: _selectedSkema,
          searchController: _searchController,
          onSearchChanged: (val) {
            setState(() {});
          },
        );
      case 3:
        return BuatLaporanStep3Form(
          participants: _participants,
          allKSelected: _allKSelected,
          allTKSelected: _allTKSelected,
          onBulkK: () {
            setState(() {
              _allKSelected = !_allKSelected;
              _allTKSelected = false;
              for (var p in _participants) {
                p.isCompetent = _allKSelected;
              }
            });
          },
          onBulkTK: () {
            setState(() {
              _allTKSelected = !_allTKSelected;
              _allKSelected = false;
              for (var p in _participants) {
                p.isCompetent = !_allTKSelected;
              }
            });
          },
          onCompetenceChanged: (bool isCompetent) {
            final newAllK = _participants.every((p) => p.isCompetent);
            final newAllTK = _participants.every((p) => !p.isCompetent);
            if (newAllK != _allKSelected || newAllTK != _allTKSelected) {
              setState(() {
                _allKSelected = newAllK;
                _allTKSelected = newAllTK;
              });
            }
          },
        );
      case 4:
        return BuatLaporanStep4Form(
          notesController: _notesController,
          isUploadingAttachment: _isUploadingAttachment,
          attachments: _attachments,
          onPickLampiran: _pickLampiran,
          onRemoveAttachment: (idx) {
            setState(() {
              _attachments.removeAt(idx);
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
