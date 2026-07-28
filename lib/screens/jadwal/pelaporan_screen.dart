import 'package:flutter/material.dart';
import '../../services/admin_laporan_service.dart';
import 'detail_pelaporan_screen.dart';

class PelaporanScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PelaporanScreen({super.key, this.onBack});

  @override
  State<PelaporanScreen> createState() => _PelaporanScreenState();
}

class _PelaporanScreenState extends State<PelaporanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedMonth = 'Juli 2026';

  List<PelaporanItemData> _revisiList = [];
  List<PelaporanItemData> _disetujuiList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _loadPelaporanData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPelaporanData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminLaporanService = AdminLaporanService();
      final response = await adminLaporanService.getLaporanList();

      // Split by status
      List<PelaporanItemData> revisiList = [];
      List<PelaporanItemData> disetujuiList = [];

      for (var item in response.data) {
        final data = PelaporanItemData(
          id: item.id.toString(),
          skema: item.skemaSertifikasi,
          tuk: item.tuk,
          asesorName: item.namaAsesor,
          tanggalMulai: item.tanggalPelaksanaan,
          tanggalSelesai: item.tanggalPelaksanaan,
          status: item.status,
          tanggalStatus: item.tanggalPelaksanaan,
        );

        if (item.status == 'Revisi') {
          revisiList.add(data);
        } else if (item.status == 'Disetujui') {
          disetujuiList.add(data);
        }
      }

      setState(() {
        _revisiList = revisiList;
        _disetujuiList = disetujuiList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  List<PelaporanItemData> _getFilteredList(List<PelaporanItemData> source) {
    if (_searchQuery.isEmpty) return source;
    return source.where((item) {
      final matchesSkema = item.skema.toLowerCase().contains(_searchQuery);
      final matchesTuk = item.tuk.toLowerCase().contains(_searchQuery);
      final matchesAsesor = item.asesorName.toLowerCase().contains(_searchQuery);
      return matchesSkema || matchesTuk || matchesAsesor;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Custom Header: "< pelaporan"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E293B),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF1E293B),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'pelaporan',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Top Tab Bar following Jadwal pill design system
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabPill(
                    label: 'Revisi',
                    isSelected: _tabController.index == 0,
                    onTap: () => _tabController.animateTo(0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabPill(
                    label: 'Disetujui',
                    isSelected: _tabController.index == 1,
                    onTap: () => _tabController.animateTo(1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search input & Date filter dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Search field: "Cari TUK/skema pelapor"
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Cari TUK/skema pelapor',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Date filter dropdown pill button
                GestureDetector(
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2026, 7, 18),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (selected != null) {
                      const months = [
                        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                      ];
                      setState(() {
                        _selectedMonth = '${months[selected.month - 1]} ${selected.year}';
                      });
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedMonth,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // TabBarView Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C8BB4),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 0: Revisi
                      _buildPelaporanListView(
                        _getFilteredList(_revisiList),
                        'Revisi',
                      ),

                      // Tab 1: Disetujui
                      _buildPelaporanListView(
                        _getFilteredList(_disetujuiList),
                        'Disetujui',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds a tab pill widget using the exact JadwalTabBar design system
  Widget _buildTabPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color containerColor =
        isSelected ? const Color(0xFF6C8BB4) : const Color(0xFFD2E3F4);
    final Color textColor =
        isSelected ? Colors.white : const Color(0xFF5A7EAA);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPelaporanListView(
      List<PelaporanItemData> items, String currentStatus) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data pelaporan ($currentStatus).',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPelaporanData,
      color: const Color(0xFF6C8BB4),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildPelaporanCard(item);
        },
      ),
    );
  }

  Widget _buildPelaporanCard(PelaporanItemData item) {
    final bool isApproved = item.status == 'Disetujui';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPelaporanScreen(
              laporanId: int.tryParse(item.id) ?? 0,
            ),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Blue Document Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Main Card Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Skema Title & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.skema,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFFDCFCE7) // Soft Green
                            : const Color(0xFFFEF3C7), // Soft Amber/Yellow
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isApproved
                              ? const Color(0xFF16A34A) // Green text
                              : const Color(0xFFD97706), // Amber text
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Icon Row 1: Asesor Name
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.asesorName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Icon Row 2: TUK / Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.tuk,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Icon Row 3: Assessment Date Range
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.tanggalMulai} – ${item.tanggalSelesai}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Status info date line at bottom
                Text(
                  '${item.status} : ${item.tanggalStatus}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

class PelaporanItemData {
  final String id;
  final String skema;
  final String tuk;
  final String asesorName;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String status; // 'Disetujui' or 'Revisi'
  final String tanggalStatus;

  PelaporanItemData({
    required this.id,
    required this.skema,
    required this.tuk,
    required this.asesorName,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.status,
    required this.tanggalStatus,
  });
}
