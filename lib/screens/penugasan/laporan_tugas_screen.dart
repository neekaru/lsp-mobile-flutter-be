import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'buat_laporan_screen.dart';
import 'detail_laporan_screen.dart';

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
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailLaporanScreen(reportData: item),
                      ),
                    );
                  },
                  child: Container(
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
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final result = await navigator.push<Map<String, String>>(
                    MaterialPageRoute(
                      builder: (context) => const BuatLaporanScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _reports.insert(0, result);
                    });
                    if (mounted) {
                      navigator.push(
                        MaterialPageRoute(
                          builder: (context) => DetailLaporanScreen(reportData: result),
                        ),
                      );
                    }
                  }
                },
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
