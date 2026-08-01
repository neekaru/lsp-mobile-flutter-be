import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'detail_honor_screen.dart';

class DetailTugasAsesorScreen extends StatefulWidget {
  final Map<String, dynamic> asesorData;

  const DetailTugasAsesorScreen({
    super.key,
    required this.asesorData,
  });

  @override
  State<DetailTugasAsesorScreen> createState() => _DetailTugasAsesorScreenState();
}

class _DetailTugasAsesorScreenState extends State<DetailTugasAsesorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getTasksForAsesor() {
    // Default task items matching reference screenshot
    return [
      {
        'id': 101,
        'judul': 'Junior Grafik Desain',
        'tuk': 'SMK 2 Jakarta',
        'waktu': '07/05/2026 09:00 wib',
        'mode': '(Offline)',
        'honor': 'Rp 2.250.000',
        'status': 'Selesai',
      },
      {
        'id': 102,
        'judul': 'Junior Web Developer',
        'tuk': 'SMA 5 Semarang',
        'waktu': '20/05/2026 09:00 wib',
        'mode': '(Offline)',
        'honor': 'Rp 2.250.000',
        'status': 'Selesai',
      },
      {
        'id': 103,
        'judul': 'Digital Marketing',
        'tuk': 'SMA 5 Semarang',
        'waktu': '30/05/2026 09:00 wib',
        'mode': '(Online)',
        'honor': 'Rp 2.250.000',
        'status': 'Menunggu',
      },
      {
        'id': 104,
        'judul': 'Digital Marketing',
        'tuk': 'SMA 5 Semarang',
        'waktu': '30/05/2026 09:00 wib',
        'mode': '(Online)',
        'honor': 'Rp 2.250.000',
        'status': 'Menunggu',
      },
      {
        'id': 105,
        'judul': 'Junior Web Developer',
        'tuk': 'SMA 5 Semarang',
        'waktu': '30/07/2026 09:00 wib',
        'mode': '(Offline)',
        'honor': 'Rp 2.250.000',
        'status': 'Selesai',
      },
      {
        'id': 106,
        'judul': 'Junior Web Developer',
        'tuk': 'SMA 5 Semarang',
        'waktu': '30/07/2026 09:00 wib',
        'mode': '(Offline)',
        'honor': 'Rp 2.250.000',
        'status': 'Selesai',
      },
    ];
  }

  void _navigateToDetailHonor(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHonorScreen(
          detail: {
            'judul_asesmen': task['judul'],
            'honor': task['honor'],
            'tanggal': task['waktu'],
            'tuk': task['tuk'],
            'status': task['status'],
          },
          status: task['status'] ?? 'Selesai',
          metodePembayaran: 'Transfer Bank',
          tanggalPembayaran: task['waktu'] ?? '20 Juli 2026',
          noTransfer: 'PAY-20260720-001',
          jumlahAsesmen: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    
    final String namaAsesor = widget.asesorData['nama_asesor'] ?? 'Karina';
    final String tipeAsesor = widget.asesorData['tipe_asesor'] ?? 'Asessor Internal';
    final String totalHonor = widget.asesorData['total_honor'] ?? 'Rp 4.000.000';
    final String statusAsesor = widget.asesorData['status_asesor'] ?? 'Aktif';

    final allTasks = _getTasksForAsesor();
    final selesaiTasks = allTasks.where((t) => (t['status'] ?? '').toString().toLowerCase() == 'selesai').toList();
    final menungguTasks = allTasks.where((t) => (t['status'] ?? '').toString().toLowerCase() == 'menunggu').toList();

    List<Map<String, dynamic>> currentTasks = allTasks;
    if (_tabController.index == 1) {
      currentTasks = selesaiTasks;
    } else if (_tabController.index == 2) {
      currentTasks = menungguTasks;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Header
          CustomAppBar(
            title: 'Detail Tugas Asessor',
            onBack: () => Navigator.of(context).pop(),
            rightWidget: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.black, size: 24),
              onSelected: (val) {},
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF0F172A)),
                      SizedBox(width: 8),
                      Text('Refresh Data', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // 1. Asesor Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    namaAsesor,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tipeAsesor,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                statusAsesor,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                            children: [
                              const TextSpan(
                                text: 'Total Honor : ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: totalHonor,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Main Content Container with Tabs
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Tab Bar Header (Semua, Selesai, Menunggu with Red Count Badges)
                        Row(
                          children: [
                            _buildUnderlineTab(
                              index: 0,
                              label: 'Semua',
                              count: allTasks.length,
                            ),
                            _buildUnderlineTab(
                              index: 1,
                              label: 'Selesai',
                              count: selesaiTasks.length,
                            ),
                            _buildUnderlineTab(
                              index: 2,
                              label: 'Menunggu',
                              count: menungguTasks.length,
                            ),
                          ],
                        ),

                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 12),

                        // Tasks List
                        if (currentTasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'Tidak ada tugas',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentTasks.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final task = currentTasks[index];
                              return _buildTaskCard(task);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnderlineTab({
    required int index,
    required String label,
    required int count,
  }) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final String judul = task['judul'] ?? '';
    final String tuk = task['tuk'] ?? '';
    final String waktu = task['waktu'] ?? '';
    final String mode = task['mode'] ?? '(Offline)';
    final String honor = task['honor'] ?? 'Rp 0';
    final String status = task['status'] ?? 'Selesai';
    final bool isSelesai = status.toLowerCase() == 'selesai';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _navigateToDetailHonor(task),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document Icon Box
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.description_rounded,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'TUK : $tuk',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        waktu,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mode,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: mode.contains('Online') ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Amount & Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      honor,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelesai ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSelesai ? 'Selesai' : 'Menunggu',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelesai ? const Color(0xFF10B981) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
