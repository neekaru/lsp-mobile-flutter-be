import 'package:flutter/material.dart';
import '../widgets/rangkuman_utama.dart';
import '../widgets/tren_asesmen_chart.dart';
import '../widgets/jadwal_asesmen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulasi fetch data dari API
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    // Tampilkan feedback ke user
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
                  padding: EdgeInsets.fromLTRB(20, statusBarHeight + 20, 20, 20),
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
                                color: const Color(0x66FFFFFF), // white with 0.4 opacity
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
                                    'LSP Monitoring sertifikasi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                SizedBox(height: 2),
                                Text(
                                  'Monitoring Sertifikasi Nasional',
                                  style: TextStyle(
                                    color: Color(0xE6FFFFFF), // white with 0.9 opacity
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Notification Bell Icon
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
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
                  child: const RangkumanUtama(),
                ),
              ],
            ),

            // 2. Tren Asesmen Bulanan Section (Imported chart card widget)
            const Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 4.0, // 12 (bottom of previous) + 4 (top of this) = 16px gap
                bottom: 8.0, // Set to 8
              ),
              child: TrenAsesmenChart(),
            ),

            // 3. Jadwal Asesmen Mendekati Akhir Section (Imported list widget)
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0), // 8 (bottom of previous) + 8 (top of this) = 16px gap
              child: JadwalAsesmen(),
            ),
          ],
        ),
      ),
    );
  }
}
