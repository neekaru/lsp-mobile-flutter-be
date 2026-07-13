import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/auth_repository.dart';

class ParticipantItem {
  final String name;
  final String nim;
  bool isPresent;
  bool isCompetent; // For Step 3

  ParticipantItem({
    required this.name,
    required this.nim,
    this.isPresent = true,
    this.isCompetent = true,
  });
}

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
  final String _uploadedFileName = 'Surat tugas.pdf';
  final _linkController = TextEditingController();

  final List<String> _skemaOptions = [
    'Desaign UI/Ux',
    'Junior Web Programmer',
    'Digital Marketing',
    'Network Administrator',
    'Junior Graphic Designer',
  ];

  // Step 2 State
  String _searchQuery = '';
  final List<ParticipantItem> _participants = [
    ParticipantItem(name: 'Ayu Putri Sri', nim: '0897556789', isPresent: true),
    ParticipantItem(name: 'Arya Pamungkas', nim: '125809872315', isPresent: true),
    ParticipantItem(name: 'Bima Sakti', nim: '09890980007', isPresent: true),
    ParticipantItem(name: 'Bayu Nugrahan', nim: '09769990862', isPresent: false),
    ParticipantItem(name: 'Setiabudi', nim: '90876898777', isPresent: false),
    ParticipantItem(name: 'Stya Dipa', nim: '0000889768', isPresent: true),
    ParticipantItem(name: 'Ayu Wandira', nim: '0897654321', isPresent: true),
    ParticipantItem(name: 'Catur Putra', nim: '0812345678', isPresent: true),
    ParticipantItem(name: 'Dodi Alfian', nim: '0823456789', isPresent: true),
    ParticipantItem(name: 'Eka Safitri', nim: '0834567890', isPresent: true),
  ];

  // Step 4 State
  final _notesController = TextEditingController(
    text: 'Asesi telah mengumpulkan seluruh tugas implementasi UI Design dengan lengkap. Melalui sesi wawancara, Asesi mampu membuktikan keaslian karya secara mandiri, menjelaskan alur user flow dengan logis, serta menggunakan design system yang terkini. Seluruh kriteria unjuk kerja telah terpenuhi dengan cukup.',
  );
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_formKeyStep1.currentState?.validate() ?? false) {
        if (_selectedDate.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan pilih Tanggal Pelaksanaan terlebih dahulu'),
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

  void _submitLaporan() {
    // Generate mock result details back to previous screen
    final newReport = {
      'code': 'LAP-2026-00${DateTime.now().millisecond % 100}',
      'status': 'Terkonfirmasi',
      'asesor': _nameController.text,
      'skema': _selectedSkema,
      'tanggal': _selectedDate,
    };

    // Return to the list screen with success data
    Navigator.pop(context, newReport);
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
                    'Pilih Skema Sertifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._skemaOptions.map((skema) {
                    final isSelected = skema == _selectedSkema;
                    return ListTile(
                      title: Text(
                        skema,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF378CE7) : const Color(0xFF1E293B),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF378CE7))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedSkema = skema;
                        });
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;

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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
                  ),
                ),
              ],
            ),
          ),

          // Main Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _buildCurrentStepContent(),
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
                        backgroundColor: const Color(0xFFCBD5E1), // Gray button background
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _currentStep > 1 ? _previousStep : () => Navigator.pop(context),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                        backgroundColor: const Color(0xFF5B9FD8), // Blue button background
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _currentStep < 4 ? _nextStep : _submitLaporan,
                      child: Text(
                        _currentStep < 4 ? 'Selanjutnya' : 'Kirim Laporan',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  // ================= STEP 1: General Info =================
  Widget _buildStep1() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Lengkap
          const Text(
            'Nama Lengkap',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Masukan nama lengkap anda',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama lengkap tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Skema Sertifikasi
          const Text(
            'Skema Sertifikasi (TUK)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectSkema,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedSkema,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tanggal Pelaksanaan
          Row(
            children: const [
              Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                'Tanggal Pelaksanaan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  final monthNames = [
                    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                  ];
                  _selectedDate = '${picked.day} ${monthNames[picked.month - 1]} ${picked.year}';
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate.isEmpty ? 'Pilih tanggal' : _selectedDate,
                    style: TextStyle(
                      color: _selectedDate.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Unggah Surat Tugas
          const Text(
            'Unggah Surat Tugas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mengunggah File PDF (Simulasi)')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _uploadedFileName,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Surat tugas harus PDF minimal 2 mb.',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Link Dokumentasi
          const Text(
            'Link Dokumentasi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _linkController,
            decoration: InputDecoration(
              hintText: 'Unggah link dokumentasi',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bukti dokumentasi berupa link video/foto.',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================= STEP 2: Attendance =================
  Widget _buildStep2() {
    final filtered = _participants.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.nim.contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Asessi Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFDBFE), // Soft blue
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Asessi Skema $_selectedSkema',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_participants.length} Asessi',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Cari nama/NIM peserta',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Custom Attendance Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                color: const Color(0xFFDBEAFE), // Light blue header row background
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Nama Asessi',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'NIM',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Kehadiran',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Table Body Rows
              ...filtered.map((participant) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // Name Col
                          Expanded(
                            flex: 2,
                            child: Text(
                              participant.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // NIM Col
                          Expanded(
                            flex: 2,
                            child: Text(
                              participant.nim,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          // Attendance Switch Col
                          SizedBox(
                            width: 80,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _buildAttendanceSwitch(participant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Beautiful custom toggle switch matching the mockup screenshot
  Widget _buildAttendanceSwitch(ParticipantItem participant) {
    return GestureDetector(
      onTap: () {
        setState(() {
          participant.isPresent = !participant.isPresent;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        height: 28,
        decoration: BoxDecoration(
          color: participant.isPresent ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment:
              participant.isPresent ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            if (participant.isPresent) ...[
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Hadir',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Absen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= STEP 3: Assessment Decision =================
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Instruction Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Penilaian Asessi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tugas yang diberikan assessor dikerjakan dengan baik, Tingkat kehadiran tidak absen, dan asessi mengerjakan tugas secara mandiri.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Text(
                    '> ',
                    style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Kompeten [K]',
                    style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Text(
                    '> ',
                    style: TextStyle(color: Color(0xFFBE123C), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Tidak Kompeten [TK]',
                    style: TextStyle(color: Color(0xFFBE123C), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Bulk Selection Header Card (Mobile First style)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PILIHAN MASSAL (BULK ACTION)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _allKSelected ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                          ),
                          backgroundColor: _allKSelected ? const Color(0xFFECFDF5) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: _allKSelected ? const Color(0xFF047857) : const Color(0xFF475569),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            _allKSelected = !_allKSelected;
                            _allTKSelected = false;
                            for (var p in _participants) {
                              p.isCompetent = _allKSelected;
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _allKSelected ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                              size: 16,
                              color: _allKSelected ? const Color(0xFF10B981) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Semua [K]',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _allTKSelected ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                          ),
                          backgroundColor: _allTKSelected ? const Color(0xFFFEF2F2) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: _allTKSelected ? const Color(0xFFB91C1C) : const Color(0xFF475569),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            _allTKSelected = !_allTKSelected;
                            _allKSelected = false;
                            for (var p in _participants) {
                              p.isCompetent = !_allTKSelected;
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _allTKSelected ? Icons.cancel_rounded : Icons.cancel_outlined,
                              size: 16,
                              color: _allTKSelected ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Semua [TK]',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Participant Mobile-First List Card
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _participants.length,
          itemBuilder: (context, index) {
            final participant = _participants[index];
            final firstLetter = participant.name.isNotEmpty ? participant.name[0].toUpperCase() : 'A';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // Left: Avatar + Name & NIM
                  Expanded(
                    flex: 11,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFF1F5F9),
                          child: Text(
                            firstLetter,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                participant.name,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'NIM: ${participant.nim}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right: Premium Mobile-First Selector Switch/Buttons
                  Expanded(
                    flex: 9,
                    child: Row(
                      children: [
                        // Pill for Kompeten [K]
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                participant.isCompetent = true;
                                // Recalculate bulk state if needed
                                _allKSelected = _participants.every((p) => p.isCompetent);
                                _allTKSelected = false;
                              });
                            },
                            child: Container(
                              height: 34,
                              decoration: BoxDecoration(
                                color: participant.isCompetent ? const Color(0xFFECFDF5) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: participant.isCompetent ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                                  width: participant.isCompetent ? 1.5 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '[K]',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: participant.isCompetent ? const Color(0xFF047857) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  if (participant.isCompetent) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 12),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Pill for Tidak Kompeten [TK]
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                participant.isCompetent = false;
                                // Recalculate bulk state if needed
                                _allTKSelected = _participants.every((p) => !p.isCompetent);
                                _allKSelected = false;
                              });
                            },
                            child: Container(
                              height: 34,
                              decoration: BoxDecoration(
                                color: !participant.isCompetent ? const Color(0xFFFEF2F2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: !participant.isCompetent ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                                  width: !participant.isCompetent ? 1.5 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '[TK]',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: !participant.isCompetent ? const Color(0xFFB91C1C) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  if (!participant.isCompetent) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 12),
                                  ],
                                ],
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
          },
        ),
      ],
    );
  }

  // ================= STEP 4: Review / Catatan & Lampiran =================
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan :',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 7,
          decoration: InputDecoration(
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1E293B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Lampiran Pendukung(Opsional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        
        // Add attachment button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDBEAFE),
            foregroundColor: const Color(0xFF1E40AF),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () {
            setState(() {
              if (_attachments.isEmpty) {
                _attachments.add('Bukti_Pendukung_1.pdf');
              } else {
                _attachments.add('Foto_Dokumentasi_${_attachments.length + 1}.png');
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lampiran berhasil ditambahkan')),
            );
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text(
            'Tambah Lampiran',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._attachments.asMap().entries.map((entry) {
            final idx = entry.key;
            final file = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        file.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
                        color: file.endsWith('.pdf') ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        file,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _attachments.removeAt(idx);
                      });
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
