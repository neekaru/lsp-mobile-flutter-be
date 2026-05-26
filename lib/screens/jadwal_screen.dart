import 'package:flutter/material.dart';
import '../models/jadwal_models.dart';
import '../widgets/jadwal/jadwal_list_item.dart';
import 'jadwal_detail_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock user role - dalam implementasi nyata, ambil dari auth service
  final UserRole currentUser = const UserRole(
    role: 'admin', // Ubah ke 'asesor' atau 'viewer' untuk testing permission
    name: 'Admin User',
    email: 'admin@lsp.com',
  );

  // Mock data - dalam implementasi nyata, ambil dari API
  final JadwalStatistik stats = JadwalStatistik.fallback();
  
  final List<JadwalItem> akanBerakhirList = const [
    JadwalItem(
      id: 1,
      skema: 'Skema Junior Web Developer',
      tuk: 'TUK LSP Pengembangan',
      tanggalMulai: '2025-05-20',
      tanggalSelesai: '2025-05-28',
      status: 'akan_berakhir',
      jumlahAsesi: 25,
      asesor: 'Budi Santoso',
      sisaHari: 2,
    ),
    JadwalItem(
      id: 2,
      skema: 'Skema Junior Web Developer',
      tuk: 'TUK LSP Pengembangan',
      tanggalMulai: '2025-05-18',
      tanggalSelesai: '2025-05-27',
      status: 'akan_berakhir',
      jumlahAsesi: 30,
      asesor: 'Budi Santoso',
      sisaHari: 1,
    ),
    JadwalItem(
      id: 3,
      skema: 'Skema Junior Web Developer',
      tuk: 'TUK LSP Pengembangan',
      tanggalMulai: '2025-05-15',
      tanggalSelesai: '2025-05-29',
      status: 'akan_berakhir',
      jumlahAsesi: 28,
      asesor: 'Budi Santoso',
      sisaHari: 3,
    ),
    JadwalItem(
      id: 4,
      skema: 'Skema Junior Web Developer',
      tuk: 'TUK LSP Pengembangan',
      tanggalMulai: '2025-05-12',
      tanggalSelesai: '2025-05-30',
      status: 'akan_berakhir',
      jumlahAsesi: 22,
      asesor: 'Budi Santoso',
      sisaHari: 4,
    ),
    JadwalItem(
      id: 5,
      skema: 'Skema Junior Web Developer',
      tuk: 'TUK LSP Pengembangan',
      tanggalMulai: '2025-05-10',
      tanggalSelesai: '2025-06-02',
      status: 'akan_berakhir',
      jumlahAsesi: 35,
      asesor: 'Budi Santoso',
      sisaHari: 7,
    ),
  ];

  final List<JadwalItem> sedangBerjalanList = const [
    JadwalItem(
      id: 6,
      skema: 'Skema Data Analyst',
      tuk: 'TUK LSP Digital',
      tanggalMulai: '2025-05-01',
      tanggalSelesai: '2025-06-15',
      status: 'sedang_berjalan',
      jumlahAsesi: 40,
      asesor: 'Siti Aminah',
      sisaHari: 20,
    ),
    JadwalItem(
      id: 7,
      skema: 'Skema Mobile Developer',
      tuk: 'TUK LSP Teknologi',
      tanggalMulai: '2025-05-05',
      tanggalSelesai: '2025-06-20',
      status: 'sedang_berjalan',
      jumlahAsesi: 32,
      asesor: 'Ahmad Rizki',
      sisaHari: 25,
    ),
  ];

  final List<JadwalItem> selesaiList = const [
    JadwalItem(
      id: 8,
      skema: 'Skema UI/UX Designer',
      tuk: 'TUK LSP Kreatif',
      tanggalMulai: '2025-04-01',
      tanggalSelesai: '2025-04-30',
      status: 'selesai',
      jumlahAsesi: 28,
      asesor: 'Dewi Lestari',
      sisaHari: 0,
    ),
    JadwalItem(
      id: 9,
      skema: 'Skema Network Administrator',
      tuk: 'TUK LSP Infrastruktur',
      tanggalMulai: '2025-03-15',
      tanggalSelesai: '2025-04-15',
      status: 'selesai',
      jumlahAsesi: 20,
      asesor: 'Eko Prasetyo',
      sisaHari: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          // Header sederhana dengan back button
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Jadwal Asesmen',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.black87,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF5B9FD8),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Akan Berakhir'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '${akanBerakhirList.length}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Tab(text: 'Berjalan'),
                const Tab(text: 'Selesai'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Akan Berakhir (dengan chart)
                _buildAkanBerakhirTab(),
                
                // Tab 2: Sedang Berjalan
                _buildJadwalList(sedangBerjalanList, 'sedang_berjalan'),
                
                // Tab 3: Selesai
                _buildJadwalList(selesaiList, 'selesai'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAkanBerakhirTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistik Card dengan Line Chart
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Asesmen',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '8.045',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '↑ 15,7%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'dibanding tahun 2025',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 100,
                    child: CustomPaint(
                      painter: MiniLineChartPainter(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // List Jadwal
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: akanBerakhirList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = akanBerakhirList[index];
              return JadwalListItem(
                item: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JadwalDetailScreen(
                        jadwal: item,
                        userRole: currentUser,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildJadwalList(List<JadwalItem> items, String status) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE5F1FC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: Color(0xFF2C6C9C),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada jadwal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return JadwalListItem(
          item: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JadwalDetailScreen(
                  jadwal: item,
                  userRole: currentUser,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Custom Painter untuk Mini Line Chart
class MiniLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Data points untuk line chart (simulasi data)
    final dataPoints = [
      0.3, 0.5, 0.4, 0.6, 0.8, 0.7, 0.9, 0.85, 1.0
    ];

    // Bar chart colors
    final barColors = [
      const Color(0xFF5B47D8), // Purple
      const Color(0xFF5B47D8),
      const Color(0xFFFFC107), // Yellow
      const Color(0xFFFF7043), // Orange
      const Color(0xFF5B9FD8), // Blue
      const Color(0xFFFF7043), // Orange
    ];

    final barWidth = size.width / (barColors.length * 2);
    final maxBarHeight = size.height * 0.6;

    // Draw bars
    for (int i = 0; i < barColors.length; i++) {
      final barPaint = Paint()
        ..color = barColors[i]
        ..style = PaintingStyle.fill;

      final barHeight = maxBarHeight * (0.4 + (i % 3) * 0.2);
      final x = i * barWidth * 1.8 + barWidth * 0.5;
      final y = size.height - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, barPaint);
    }

    // Draw line chart
    final linePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (size.width / (dataPoints.length - 1)) * i;
      final y = size.height - (dataPoints[i] * size.height * 0.7);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

