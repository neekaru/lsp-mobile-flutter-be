import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/blanko_models.dart';
import '../../services/admin/blanko_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'detail_pengajuan_blanko_screen.dart';
import 'widgets/blanko_card.dart';
import 'widgets/blanko_tab_pills.dart';

class AdminPengajuanBlankoScreen extends StatefulWidget {
  const AdminPengajuanBlankoScreen({super.key});

  @override
  State<AdminPengajuanBlankoScreen> createState() =>
      _AdminPengajuanBlankoScreenState();
}

class _AdminPengajuanBlankoScreenState
    extends State<AdminPengajuanBlankoScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Timer? _debounce;

  int _selectedTabIndex = 0; // 0: Semua, 1: Pending, 2: Terkirim
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  List<BlankoListItem> _items = [];
  // Badge counts harus global, jangan ikut totalItem dari response terfilter.
  int _badgeTotal = 0;
  int _badgePending = 0;
  int _badgeTerkirim = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchBlankoList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _currentStatusParam {
    switch (_selectedTabIndex) {
      case 1:
        return 'belum_terkirim';
      case 2:
        return 'terkirim';
      default:
        return '';
    }
  }

  // Infinite scroll: load next page ketika mendekati akhir list.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchBlankoList({int page = 1, bool append = false}) async {
    if (append) {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final response = await BlankoService.getBlankoList(
        page: page,
        size: _pageSize,
        search: _searchQuery,
        status: _currentStatusParam,
      );

      if (mounted) {
        final isUnfiltered =
            _currentStatusParam.isEmpty && _searchQuery.isEmpty;
        setState(() {
          _currentPage = page;
          _items = append ? [..._items, ...response.data] : response.data;
          _hasMore = page < response.meta.totalPage;
          if (isUnfiltered && !append) {
            _badgeTotal = response.meta.totalItem;
            _badgePending = response.meta.totalBelumTerkirim;
            _badgeTerkirim = response.meta.totalTerkirim;
          }
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error fetching blanko list: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    await _fetchBlankoList(page: _currentPage + 1, append: true);
  }

  void _onTabChanged(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
      _currentPage = 1;
      _items = [];
      _hasMore = true;
    });
    _fetchBlankoList(page: 1);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _searchQuery = query.trim();
          _currentPage = 1;
          _items = [];
          _hasMore = true;
        });
        _fetchBlankoList(page: 1);
      }
    });
  }

  void _navigateToDetail(BlankoListItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPengajuanBlankoScreen(
          blankoId: item.id,
          initialData: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            CustomAppBar(
              title: 'Pengajuan Blanko',
              onBack: () => Navigator.pop(context),
              rightWidget: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF0F172A),
                  size: 24,
                ),
                onSelected: (val) {
                  if (val == 'refresh') {
                    _fetchBlankoList(page: 1);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: Color(0xFF0F172A),
                        ),
                        SizedBox(width: 8),
                        Text('Refresh Data', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Filter Bar with Jadwal/Honor pill style
            BlankoTabPills(
              selectedIndex: _selectedTabIndex,
              totalCount: _badgeTotal,
              pendingCount: _badgePending,
              terkirimCount: _badgeTerkirim,
              onTabChanged: _onTabChanged,
            ),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 8),

            // Loading indicator
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF378CE7)),
              ),

            // List Content with Pull to Refresh + Infinite Auto-Scroll
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchBlankoList(page: 1),
                color: const Color(0xFF378CE7),
                child: _items.isEmpty && !_isLoading
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _items.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _items.length) {
                            // Loader kecil saat auto-load halaman berikutnya.
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF378CE7),
                                  ),
                                ),
                              ),
                            );
                          }

                          final item = _items[index];
                          return BlankoCard(
                            item: item,
                            onTap: () => _navigateToDetail(item),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SizedBox(
        height: 38,
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Cari No. Permohonan, SK, atau PIC...',
            hintStyle: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 28,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Data pengajuan blanko tidak ditemukan',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Coba ubah kata kunci pencarian atau filter tab',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
