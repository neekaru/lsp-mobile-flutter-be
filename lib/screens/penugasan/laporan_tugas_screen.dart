import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/asesor_service.dart';
import 'buat_laporan_screen.dart';
import 'detail_laporan_screen.dart';

class LaporanTugasScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const LaporanTugasScreen({super.key, this.onBackToHome});

  @override
  State<LaporanTugasScreen> createState() => _LaporanTugasScreenState();
}

class _LaporanTugasScreenState extends State<LaporanTugasScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await AsesorService.getLaporanList();
      if (mounted) {
        setState(() {
          _reports = list;
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, String> _mapToReportData(Map<String, dynamic> item) {
    return {
      'id': item['id']?.toString() ?? '',
      'code': item['code']?.toString() ?? '',
      'status': item['status']?.toString() ?? 'Draf',
      'asesor': item['asesor']?.toString() ?? '',
      'skema': item['skema']?.toString() ?? '',
      'tanggal': item['tanggal']?.toString() ?? '',
    };
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
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9FD8)),
            ),
          // List of Laporan Cards
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchReports,
              color: const Color(0xFF5B9FD8),
              child: _reports.isEmpty && !_isLoading
                  ? const Center(
                      child: Text(
                        'Belum ada laporan tugas.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        final item = _reports[index];
                        final mapped = _mapToReportData(item);
                        final statusText = mapped['status'] ?? 'Draf';
                        final isConfirmed = statusText == 'Terkonfirmasi';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailLaporanScreen(reportData: mapped),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
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
                                      mapped['code']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isConfirmed
                                            ? const Color(0xFFDCFCE7) // Soft green badge
                                            : const Color(0xFFFEF9C3), // Soft yellow badge for Draf/Proses
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isConfirmed
                                              ? const Color(0xFF16A34A) // Deep green
                                              : const Color(0xFFCA8A04), // Deep yellow
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
                                          const Row(
                                            children: [
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
                                            mapped['asesor']!,
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
                                          const Row(
                                            children: [
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
                                            mapped['skema']!,
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
                                          const Row(
                                            children: [
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
                                            mapped['tanggal']!,
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
                  await navigator.push(
                    MaterialPageRoute(
                      builder: (context) => const BuatLaporanScreen(),
                    ),
                  );
                  _fetchReports();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
