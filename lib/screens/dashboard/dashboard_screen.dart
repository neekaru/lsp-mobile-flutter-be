import 'package:flutter/material.dart';
import '../../widgets/rangkuman_utama.dart';
import '../../widgets/tren_asesmen_chart.dart';
import '../../widgets/jadwal_asesmen.dart';
import '../../widgets/notification_bell.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../services/auth_repository.dart';
import '../../widgets/mulai_sertifikasi_card.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToJadwal;

  const DashboardScreen({super.key, this.onNavigateToJadwal});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  // State untuk menyimpan data dari API
  DashboardSummary? _summaryData;
  List<MonthlyAssessment>? _chartData;
  List<JadwalBaru>? _jadwalData;

  @override
  void initState() {
    super.initState();
    // Delay 300ms to let session validation complete first
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _loadAllData();
      }
    });
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil semua API secara parallel
      final results = await Future.wait([
        ApiService.getSummary(),
        ApiService.getAssessmentGraph(), // Changed to new endpoint
        ApiService.getJadwalBaru(),
      ]);

      setState(() {
        _summaryData = results[0] as DashboardSummary;
        _chartData = results[1] as List<MonthlyAssessment>;
        _jadwalData = results[2] as List<JadwalBaru>;
        _isLoading = false;
      });
    } catch (e) {
      // Log error untuk debugging
      debugPrint('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadAllData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 1. Top Section: Header & Rangkuman Utama Card Overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Sky Blue Header Background
                Container(
                  width: double.infinity,
                  height: 260 + statusBarHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4FA8E8),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    statusBarHeight + 20,
                    20,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Custom Logo
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(
                                  0x66FFFFFF,
                                ), // white with 0.4 opacity
                                width: 2,
                              ),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Title Texts
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LSP Teknologi Digital',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Dashboard Sertifikasi',
                                  style: TextStyle(
                                    color: Color(
                                      0xE6FFFFFF,
                                    ), // white with 0.9 opacity
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Notification Bell Icon
                          const NotificationBell(),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rangkuman Utama Card Container (Imported widget)
                Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 90,
                    left: 16,
                    right: 16,
                    bottom: 12, // Set to 12
                  ),
                  child: RangkumanUtama(
                    data: _summaryData,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),

            // 1.5. Mulai Skema Sertifikasi Section
            const Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 4.0,
                bottom: 8.0,
              ),
              child: MulaiSertifikasiCard(),
            ),

            // 2. Tren Asesmen Bulanan Section (Imported chart card widget)
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: TrenAsesmenChart(data: _chartData, isLoading: _isLoading),
            ),

            // 3. Jadwal Asesmen Mendekati Baru Section (Imported list widget) - Hanya untuk Admin
            if (AuthRepository.currentUserInstance?.role == 'admin')
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16.0,
                  8.0,
                  16.0,
                  32.0,
                ), // 8 (bottom of previous) + 8 (top of this) = 16px gap
                child: JadwalAsesmen(
                  data: _jadwalData,
                  isLoading: _isLoading,
                  onTapLihatSemua: widget.onNavigateToJadwal,
                ),
              )
            else
              const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
