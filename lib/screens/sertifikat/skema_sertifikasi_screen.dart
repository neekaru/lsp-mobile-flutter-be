// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../models/sertifikat_models.dart';
import '../../services/sertifikat_service.dart';
import 'filter_menu_overlay.dart';
import 'detail_skema_screen.dart';

class SkemaSertifikasiScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const SkemaSertifikasiScreen({super.key, this.onBackToHome});

  @override
  State<SkemaSertifikasiScreen> createState() => _SkemaSertifikasiScreenState();
}

class _SkemaSertifikasiScreenState extends State<SkemaSertifikasiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua Skema';
  int _currentPage = 1;
  static const int _itemsPerPage = 6;

  // Filter states matching the popover options
  String _selectedKategori = 'Semua Skema';
  String? _selectedJenjang;
  String? _selectedBidang;

  // API state
  List<SkemaSertifikatListItem> _skemaList = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  int _totalPages = 1;

  // Palette for card gradients
  static const List<List<Color>> _palettes = [
    [Color(0xFFFFF9C4), Color(0xFFFFB74D)],
    [Color(0xFFE0F7FA), Color(0xFF4DD0E1)],
    [Color(0xFFE8EAF6), Color(0xFF7986CB)],
    [Color(0xFFFFEBEE), Color(0xFFE57373)],
    [Color(0xFFE3F2FD), Color(0xFF64B5F6)],
    [Color(0xFFF3E5F5), Color(0xFFBA68C8)],
    [Color(0xFFE1F5FE), Color(0xFF29B6F6)],
    [Color(0xFFE0F2F1), Color(0xFF4DB6AC)],
  ];

  static const List<IconData> _icons = [
    Icons.campaign_rounded,
    Icons.palette_rounded,
    Icons.assignment_rounded,
    Icons.storage_rounded,
    Icons.dns_rounded,
    Icons.analytics_rounded,
    Icons.brush_rounded,
    Icons.workspace_premium_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    _fetchSkema();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSkema() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      final response = await SertifikatService.getSkemaList(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        kategori: (_selectedKategori == 'Semua Skema' || _selectedKategori == 'Skema Populer') ? null : _selectedKategori,
        jenjang: _selectedJenjang,
        bidang: _selectedBidang,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      setState(() {
        _skemaList = response.data;
        _totalPages = response.meta.lastPage;
        if (_totalPages < 1) _totalPages = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _onFilterChanged() {
    _currentPage = 1;
    _fetchSkema();
  }

  void _showFilterMenu() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Filter',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FilterMenuOverlay(
          initialKategori: _selectedKategori,
          initialJenjang: _selectedJenjang,
          initialBidang: _selectedBidang,
          onApply: (kategori, jenjang, bidang) {
            setState(() {
              _selectedKategori = kategori;
              _selectedJenjang = jenjang;
              _selectedBidang = bidang;

              // Sync the horizontal shortcut pills highlight
              if (kategori == 'Semua Skema' && jenjang == null && bidang == null) {
                _selectedFilter = 'Semua Skema';
              } else if (kategori == 'Skema Populer') {
                _selectedFilter = 'Populer';
              } else if (bidang == 'Multimedia') {
                _selectedFilter = 'Digital';
              } else {
                _selectedFilter = ''; // Deselect shortcut pills when custom combo is set
              }
            });
            _onFilterChanged();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Header Widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.onBackToHome != null) {
                      widget.onBackToHome!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const Text(
                  'Skema Sertifikasi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: _showFilterMenu,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar Widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _onFilterChanged(),
                decoration: InputDecoration(
                  hintText: 'Cari skema',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onFilterChanged();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),

          // Filter Row Widget (Shortcuts)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterButton('Semua Skema'),
                const SizedBox(width: 8),
                _buildFilterButton('Populer'),
                const SizedBox(width: 8),
                _buildFilterButton('Digital'),
              ],
            ),
          ),

          // Grid View of Schemes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EDF)))
                : _isError
                    ? _buildErrorState()
                    : _skemaList.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.43,
                            ),
                            itemCount: _skemaList.length,
                            itemBuilder: (context, index) {
                              return _buildSchemeCard(_skemaList[index], index);
                            },
                          ),
          ),

          // Pagination Widget
          if (!_isLoading && !_isError && _totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filterName) {
    final bool isSelected = _selectedFilter == filterName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterName;
          if (filterName == 'Semua Skema') {
            _selectedKategori = 'Semua Skema';
            _selectedJenjang = null;
            _selectedBidang = null;
          } else if (filterName == 'Populer') {
            _selectedKategori = 'Skema Populer';
            _selectedJenjang = null;
            _selectedBidang = null;
          } else if (filterName == 'Digital') {
            _selectedKategori = 'Semua Skema';
            _selectedJenjang = null;
            _selectedBidang = 'Multimedia';
          }
        });
        _onFilterChanged();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5E80B0) : const Color(0xFFD6E6F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          filterName,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2C6C9C),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeCard(SkemaSertifikatListItem skema, int index) {
    final colors = _palettes[index % _palettes.length];
    final icon = _icons[index % _icons.length];
    final isOpen = skema.isOpen;
    final tags = skema.tags;

    final scheme = {
      'id': skema.id,
      'title': skema.title,
      'status': skema.status,
      'isOpen': skema.isOpen,
      'tags': skema.tags,
      'units': '${skema.unitsCount} Unit Kompetensi',
      'price': skema.price,
      'colors': colors,
      'icon': icon,
      'description': skema.description,
      'kategori': skema.kategori,
      'jenjang': skema.jenjang,
      'bidang': skema.bidang,
      'kode_skema': skema.kodeSkema,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Graphic header
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    icon,
                    size: 56,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOpen ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      skema.status,
                      style: TextStyle(
                        color: isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Expanded(
                    child: Text(
                      skema.title,
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Tags Row
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: tags.map((tag) {
                        final isPopular = tag == 'Populer';
                        final isEUji = tag == 'E-Uji';
                        final isSjj = tag.startsWith('SJJ');
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isPopular
                                ? const Color(0xFFFFEBEE)
                                : (isEUji || isSjj)
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isPopular
                                  ? const Color(0xFFC62828)
                                  : (isEUji || isSjj)
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF1565C0),
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const Divider(height: 12, color: Color(0xFFF1F5F9)),

                  // Details rows
                  Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, size: 10, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${skema.unitsCount} Unit Kompetensi',
                          style: const TextStyle(fontSize: 8, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 10, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          skema.price,
                          style: const TextStyle(fontSize: 8, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () => _showSchemeDetail(scheme),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A9EDF),
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
            ),
          ),
        ],
      ),
    );
  }

  void _showSchemeDetail(Map<String, dynamic> scheme) {
    final id = scheme['id'] as int? ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSkemaScreen(
          skemaId: id,
          schemePreview: scheme,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF0284C7)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Skema Tidak Ditemukan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba ketik kata kunci pencarian yang lain.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, size: 36, color: Color(0xFFDC2626)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal Memuat Data',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchSkema,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A9EDF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _fetchSkema();
                  }
                : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            color: const Color(0xFF2C6C9C),
            disabledColor: Colors.grey[300],
          ),
          for (int i = 1; i <= _totalPages; i++) _buildPageNumber(i),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _fetchSkema();
                  }
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            color: const Color(0xFF2C6C9C),
            disabledColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    final bool isSelected = _currentPage == page;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = page;
        });
        _fetchSkema();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          page.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
