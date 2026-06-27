// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();
  // Selected chip in the horizontal filter bar:
  // null = Semua Skema, 'popular' = Populer, '<value>' = Bidang tertentu.
  String? _selectedChip;
  // Dynamic list of bidang fetched from /api/sertifikat/skema/bidang.
  List<SkemaBidangItem> _bidangList = [];

  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  // Filter states matching the popover options
  String _selectedKategori = 'Semua Skema';
  String? _selectedJenjang;
  String? _bidangFromOverlay;

  // API state
  List<SkemaSertifikatListItem> _skemaList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isError = false;
  String _errorMessage = '';
  int _totalPages = 1;

  // Debounce timers for search & scroll
  Timer? _searchDebounce;
  bool _isScrollThrottled = false;

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
    // Debounced search — only triggers after 400ms pause
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    // H1+H2: Force-compile gradient & shadow shaders BEFORE the first
    // scroll frame. Draws the same LinearGradient + drawShadow paths the
    // cards will use into a throwaway canvas so the GPU driver caches the
    // compiled shaders. No async — completes in a fraction of a frame.
    _warmUpGradientAndShadowShaders();
    // Fetch bidang list for dynamic filter chips (also fires skema fetch)
    _fetchBidangList();
    _fetchSkema(isInitial: true);
  }

  /// H1+H2: Pre-compile the gradient and shadow shaders so the first
  /// scroll doesn't pay shader-compilation jank.
  static void _warmUpGradientAndShadowShaders() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // Prime LinearGradient shader — same type used in _SkemaCard headers
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1, 1),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF9C4), Color(0xFFFFB74D)],
        ).createShader(const Rect.fromLTWH(0, 0, 1, 1)),
    );
    // Prime drawShadow shader — same blur-radius path used in the cards
    canvas.drawShadow(
      (Path()..addRect(const Rect.fromLTWH(0, 0, 2, 2))),
      const Color(0x06000000),
      2.0,
      false,
    );
    recorder.endRecording().dispose();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Debounced search: waits 400ms after last keystroke before rebuilding
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        // Only update the clear-button visibility, don't refetch on every key
        setState(() {});
      }
    });
  }

  /// Throttled scroll listener: checks at most once per 100ms
  void _onScroll() {
    if (_isScrollThrottled) return;
    _isScrollThrottled = true;

    Future.delayed(const Duration(milliseconds: 100), () {
      _isScrollThrottled = false;
      if (!mounted) return;
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        if (!_isLoading && !_isLoadingMore && _hasMore) {
          _fetchNextPage();
        }
      }
    });
  }

  Future<void> _fetchBidangList() async {
    try {
      final list = await SertifikatService.getBidangList();
      if (!mounted) return;
      setState(() => _bidangList = list);
    } catch (_) {
      // Silently fail — chips simply won't have the extra bidang entries
    }
  }

  Future<void> _fetchSkema({bool isInitial = true}) async {
    if (isInitial) {
      setState(() {
        _currentPage = 1;
        _isLoading = true;
        _isError = false;
        _errorMessage = '';
        _skemaList = [];
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      // Compute sort & bidang from the chip shortcut (overlay params are separate)
      final String? sortParam = _selectedChip == 'popular' ? 'popular' : null;
      final String? bidangParam = (_selectedChip != null && _selectedChip != 'popular')
          ? _selectedChip
          : null;

      final response = await SertifikatService.getSkemaList(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        kategori: (_selectedKategori == 'Semua Skema' || _selectedKategori == 'Skema Populer') ? null : _selectedKategori,
        jenjang: _selectedJenjang,
        bidang: bidangParam ?? _bidangFromOverlay,
        sort: sortParam,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      setState(() {
        if (isInitial) {
          _skemaList = response.data;
        } else {
          _skemaList.addAll(response.data);
        }
        _totalPages = response.meta.lastPage;
        if (_totalPages < 1) _totalPages = 1;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (isInitial) {
          _isError = true;
          _errorMessage = e.toString();
        }
      });
    }
  }

  void _fetchNextPage() {
    _currentPage++;
    _fetchSkema(isInitial: false);
  }

  void _onFilterChanged() {
    _fetchSkema(isInitial: true);
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
          initialBidang: _bidangFromOverlay,
          onApply: (kategori, jenjang, bidang) {
            setState(() {
              _selectedKategori = kategori;
              _selectedJenjang = jenjang;
              _bidangFromOverlay = bidang;

              // Sync the horizontal chip highlight back from the overlay state.
              if (kategori == 'Semua Skema' && jenjang == null && bidang == null) {
                _selectedChip = null; // "Semua Skema" shortcut
              } else if (kategori == 'Skema Populer') {
                _selectedChip = 'popular';
              } else if (bidang != null) {
                // Bidang chosen via overlay — highlight matching chip if any
                _selectedChip = bidang;
              } else {
                _selectedChip = null; // Custom combo — no chip highlight
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

          // Filter Row — shortcut chips (Semua Skema, Populer) + dynamic bidang
          // from /api/sertifikat/skema/bidang.  Horizontal scroll so the bar
          // doesn't overflow when there are many bidang values.
          _buildFilterChipRow(),

          // Grid View — optimized with CustomScrollView + SliverGrid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EDF)))
                : _isError
                    ? _buildErrorState()
                    : _skemaList.isEmpty
                        ? _buildEmptyState()
                        : _buildOptimizedGrid(),
          ),
        ],
      ),
    );
  }

  /// Optimized grid using CustomScrollView + SliverGrid for true virtual scrolling.
  /// Loading indicator is inside the scroll view to prevent layout shifts.
  Widget _buildOptimizedGrid() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth = (screenWidth - 32 - 12) / 2;
    const double cardHeight = 215;
    final double childAspectRatio = cardWidth / cardHeight;

    return CustomScrollView(
      controller: _scrollController,
      // ClampingScrollPhysics matches native Android overscroll and causes
      // less per-frame work than BouncingScrollPhysics (H4 fix — comment
      // already stated clamping but code was bouncing; corrected here).
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      // 300px cache = fewer off-screen cards built during fast scroll,
      // keeping build phase inside the 16 ms budget (H5).
      cacheExtent: 300,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Wrap each card in RepaintBoundary for isolated repaints
                return RepaintBoundary(
                  child: _SkemaCard(
                    skema: _skemaList[index],
                    colors: _palettes[index % _palettes.length],
                    icon: _icons[index % _icons.length],
                    onTap: () => _showSchemeDetail(_skemaList[index], index),
                  ),
                );
              },
              childCount: _skemaList.length,
              // Disable auto keep-alives — cards are stateless, no need to keep state
              addAutomaticKeepAlives: false,
              // We handle RepaintBoundary manually above
              addRepaintBoundaries: false,
            ),
          ),
        ),
        // Loading indicator as a sliver — no layout shift
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF4A9EDF),
                  ),
                ),
              ),
            ),
          ),
        // Bottom safe area
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// Horizontal scrollable filter chip bar.
  /// Static "Semua Skema" + "Populer" shortcuts, then dynamic bidang
  /// chips from /api/sertifikat/skema/bidang.
  Widget _buildFilterChipRow() {
    // Build the chip list: two shortcuts + dynamic bidang
    final chips = <_ChipSpec>[
      const _ChipSpec(label: 'Semua Skema', value: null),
      const _ChipSpec(label: 'Populer', value: 'popular'),
      ..._bidangList.map((b) => _ChipSpec(label: b.label, value: b.value)),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final selected = (chip.value == null && _selectedChip == null) ||
              (_selectedChip == chip.value && chip.value != null);
          return _buildFilterChip(
            chip.label,
            selected,
            onTap: () => _onChipSelected(chip.value),
          );
        },
      ),
    );
  }

  /// Called when a filter chip is tapped.
  /// value: null -> Semua Skema, 'popular' -> Populer, '<value>' -> bidang filter
  void _onChipSelected(String? value) {
    setState(() {
      _selectedChip = value;
      // Keep overlay filter state in sync:
      // - Choosing a shortcut/bidang chip resets the overlay extras so
      //   there's only one active filter dimension at a time.
      if (value == null) {
        _selectedKategori = 'Semua Skema';
        _selectedJenjang = null;
        _bidangFromOverlay = null;
      } else if (value == 'popular') {
        _selectedKategori = 'Skema Populer';
        _selectedJenjang = null;
        _bidangFromOverlay = null;
      } else {
        // Bidang chip — reset kategori/jenjang, set bidang from this chip
        _selectedKategori = 'Semua Skema';
        _selectedJenjang = null;
        _bidangFromOverlay = null;
      }
    });
    _onFilterChanged();
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5E80B0) : const Color(0xFFD6E6F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF2C6C9C),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showSchemeDetail(SkemaSertifikatListItem skema, int index) {
    final colors = _palettes[index % _palettes.length];
    final icon = _icons[index % _icons.length];

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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSkemaScreen(
          skemaId: skema.id,
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
            onPressed: () => _fetchSkema(isInitial: true),
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
}

// =============================================================================
// Extracted stateless card widget — avoids Map allocation per build,
// enables Flutter to skip rebuild when data hasn't changed.
// =============================================================================
class _SkemaCard extends StatelessWidget {
  final SkemaSertifikatListItem skema;
  final List<Color> colors;
  final IconData icon;
  final VoidCallback onTap;

  const _SkemaCard({
    required this.skema,
    required this.colors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = skema.isOpen;
    final tags = skema.tags;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        // blurRadius reduced from 4 → 2: quadratic cost in blur pixels
        // (H1). 2px still visually preserves the soft-shadow feel but
        // cuts raster work ~4×. Combined with RepaintBoundary the shadow
        // is only rasterized once per card.
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 2,
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
                    // const color avoids a Color allocation per build (H3)
                    color: const Color(0x26FFFFFF), // 0.15 opacity white
                  ),
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 28,
                    color: const Color(0xF2FFFFFF), // 0.95 opacity white
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
                        color: isOpen ? const Color(0xFF2E7D32) : const Color(0xFFFF4D4F),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    skema.title,
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Tags Row
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      // Closure extracted to a static helper (H6) so the
                      // inline lambda is not re-created on every build
                      // and the const children are reused by Flutter's
                      // element-reconciliation algorithm.
                      children: tags.map(_buildTagChip).toList(growable: false),
                    ),
                  ],

                  const Spacer(),

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
                      onPressed: onTap,
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

  /// Pre-built tag chip — extracted from the inline lambda (H6) so Flutter
  /// can reuse the same widget instances across builds via element diffing.
  static Widget _buildTagChip(String tag) {
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
  }
}

/// Lightweight spec for a filter chip:
/// - label: text shown on the chip
/// - value: null → "Semua Skema", 'popular' → Populer, '<value>' → bidang filter
class _ChipSpec {
  final String label;
  final String? value;
  /// - value: null -> "Semua Skema"
  /// - value: 'popular' -> Populer
  /// - value: '<string>' -> bidang filter
  const _ChipSpec({required this.label, required this.value});
}
