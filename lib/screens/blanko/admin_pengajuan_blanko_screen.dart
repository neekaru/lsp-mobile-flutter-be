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
  String _searchQuery = '';
  Timer? _debounce;

  int _selectedTabIndex = 0; // 0: Semua, 1: Pending, 2: Terkirim
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoading = false;

  List<BlankoListItem> _items = [];
  BlankoMeta _meta = const BlankoMeta();

  @override
  void initState() {
    super.initState();
    _fetchBlankoList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
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

  Future<void> _fetchBlankoList({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _currentPage = page;
    });

    try {
      final response = await BlankoService.getBlankoList(
        page: page,
        size: _pageSize,
        search: _searchQuery,
        status: _currentStatusParam,
      );

      if (mounted) {
        setState(() {
          _items = response.data;
          _meta = response.meta;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error fetching blanko list: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
      _currentPage = 1;
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
                    _fetchBlankoList(page: _currentPage);
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
              totalCount: _meta.totalItem,
              pendingCount: _meta.totalBelumTerkirim,
              terkirimCount: _meta.totalTerkirim,
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

            // List Content with Pull to Refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchBlankoList(page: 1),
                color: const Color(0xFF378CE7),
                child: _items.isEmpty && !_isLoading
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return BlankoCard(
                            item: item,
                            onTap: () => _navigateToDetail(item),
                          );
                        },
                      ),
              ),
            ),

            // Pagination Controls (if more than 1 page)
            if (_meta.totalPage > 1) _buildPaginationFooter(),
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

  Widget _buildPaginationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Halaman $_currentPage dari ${_meta.totalPage}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _currentPage > 1 && !_isLoading
                    ? () => _fetchBlankoList(page: _currentPage - 1)
                    : null,
                visualDensity: VisualDensity.compact,
              ),
              Text(
                '$_currentPage',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _currentPage < _meta.totalPage && !_isLoading
                    ? () => _fetchBlankoList(page: _currentPage + 1)
                    : null,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
