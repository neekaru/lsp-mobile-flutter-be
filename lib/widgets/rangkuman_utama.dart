import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_models.dart';
import '../helpers/number_format_helper.dart';

class RangkumanUtama extends StatefulWidget {
  final DashboardSummary? data;
  final bool? isLoading;

  const RangkumanUtama({super.key, this.data, this.isLoading});

  @override
  State<RangkumanUtama> createState() => _RangkumanUtamaState();
}

class _RangkumanUtamaState extends State<RangkumanUtama> {
  late Future<DashboardSummary>? _summaryFuture;

  String get _currentDayMonth {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month - 1]}';
  }

  String get _todayDate {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    // Hanya fetch jika data tidak disediakan dari parent
    if (widget.data == null) {
      _summaryFuture = ApiService.getSummary();
    } else {
      _summaryFuture = null;
    }
  }

  @override
  void didUpdateWidget(RangkumanUtama oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update ketika data dari parent berubah
    if (widget.data != oldWidget.data) {
      setState(() {
        _summaryFuture = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan data dari parent jika ada
    if (widget.data != null) {
      return _buildContent(widget.data!, widget.isLoading ?? false);
    }

    // Fallback: Gunakan FutureBuilder jika standalone
    return FutureBuilder<DashboardSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data ?? DashboardSummary.fallback();
        return _buildContent(data, isLoading);
      },
    );
  }

  Widget _buildContent(DashboardSummary data, bool isLoading) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF559AD4), Color(0xFF2C6C9C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000), // black with 0.15 opacity
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Rangkuman Utama',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Dynamic Day/Month Dropdown Pill
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0x99FFFFFF), // white with 0.6 opacity
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentDayMonth,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Data diperbarui secara real-time - $_todayDate',
            style: const TextStyle(
              color: Color(0xB3FFFFFF), // white with 0.7 opacity
              fontSize: 12,
            ),
          ),

          // Current Month Warning Badge
          _buildWarningBadge(data),

          // 2x2 Grid of Summary Cards with premium modern rounded Material Icons
          _buildSummaryGrid(data, isLoading),
        ],
      ),
    );
  }

  Widget _buildWarningBadge(DashboardSummary data) {
    if (data.isCurrentMonth && data.note != null) {
      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x33FFA726), // Orange with opacity
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF9800), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFFFB74D), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                data.note!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSummaryGrid(DashboardSummary data, bool isLoading) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.32,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        SummaryCard(
          title: 'Jadwal Asesmen',
          value: isLoading
              ? '...'
              : NumberFormatHelper.formatWithDots(data.totalAsesmen),
          trend: data.trendAsesmen,
          subtitle: 'Total Terjadwal',
          comparison: data.jadwalAsesmen,
          icon: Icons.assignment_rounded,
          iconColor: const Color(0xFF5C51DC),
          iconBgColor: const Color(0xFFEEECFD),
        ),
        SummaryCard(
          title: 'Asesi Aktif',
          value: isLoading
              ? '...'
              : NumberFormatHelper.formatWithDots(data.totalPemegangSertifikat),
          trend: data.trendPemegangSertifikat,
          subtitle: 'Asesi Kompeten',
          comparison: data.sertifikatPerSkema,
          icon: Icons.verified_rounded,
          iconColor: const Color(0xFFFFB300),
          iconBgColor: const Color(0xFFFFF9E6),
        ),
        SummaryCard(
          title: 'Asesor Aktif',
          value: isLoading
              ? '...'
              : NumberFormatHelper.formatWithDots(data.totalAsesor),
          trend: data.trendAsesor,
          subtitle: 'Asesor Terverifikasi',
          comparison: data.sebaranAsesor,
          icon: Icons.assignment_ind_rounded,
          iconColor: const Color(0xFF00D1B2),
          iconBgColor: const Color(0xFFE6FAF7),
        ),
        SummaryCard(
          title: 'Tempat Uji Kompetensi',
          value: isLoading
              ? '...'
              : NumberFormatHelper.formatWithDots(data.totalTuk),
          trend: data.trendTuk,
          subtitle: 'Jumlah TUK',
          comparison: data.tempatUjiKompetensi,
          icon: Icons.domain_rounded,
          iconColor: const Color(0xFFFF5252),
          iconBgColor: const Color(0xFFFFEEEE),
        ),
      ],
    );
  }
}

// Custom widget for summary card
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final String subtitle;
  final String comparison;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.subtitle,
    required this.comparison,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    // Parse comparison "bulan_lalu > bulan_ini"
    final comparisonData = DashboardSummary.parseComparison(comparison);
    final previous = comparisonData['previous'] ?? 0;
    final current = comparisonData['current'] ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // black with 0.04 opacity
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          // Left Column for text information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Comparison display - replaces trend indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$previous → $current',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Right Column for visual icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ],
      ),
    );
  }
}
