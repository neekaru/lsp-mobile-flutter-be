import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/rangkuman_utama.dart';
import '../../widgets/rangkuman_asesi.dart';
import '../../widgets/rangkuman_asesor.dart';
import '../../widgets/tren_asesmen_chart.dart';
// import '../../widgets/jadwal_asesmen.dart';
import '../../widgets/notification_bell.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../services/auth_repository.dart';
import '../../widgets/mulai_sertifikasi_card.dart';
import '../../models/berita_model.dart';
import '../../widgets/berita_terkini_section.dart';
import '../auth/login_screen.dart';
import '../../widgets/public_sertifikat_card.dart';
import '../../widgets/tentang_kami_section.dart';
import '../../widgets/admin_bantuan_pengumuman.dart';
import 'ringkasan_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToJadwal;

  const DashboardScreen({super.key, this.onNavigateToJadwal});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _initTimer;

  // State untuk menyimpan data dari API
  DashboardSummary? _summaryData;
  AsesiDashboardSummary? _asesiSummaryData;
  AsesorDashboardData? _asesorDashboardData;
  List<MonthlyAssessment>? _chartData;
  // ignore: unused_field
  List<JadwalBaru>? _jadwalData;
  List<BeritaItem>? _beritaData;

  @override
  void initState() {
    super.initState();
    // Delay 300ms to let session validation complete first
    _initTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_isDisposed && mounted) {
        _loadAllData();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _initTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (_isDisposed || !mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthRepository.currentUserInstance;
      final bool isAsesi = user?.role == 'asesi';
      final bool isAsesor = user?.role == 'asesor';

      if (isAsesi) {
        // Panggil API yang dibutuhkan asesi secara parallel (termasuk berita, chart graf, dan jadwal baru)
        final results = await Future.wait([
          ApiService.getAsesiSummary(),
          ApiService.getBerita(page: 1, size: 5),
          ApiService.getAssessmentGraph(),
          ApiService.getJadwalBaru(),
        ]);

        if (_isDisposed || !mounted) return;
        setState(() {
          _asesiSummaryData = results[0] as AsesiDashboardSummary;
          _beritaData = results[1] as List<BeritaItem>;
          _chartData = results[2] as List<MonthlyAssessment>;
          _jadwalData = results[3] as List<JadwalBaru>;
          _isLoading = false;
        });
      } else if (isAsesor) {
        // Fetch Asesor Dashboard API data
        final data = await ApiService.getAsesorDashboard();
        if (_isDisposed || !mounted) return;
        setState(() {
          _asesorDashboardData = data;
          _isLoading = false;
        });
      } else {
        // Admin / other roles: admin summary APIs only.
        // Do NOT call /api/asesor/dashboard (role=asesor → 403 for admin).
        final results = await Future.wait([
          ApiService.getSummary(),
          ApiService.getBerita(page: 1, size: 5),
          ApiService.getAssessmentGraph(),
          ApiService.getJadwalBaru(),
        ]);

        if (_isDisposed || !mounted) return;
        setState(() {
          _summaryData = results[0] as DashboardSummary;
          _beritaData = results[1] as List<BeritaItem>;
          _chartData = results[2] as List<MonthlyAssessment>;
          _jadwalData = results[3] as List<JadwalBaru>;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Log error untuk debugging
      debugPrint('Error loading dashboard data: $e');
      if (_isDisposed || !mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ignore: unused_element
  Future<void> _refreshJadwalData() async {
    try {
      final jadwalData = await ApiService.getJadwalBaru();
      if (!_isDisposed && mounted) {
        setState(() {
          _jadwalData = jadwalData;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing jadwal data: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await _loadAllData();

    if (!_isDisposed && mounted) {
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
    final user = AuthRepository.currentUserInstance;
    final bool isAsesi = user?.role == 'asesi';
    final bool isAsesor = user?.role == 'asesor';
    final bool isGuest = user == null;

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
                          if (isAsesi || isAsesor) ...[
                            // Foto Profil
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  width: 2,
                                ),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const ClipOval(
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 32,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Hallo, Nama User
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAsesor ? 'Hallo' : 'Hallo,',
                                    style: const TextStyle(
                                      color: Color(
                                        0xE6FFFFFF,
                                      ), // white with 0.9 opacity
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.name ??
                                        (isAsesor
                                            ? 'Muhammad Hanafi'
                                            : 'Asesi'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isAsesor) ...[
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Selamat Datang Asessor',
                                      style: TextStyle(
                                        color: Color(0xE6FFFFFF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ] else if (isGuest) ...[
                            // Guest Header (original style + Masuk button)
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
                            const SizedBox(width: 8),
                            // "Masuk" Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ] else ...[
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
                          ],
                          if (!isGuest) ...[
                            const SizedBox(width: 8),
                            const NotificationBell(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Rangkuman Utama Card Container (Imported widget)
                Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight + (isAsesor ? 110 : 90),
                    left: 16,
                    right: 16,
                    bottom: 12, // Set to 12
                  ),
                  child: isGuest
                      ? const PublicSertifikatCard()
                      : (isAsesi
                            ? RangkumanAsesi(
                                data: _asesiSummaryData,
                                isLoading: _isLoading,
                              )
                            : (isAsesor
                                  ? RangkumanAsesor(
                                      isLoading: _isLoading,
                                      onNavigateToJadwal:
                                          widget.onNavigateToJadwal,
                                      data: _asesorDashboardData,
                                    )
                                  : RangkumanUtama(
                                      data: _summaryData,
                                      isLoading: _isLoading,
                                    ))),
                ),
              ],
            ),

            if (isAsesi && _asesiSummaryData?.hasAlert == true)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF3CD), Color(0xFFFFE8A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFE082),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB300),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _asesiSummaryData!.alertTitle,
                              style: const TextStyle(
                                color: Color(0xFF856404),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _asesiSummaryData!.alertSubtitle,
                              style: const TextStyle(
                                color: Color(0xFF856404),
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 1.5. Mulai Skema Sertifikasi Section - Hanya untuk Guest/Publik (sembunyi untuk asesi/admin/asesor)
            if (isGuest)
              const Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 4.0,
                  bottom: 8.0,
                ),
                child: MulaiSertifikasiCard(),
              ),

            // 1.6. Berita Terkini Section (2 boxes horizontally under Mulai Skema Sertifikasi) - Tampil di semua role kecuali asesor
            if (!isAsesor)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: BeritaTerkiniSection(
                  data: _beritaData,
                  isLoading: _isLoading,
                ),
              ),

            // Ringkasan Section (like Asesor) - Only for Admin
            if (user?.role == 'admin')
              _buildAdminRingkasanSection(),

            // 2. Tren Asesmen Bulanan Section (Imported chart card widget) - Tampil di semua role kecuali asesor
            if (!isAsesor)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: TrenAsesmenChart(
                  data: _chartData,
                  isLoading: _isLoading,
                ),
              ),

            // 2.5. Tentang Kami Section - Hanya untuk Guest (Public Landing Page)
            if (isGuest) const TentangKamiSection(),

            // 3. Bantuan & Informasi serta Pengumuman Baru Section - Tampil untuk semua role terautentikasi (Admin, Asesi, Asesor)
            if (!isGuest)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
                child: AdminBantuanPengumuman(
                  showBantuan: user.role != 'admin',
                ),
              )
            else
              const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminRingkasanSection() {
    final approveJadwalCount = _summaryData?.jadwalBelumTerkonfirmasi ?? 0;
    final laporanCount = _summaryData?.suratTugasMenungguPengiriman ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminRingkasanScreen(
                        summaryData: _summaryData,
                        onNavigateToJadwal: widget.onNavigateToJadwal,
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRingkasanItem(
            icon: Icons.calendar_today_rounded,
            title: 'Approve Jadwal',
            subtitle: '$approveJadwalCount Jadwal menunggu...',
            onTap: () {
              if (widget.onNavigateToJadwal != null) {
                widget.onNavigateToJadwal!();
              }
            },
          ),
          const SizedBox(height: 8),
          _buildRingkasanItem(
            icon: Icons.assignment_rounded,
            title: 'Laporan',
            subtitle: '$laporanCount Laporan menunggu...',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminRingkasanScreen(
                    summaryData: _summaryData,
                    onNavigateToJadwal: widget.onNavigateToJadwal,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
