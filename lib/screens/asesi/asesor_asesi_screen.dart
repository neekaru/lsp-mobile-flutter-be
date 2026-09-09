import 'package:material_ui/material_ui.dart';
import '../../models/asesor_asesi_models.dart';
import '../../services/asesor/asesor_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/asesi/asesor_asesi_filter_widgets.dart';
import '../../widgets/asesi/asesor_asesi_list_widgets.dart';
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
  String _selectedDateFilter = 'all'; // 'all' | 'today' | 'yesterday' | 'YYYY-MM-DD'

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
        filterDate: _selectedDateFilter,
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

  void _onDateFilterChanged(String dateFilter) {
    if (_selectedDateFilter == dateFilter) return;
    setState(() {
      _selectedDateFilter = dateFilter;
      _currentPage = 1;
    });
    _fetchAsesiList();
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Jadwal Asesmen',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _onDateFilterChanged(formatted);
    }
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

          // 2 Tabs: Belum Rekomendasi vs Sudah Rekomendasi
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
                    child: AsesorAsesiTabButton(
                      label: 'Belum Rekomendasi',
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
                    child: AsesorAsesiTabButton(
                      label: 'Sudah Rekomendasi',
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

          // Search Bar & Date Filter Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                Expanded(
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
                                  ? 'Cari asesi belum rekomendasi...'
                                  : 'Cari asesi sudah rekomendasi...',
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
                const SizedBox(width: 8),
                AsesorAsesiDateFilterMenuButton(
                  selectedDateFilter: _selectedDateFilter,
                  onSelected: (val) {
                    if (val == 'custom') {
                      _pickCustomDate();
                    } else {
                      _onDateFilterChanged(val);
                    }
                  },
                ),
              ],
            ),
          ),

          // Horizontal Quick Date Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  AsesorAsesiDateChip(
                    label: 'Semua',
                    value: 'all',
                    icon: Icons.all_inclusive_rounded,
                    isSelected: _selectedDateFilter == 'all',
                    onTap: () => _onDateFilterChanged('all'),
                  ),
                  const SizedBox(width: 8),
                  AsesorAsesiDateChip(
                    label: 'Hari Ini (Today)',
                    value: 'today',
                    icon: Icons.today_rounded,
                    isSelected: _selectedDateFilter == 'today',
                    onTap: () => _onDateFilterChanged('today'),
                  ),
                  const SizedBox(width: 8),
                  AsesorAsesiDateChip(
                    label: 'Kemarin (Yesterday)',
                    value: 'yesterday',
                    icon: Icons.history_rounded,
                    isSelected: _selectedDateFilter == 'yesterday',
                    onTap: () => _onDateFilterChanged('yesterday'),
                  ),
                  if (_selectedDateFilter != 'all' &&
                      _selectedDateFilter != 'today' &&
                      _selectedDateFilter != 'yesterday') ...[
                    const SizedBox(width: 8),
                    AsesorAsesiDateChip(
                      label: _selectedDateFilter,
                      value: _selectedDateFilter,
                      icon: Icons.calendar_month_rounded,
                      isCustom: true,
                      isSelected: true,
                      onTap: () => _onDateFilterChanged(_selectedDateFilter),
                      onClear: () => _onDateFilterChanged('all'),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Subtitle / Total Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_selectedTab == 'belum' ? 'Menampilkan: $_totalCount Asesi Belum Rekomendasi' : 'Menampilkan: $_totalCount Asesi Sudah Rekomendasi'}${_selectedDateFilter == 'today' ? ' (Hari Ini)' : (_selectedDateFilter == 'yesterday' ? ' (Kemarin)' : (_selectedDateFilter != 'all' ? ' ($_selectedDateFilter)' : ''))}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
                    ? AsesorAsesiErrorWidget(
                        message: _errorMessage,
                        onRetry: () => _fetchAsesiList(isRefresh: true),
                      )
                    : _asesiList.isEmpty
                        ? const AsesorAsesiEmptyWidget()
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
                                final item = _asesiList[index];
                                return AsesorAsesiCard(
                                  item: item,
                                  isSudahTab: _selectedTab == 'sudah',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AsesorDetailAsesiScreen(
                                          asesiId: item.id,
                                          namaAsesi: item.namaLengkap,
                                          skema: item.skema,
                                          tuk: item.tukNama,
                                          jadwal: item.jadwalNama,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
