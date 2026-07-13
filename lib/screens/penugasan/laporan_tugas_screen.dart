import 'package:flutter/material.dart';
import '../../services/auth_repository.dart';
import '../../widgets/custom_app_bar.dart';

class LaporanTugasScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const LaporanTugasScreen({super.key, this.onBackToHome});

  @override
  State<LaporanTugasScreen> createState() => _LaporanTugasScreenState();
}

class _LaporanTugasScreenState extends State<LaporanTugasScreen> {
  final List<Map<String, String>> _reports = [
    {
      'code': 'LAP-2026-001',
      'status': 'Terkonfirmasi',
      'asesor': 'Eko Setiabudi',
      'skema': 'Desaign UI/UX',
      'tanggal': '20 Juli 2026',
    },
    {
      'code': 'LAP-2026-002',
      'status': 'Terkonfirmasi',
      'asesor': 'Eko Setiabudi',
      'skema': 'Desaign UI/UX',
      'tanggal': '20 Juli 2026',
    },
    {
      'code': 'LAP-2026-003',
      'status': 'Terkonfirmasi',
      'asesor': 'Eko Setiabudi',
      'skema': 'Desaign UI/UX',
      'tanggal': '20 Juli 2026',
    },
    {
      'code': 'LAP-2026-004',
      'status': 'Terkonfirmasi',
      'asesor': 'Eko Setiabudi',
      'skema': 'Desaign UI/UX',
      'tanggal': '20 Juli 2026',
    },
    {
      'code': 'LAP-2026-005',
      'status': 'Terkonfirmasi',
      'asesor': 'Eko Setiabudi',
      'skema': 'Desaign UI/UX',
      'tanggal': '20 Juli 2026',
    },
  ];

  final List<String> _skemaOptions = [
    'Desaign UI/UX',
    'Junior Web Programmer',
    'Digital Marketing',
    'Network Administrator',
    'Junior Graphic Designer',
  ];

  void _showCreateReportSheet() {
    final currentUser = AuthRepository.currentUserInstance;
    final defaultAsesor = currentUser?.name ?? 'Eko Setiabudi';
    
    final key = GlobalKey<FormState>();
    final codeController = TextEditingController(text: 'LAP-2026-00${_reports.length + 1}');
    final asesorController = TextEditingController(text: defaultAsesor);
    String selectedSkema = _skemaOptions[0];
    DateTime selectedDate = DateTime.now();
    final dateController = TextEditingController(
      text: '${selectedDate.day} Juli 2026', // Matching user year format
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Buat Laporan Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Code
                    const Text(
                      'Kode Laporan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: codeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Asesor Name
                    const Text(
                      'Nama Asesor',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: asesorController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Nama Asesor tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),

                    // Skema dropdown
                    const Text(
                      'Skema Sertifikat',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSkema,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: _skemaOptions.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedSkema = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Assessment Date
                    const Text(
                      'Tanggal Asesmen',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: dateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                            // Format to: dd [Indonesian Month] yyyy
                            final monthNames = [
                              'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                              'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                            ];
                            dateController.text = '${picked.day} ${monthNames[picked.month - 1]} ${picked.year}';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B9FD8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (key.currentState?.validate() ?? false) {
                            setState(() {
                              _reports.insert(0, {
                                'code': codeController.text,
                                'status': 'Terkonfirmasi',
                                'asesor': asesorController.text,
                                'skema': selectedSkema,
                                'tanggal': dateController.text,
                              });
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Laporan baru berhasil dibuat!'),
                                backgroundColor: Color(0xFF16A34A),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Simpan Laporan',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
            title: 'Laporan Tugas',
            onBack: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else {
                Navigator.pop(context);
              }
            },
            rightWidget: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: Colors.black,
                size: 24,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilihan opsi ditekan (Simulasi)')),
                );
              },
            ),
          ),
          // List of Laporan Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final item = _reports[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA), // Soft light-gray container background
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['code']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7), // Soft green badge
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['status']!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A), // Deep green
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Horizontal Three Columns info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Col 1
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Nama Asesor',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['asesor']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Col 2
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Skema Sertifikat',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['skema']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Col 3
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tanggal Asesmen',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['tanggal']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9FD8), // Blue button color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _showCreateReportSheet,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Buat Laporan Baru',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
