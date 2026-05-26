import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RangkumanUtama extends StatefulWidget {
  const RangkumanUtama({super.key});

  @override
  State<RangkumanUtama> createState() => _RangkumanUtamaState();
}

class _RangkumanUtamaState extends State<RangkumanUtama> {
  late Future<DashboardSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = ApiService.getSummary();
  }

  // Format numbers with dots as thousands separator
  String _formatNumber(int number) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toString().replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
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
              // "Bulan Ini" Dropdown Pill
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bulan Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
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
          const Text(
            'Data diperbarui secara real-time',
            style: TextStyle(
              color: Color(0xB3FFFFFF), // white with 0.7 opacity
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Grid of Summary Cards with premium modern rounded Material Icons
          FutureBuilder<DashboardSummary>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              final isSearching = snapshot.connectionState == ConnectionState.waiting;
              final data = snapshot.data ?? DashboardSummary.fallback();

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.32,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  SummaryCard(
                    title: 'Total Asesmen',
                    value: isSearching ? '...' : _formatNumber(data.totalAsesmen),
                    trend: '15,7%',
                    subtitle: 'Total Terjadwal',
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF5C51DC),
                    iconBgColor: const Color(0xFFEEECFD),
                  ),
                  SummaryCard(
                    title: 'Pemegang Sertifikat',
                    value: isSearching ? '...' : _formatNumber(data.totalPemegangSertifikat),
                    trend: '12,3%',
                    subtitle: 'Asesi Kompeten',
                    icon: Icons.people_alt_rounded,
                    iconColor: const Color(0xFFFFB300),
                    iconBgColor: const Color(0xFFFFF9E6),
                  ),
                  SummaryCard(
                    title: 'Asesor Aktif',
                    value: isSearching ? '...' : _formatNumber(data.totalAsesor),
                    trend: '8,1%',
                    subtitle: 'Asesor Terverifikasi',
                    icon: Icons.badge_rounded,
                    iconColor: const Color(0xFF00D1B2),
                    iconBgColor: const Color(0xFFE6FAF7),
                  ),
                  SummaryCard(
                    title: 'Mitra & TUK Aktif',
                    value: isSearching ? '...' : _formatNumber(data.totalTuk),
                    trend: '4,5%',
                    subtitle: 'Lembaga / TUK',
                    icon: Icons.handshake_rounded,
                    iconColor: const Color(0xFFFF5252),
                    iconBgColor: const Color(0xFFFFEEEE),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom widget for summary card
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '▲',
                      style: TextStyle(color: Color(0xFF3CD278), fontSize: 8),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      trend,
                      style: const TextStyle(
                        color: Color(0xFF3CD278),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 8.5),
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
