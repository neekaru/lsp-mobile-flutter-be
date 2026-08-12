import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/admin_laporan_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/bottom_menu_bar.dart';
import 'detail_pelaporan_screen.dart';

class PelaporanScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PelaporanScreen({super.key, this.onBack});

  @override
  State<PelaporanScreen> createState() => _PelaporanScreenState();
}

/// Per-tab pagination state. Each tab (Revisi / Disetujui) fetches its own
/// page from the server — the API does the status/search filtering, so the
/// client never has to hold or scan the full 14k+ row table.
class _TabState {
  final String status; // 'Revisi' | 'Disetujui'
  List<PelaporanItemData> items = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool hasLoadedOnce = false;
  int offset = 0;
  static const int limit = 20;

  _TabState(this.status);
}

class _PelaporanScreenState extends State<PelaporanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final AdminLaporanService _service = AdminLaporanService();

  final ScrollController _revisiScrollController = ScrollController();
  final ScrollController _disetujuiScrollController = ScrollController();

  String _searchQuery = '';
  Timer? _debounce;
  String _selectedMonth = 'Juli 2026';

  late final _TabState _revisi = _TabState('Revisi');
  late final _TabState _disetujui = _TabState('Disetujui');

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {});
    // Lazily fetch the tab's first page the first time it's opened.
    final current = _tabController.index == 0 ? _revisi : _disetujui;
    if (!current.hasLoadedOnce) {
      _fetchPage(current, reset: true);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _searchQuery) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = query;
      });
      // Reset & refetch both tabs so switching tabs doesn't show stale results.
      _fetchPage(_revisi, reset: true);
      _fetchPage(_disetujui, reset: true);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    _revisiScrollController.addListener(() => _onScroll(_revisi, _revisiScrollController));
    _disetujuiScrollController.addListener(() => _onScroll(_disetujui, _disetujuiScrollController));
    // Only load the initially visible tab (Revisi) up front.
    _fetchPage(_revisi, reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _searchController.removeListener(_onSearchChanged);
    _tabController.dispose();
    _searchController.dispose();
    _revisiScrollController.dispose();
    _disetujuiScrollController.dispose();
    super.dispose();
  }

  void _onScroll(_TabState tab, ScrollController controller) {
    if (!tab.hasMore || tab.isLoadingMore || tab.isLoading) return;
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      _fetchPage(tab, reset: false);
    }
  }

  Future<void> _fetchPage(_TabState tab, {required bool reset}) async {
    if (!mounted) return;

    setState(() {
      if (reset) {
        tab.isLoading = true;
        tab.offset = 0;
        tab.hasMore = true;
      } else {
        tab.isLoadingMore = true;
      }
    });

    try {
      final response = await _service.getLaporanList(
        status: tab.status,
        search: _searchQuery,
        limit: _TabState.limit,
        offset: reset ? 0 : tab.offset,
      );

      if (!mounted) return;

      final mapped = response.data
          .map((item) => PelaporanItemData(
                id: item.id.toString(),
                skema: item.skemaSertifikasi,
                tuk: item.tuk,
                asesorName: item.namaAsesor,
                tanggalMulai: item.tanggalPelaksanaan,
                tanggalSelesai: item.tanggalPelaksanaan,
                status: item.status,
                tanggalStatus: item.tanggalPelaksanaan,
              ))
          .toList();

      setState(() {
        if (reset) {
          tab.items = mapped;
        } else {
          tab.items.addAll(mapped);
        }
        tab.offset = tab.items.length;
        tab.hasMore = tab.items.length < response.pagination.total;
        tab.isLoading = false;
        tab.isLoadingMore = false;
        tab.hasLoadedOnce = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        tab.isLoading = false;
        tab.isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> _refreshCurrentTab() async {
    final current = _tabController.index == 0 ? _revisi : _disetujui;
    await _fetchPage(current, reset: true);
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
            title: 'Pelaporan',
            onBack: widget.onBack ?? () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 4),

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

          // TabBarView Content — each tab holds its own paginated data.
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabBody(_revisi, _revisiScrollController),
                _buildTabBody(_disetujui, _disetujuiScrollController),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomMenuBar(
        selectedIndex: 0,
        onTap: (index) {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.of(context).pop();
          }
        },
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

  Widget _buildTabBody(_TabState tab, ScrollController scrollController) {
    if (tab.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C8BB4)),
      );
    }

    if (tab.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshCurrentTab,
        color: const Color(0xFF6C8BB4),
        child: ListView(
          children: [
            SizedBox(
              height: 240,
              child: Center(
                child: Text(
                  'Tidak ada data pelaporan (${tab.status}).',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshCurrentTab,
      color: const Color(0xFF6C8BB4),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        itemCount: tab.items.length + (tab.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= tab.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6C8BB4),
                  ),
                ),
              ),
            );
          }
          return _buildPelaporanCard(tab.items[index]);
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
        ).then((_) => _refreshCurrentTab());
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
