import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/statistik/indonesia_map.dart';

class PublicStatistikScreen extends StatelessWidget {
  const PublicStatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          // Header following JadwalScreen style
          const CustomAppBar(title: 'Statistik LSP'),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Three Metrics Cards
                  Row(
                    children: [
                      _buildMetricCard(
                        icon: Icons.groups_rounded,
                        count: '1.000',
                        label: 'Peserta\nBersertifikat',
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        icon: Icons.assignment_ind_rounded,
                        count: '73',
                        label: 'Asesor\nProfesional',
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        icon: Icons.apartment_rounded,
                        count: '40',
                        label: 'TUK Aktif',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sebaran Asesor Section
                  const Text(
                    'Sebaran asesor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dynamic Vector Map
                  IndonesiaMap(
                    onIslandSelected: (islandId) {
                      debugPrint('Island selected: $islandId');
                    },
                    onProvinceSelected: (province) {
                      debugPrint('Province selected: ${province.name}');
                    },
                  ),
                  const SizedBox(height: 12),

                  // Lokasi/Wilayah Asesor Skema List Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lokasi/Wilayah Asesor Skema',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildWilayahItem('ACEH', '2 Asesor', '2,7%', const Color(0xFF3E82B3)),
                        _buildDivider(),
                        _buildWilayahItem('SUMATRA UTARA', '1 Asesor', '1,4%', const Color(0xFF7CB8E6)),
                        _buildDivider(),
                        _buildWilayahItem('RIAU', '1 Asesor', '1,4%', const Color(0xFF7CB8E6)),
                        _buildDivider(),
                        _buildWilayahItem('SUMATRA SELATAN', '2 Asesor', '1,4%', const Color(0xFF3E82B3)),
                        _buildDivider(),
                        _buildWilayahItem('DKI JAKARTA', '11 Asesor', '15,1%', const Color(0xFF0F4C81)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Skema Paling Populer Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Skema Paling Populer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Row(
                          children: const [
                            Text(
                              'Lihat semua',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E6FDB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: Color(0xFF1E6FDB),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Horizontal Cards
                  SizedBox(
                    height: 190,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPopularSkemaCard(
                          icon: Icons.campaign_rounded,
                          title: 'Skema Digital Marketing',
                        ),
                        const SizedBox(width: 12),
                        _buildPopularSkemaCard(
                          icon: Icons.lan_rounded,
                          title: 'Network Administrator Muda',
                        ),
                        const SizedBox(width: 12),
                        _buildPopularSkemaCard(
                          icon: Icons.palette_rounded,
                          title: 'Desain Multimedia Muda',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Monthly Certificate Issued Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar filter
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF1E6FDB)),
                              SizedBox(width: 6),
                              Text(
                                'Mei 2025',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info row with trend chart
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2F0FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFF1E6FDB),
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Sertifikat Diterbitkan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '1.000',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Sertifikat Kompetensi\ntelah diterbitkan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF1E6FDB),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CustomPaint(
                              size: const Size(60, 40),
                              painter: GreenTrendPainter(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Expanded(
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE2F0FD),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1E6FDB), size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E6FDB),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWilayahItem(String provinsi, String asesorCount, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            provinsi,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Text(
          asesorCount,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }

  Widget _buildPopularSkemaCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xFF94A3B8), size: 40),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Pendaftaran dibuka tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Pendaftaran Dibuka',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15803D),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E6FDB),
            ),
          ),
          const SizedBox(height: 8),

          // Button
          SizedBox(
            width: double.infinity,
            height: 24,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9FD8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Lihat Skema',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Green growth trend custom painter
class GreenTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw columns at the bottom
    final barPaint = Paint()..color = const Color(0xFFDCFCE7);
    final double barWidth = size.width / 7;
    final heights = [0.2, 0.3, 0.4, 0.45, 0.6, 0.75, 0.9];
    
    for (int i = 0; i < heights.length; i++) {
      final double h = size.height * heights[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * (barWidth + 2),
            size.height - h,
            barWidth,
            h,
          ),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }

    // Draw growth line
    final linePaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(2, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.75,
        size.width * 0.75,
        size.height * 0.35,
      )
      ..lineTo(size.width - 2, size.height * 0.1);

    canvas.drawPath(path, linePaint);

    // Draw arrowhead
    final arrowPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;
      
    final arrowPath = Path()
      ..moveTo(size.width - 2, size.height * 0.1)
      ..lineTo(size.width - 9, size.height * 0.1 + 1)
      ..lineTo(size.width - 4, size.height * 0.1 + 7)
      ..close();
      
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
