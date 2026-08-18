import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'asesor_detail_asesi_screen.dart';

class AsesorAsesiScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AsesorAsesiScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<AsesorAsesiScreen> createState() => _AsesorAsesiScreenState();
}

class _AsesorAsesiScreenState extends State<AsesorAsesiScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';

  List<AsesorAsesiItem> _asesiList = [];
  AsesorAsesiSummary? _summary;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  String _searchQuery = '';
  String _selectedTab = 'belum'; // 'belum' | 'sudah'

  @override
  void initState() {
    super.initState();
    _fetchAsesiList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _currentPage < _totalPages) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAsesiList({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    setState(() {
      if (_currentPage == 1) {
        _isLoading = true;
      }
      _errorMessage = '';
    });

    try {
      // Data awal 10, saat scroll pagination ambil 20
      final int limit = _currentPage == 1 ? 10 : 20;

      final res = await AsesorService.getAsesiList(
        search: _searchQuery,
        status: _selectedTab,
        page: _currentPage,
        perPage: limit,
      );

      if (res != null) {
        setState(() {
          if (_currentPage == 1) {
            _asesiList = res.data;
          } else {
            _asesiList.addAll(res.data);
          }
          if (res.summary != null) {
            _summary = res.summary;
          }
          _totalCount = res.total;
          _totalPages = res.totalPages;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat daftar asesi.';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data.';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    await _fetchAsesiList();
  }

  void _onSearch(String val) {
    setState(() {
      _searchQuery = val.trim();
      _currentPage = 1;
    });
    _fetchAsesiList();
  }

  void _onTabChanged(String tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
      _currentPage = 1;
    });
    _fetchAsesiList();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final int belumCount = _summary?.totalBelumDinilai ?? 0;
    final int sudahCount = _summary?.totalSudahDinilai ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Daftar Asesi',
            onBack: widget.onBackToHome,
            rightWidget: const SizedBox(width: 32),
          ),

          // 2 Tabs: Belum Dinilai vs Sudah Dinilai
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      label: 'Belum Dinilai',
                      badgeCount: belumCount,
                      isActive: _selectedTab == 'belum',
                      activeColor: const Color(0xFFEA580C),
                      activeBadgeBg: const Color(0xFFFFEDD5),
                      activeBadgeText: const Color(0xFFC2410C),
                      onTap: () => _onTabChanged('belum'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTabButton(
                      label: 'Sudah Dinilai',
                      badgeCount: sudahCount,
                      isActive: _selectedTab == 'sudah',
                      activeColor: const Color(0xFF059669),
                      activeBadgeBg: const Color(0xFFD1FAE5),
                      activeBadgeText: const Color(0xFF047857),
                      onTap: () => _onTabChanged('sudah'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _onSearch,
                      onChanged: (val) {
                        setState(() {});
                      },
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: _selectedTab == 'belum'
                            ? 'Cari asesi belum dinilai...'
                            : 'Cari asesi sudah dinilai...',
                        hintStyle: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      color: const Color(0xFF94A3B8),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          // Subtitle / Total Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTab == 'belum'
                      ? 'Menampilkan: $_totalCount Asesi Belum Dinilai'
                      : 'Menampilkan: $_totalCount Asesi Sudah Dinilai',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Text(
                  'Jadwal Terbaru',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Main List View
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : _asesiList.isEmpty
                        ? _buildEmptyWidget()
                        : RefreshIndicator(
                            onRefresh: () => _fetchAsesiList(isRefresh: true),
                            color: const Color(0xFF2563EB),
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 6.0,
                              ),
                              itemCount: _asesiList.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _asesiList.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF2563EB),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                return _buildAsesiCard(_asesiList[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required int badgeCount,
    required bool isActive,
    required Color activeColor,
    required Color activeBadgeBg,
    required Color activeBadgeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeColor : const Color(0xFF64748B),
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive ? activeBadgeBg : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isActive ? activeBadgeText : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => _fetchAsesiList(isRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 44,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada asesi ditemukan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Belum ada data asesi yang terhubung dengan jadwal penugasan Anda.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsesiCard(AsesorAsesiItem item) {
    Color badgeBg = const Color(0xFFEFF6FF);
    Color badgeText = const Color(0xFF2563EB);

    final statusStr = item.rekomendasiAsesor.toLowerCase();
    if (statusStr.contains('kompeten') && !statusStr.contains('belum')) {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF059669);
    } else if (statusStr.contains('belum kompeten')) {
      badgeBg = const Color(0xFFFEF2F2);
      badgeText = const Color(0xFFDC2626);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AsesorDetailAsesiScreen(
                asesiId: item.id,
                namaAsesi: item.namaLengkap,
                skema: item.skema,
                tuk: item.tukNama,
                jadwal: item.jadwalNama,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Name & Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaLengkap,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.jadwalNama.isNotEmpty
                              ? item.jadwalNama
                              : (item.skema.isNotEmpty ? item.skema : '-'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.rekomendasiAsesor,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeText,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // TUK Row
              Row(
                children: [
                  const Icon(
                    LucideIcons.building,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'TUK: ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.tukNama.isNotEmpty ? item.tukNama : '-',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Jadwal Row (Berapa hari sudah lewat tanggal asesmen)
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Jadwal: ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatJadwalStatus(item.jadwalTanggal),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _getJadwalStatusColor(item.jadwalTanggal),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatJadwalStatus(String dateStr) {
    if (dateStr.trim().isEmpty || dateStr == '-') {
      return '-';
    }
    final parsed = DateFormatHelper.parseDate(dateStr);
    if (parsed == null) {
      return dateStr;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = today.difference(scheduledDate).inDays;

    if (diff > 0) {
      return 'Lewat $diff Hari';
    } else if (diff == 0) {
      return 'Hari Ini';
    } else {
      final daysLeft = -diff;
      if (daysLeft == 1) {
        return 'Besok';
      }
      return '$daysLeft Hari Lagi';
    }
  }

  Color _getJadwalStatusColor(String dateStr) {
    if (dateStr.trim().isEmpty || dateStr == '-') {
      return const Color(0xFF64748B);
    }
    final parsed = DateFormatHelper.parseDate(dateStr);
    if (parsed == null) {
      return const Color(0xFF334155);
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = today.difference(scheduledDate).inDays;

    if (diff > 0) {
      return const Color(0xFFDC2626);
    } else if (diff == 0) {
      return const Color(0xFF059669);
    } else {
      return const Color(0xFF2563EB);
    }
  }
}
