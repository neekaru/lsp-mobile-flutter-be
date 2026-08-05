import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/jadwal_models.dart';
import '../../services/api_service.dart';
import '../../widgets/jadwal/jadwal_list_item.dart';
import '../../widgets/jadwal/custom_tab_bar.dart';
import '../../services/auth_repository.dart';
import '../../helpers/api_routes.dart';
import '../../helpers/date_format_helper.dart';
import 'jadwal_detail_screen.dart';

class JadwalScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const JadwalScreen({super.key, this.onBackToHome});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Pagination state
  bool _isLoadingMore = false;
  bool _hasMoreDraft = true;
  bool _hasMoreRunning = true;
  bool _hasMorePelaporan = true;
  bool _hasMoreSelesai = true;

  final int _pageSize = 20;

  // Mock user role - dalam implementasi nyata, ambil dari auth service
  UserRole get currentUser {
    final user = AuthRepository.currentUserInstance;
    return UserRole(
      role: user?.role ?? 'admin',
      name: user?.name ?? 'Admin User',
      email: user?.email ?? 'admin@lsp.com',
    );
  }

  // Data dari API
  List<JadwalItem> draftList = [];
  List<JadwalItem> runningList = [];
  List<JadwalItem> pelaporanList = [];
  List<JadwalItem> selesaiList = [];

  // Statistics from API
  JadwalStatistik? _statistik;
  int totalAsesmen = 0;
  String trendPercentage = '+0%';

  int get _draftBadgeCount => _statistik?.draft ?? draftList.length;
  int get _runningBadgeCount =>
      _statistik?.sedangBerjalan ?? runningList.length;
  int get _pelaporanBadgeCount => _statistik?.pelaporan ?? pelaporanList.length;
  int get _selesaiBadgeCount => _statistik?.selesai ?? selesaiList.length;

  // Scroll controllers for pagination
  final ScrollController _scrollControllerDraft = ScrollController();
  final ScrollController _scrollControllerRunning = ScrollController();
  final ScrollController _scrollControllerPelaporan = ScrollController();
  final ScrollController _scrollControllerSelesai = ScrollController();

  // Search state — hanya tab Selesai (request Roy: biar gak berat)
  // Kriteria: tanggal asesmen + TUK
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;
  bool _isSearchingSelesai = false;
  DateTime? _selectedDate;

  bool get _isAsesiRole => currentUser.role == 'asesi';
  bool get _isAsesorRole => currentUser.role == 'asesor';
  bool get _isAdminRole =>
      currentUser.role == 'admin' || (!_isAsesiRole && !_isAsesorRole);

  /// Index tab Selesai per role. Asesi tidak punya tab Selesai.
  int get _selesaiTabIndex {
    if (_isAsesiRole) return -1;
    if (_isAsesorRole) return 2; // Menunggu, Dibatalkan, Selesai
    return 3; // Admin: Draft, Running, Pelaporan, Selesai
  }

  bool get _isOnSelesaiTab =>
      _selesaiTabIndex >= 0 && _tabController.index == _selesaiTabIndex;

  /// Gabungan tanggal (dari date picker) + TUK (dari search bar) untuk fetch
  /// tab Selesai. Keduanya terpisah — pilih tanggal tidak mengisi search bar.
  String? get _selesaiSearchParam {
    final q = _searchQuery.trim();
    final dateStr = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : '';
    final combined = [dateStr, q].where((s) => s.isNotEmpty).join(' ').trim();
    return combined.isEmpty ? null : combined;
  }

  @override
  void initState() {
    super.initState();
    final bool isAsesi = _isAsesiRole;
    final bool isAdmin = _isAdminRole;
    _tabController = TabController(
      length: isAsesi ? 2 : (isAdmin ? 4 : 3),
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _loadJadwalData();

    // Setup scroll listeners for pagination
    _scrollControllerDraft.addListener(_onScrollDraft);
    _scrollControllerRunning.addListener(_onScrollRunning);
    _scrollControllerPelaporan.addListener(_onScrollPelaporan);
    _scrollControllerSelesai.addListener(_onScrollSelesai);
  }

  void _onTabChanged() {
    if (!mounted || _tabController.indexIsChanging) return;
    setState(() {}); // show/hide search bar when switching tabs
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollControllerDraft.dispose();
    _scrollControllerRunning.dispose();
    _scrollControllerPelaporan.dispose();
    _scrollControllerSelesai.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Debounce biar gak nembak API tiap ketik
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();
      if (query == _searchQuery) return;
      if (!mounted) return;
      setState(() {
        _searchQuery = query;
      });
      // Hanya reload tab Selesai — tab lain tidak ikut di-query ulang
      _reloadSelesaiOnly();
    });
  }

  /// Reset pencarian tab Selesai secara bersih
  void _resetSelesaiSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    if (!mounted) return;
    setState(() {
      _searchQuery = '';
      _selectedDate = null;
    });
    _reloadSelesaiOnly();
  }

  /// Filter client-side: tanggal (dari date picker) + TUK (dari search bar).
  /// Keduanya filter bersamaan (AND) — tidak saling timpa.
  List<JadwalItem> _filterSelesaiByTanggalDanTuk(List<JadwalItem> items) {
    final q = _searchQuery.trim().toLowerCase();
    final dateStr = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!).toLowerCase()
        : '';
    if (q.isEmpty && dateStr.isEmpty) return items;
    return items.where((item) {
      final tanggalMulai = item.tanggalMulai.toLowerCase();
      final tanggalSelesai = item.tanggalSelesai.toLowerCase();
      final tuk = item.tuk.toLowerCase();
      final formattedMulaiShort =
          DateFormatHelper.formatToShort(item.tanggalMulai).toLowerCase();
      final formattedMulaiIndo =
          DateFormatHelper.formatToIndonesian(item.tanggalMulai).toLowerCase();

      // Filter TUK: jika search bar diisi, item harus cocok
      final tukMatch = q.isEmpty ||
          tuk.contains(q) ||
          tanggalMulai.contains(q) ||
          tanggalSelesai.contains(q) ||
          formattedMulaiShort.contains(q) ||
          formattedMulaiIndo.contains(q);

      // Filter tanggal: jika date picker dipilih, item harus cocok
      final dateMatch = dateStr.isEmpty ||
          tanggalMulai.contains(dateStr) ||
          tanggalSelesai.contains(dateStr) ||
          formattedMulaiShort.contains(dateStr) ||
          formattedMulaiIndo.contains(dateStr);

      return tukMatch && dateMatch;
    }).toList();
  }

  Future<void> _reloadSelesaiOnly() async {
    if (_selesaiTabIndex < 0) return;
    if (!mounted) return;

    setState(() {
      _isSearchingSelesai = true;
      _hasMoreSelesai = true;
    });

    try {
      final bool isAsesi = _isAsesiRole;
      final bool isAsesor = _isAsesorRole;

      String status3 = '1';
      String path3 = isAsesi
          ? ApiRoutes.asesiJadwal
          : ApiRoutes.jadwalCompleted;
      if (isAsesor) {
        status3 = '1,4'; // Selesai & Pelaporan
        path3 = ApiRoutes.asesorJadwal;
      }

      final raw = await ApiService.getJadwalList(
        limit: _pageSize,
        statusJadwal: status3,
        search: _selesaiSearchParam,
        sortBy: 'tanggal',
        sortOrder: 'desc',
        customRoutePath: path3,
      );

      if (!mounted) return;
      setState(() {
        selesaiList = _sortJadwalList(_filterSelesaiByTanggalDanTuk(raw));
        _hasMoreSelesai = raw.length >= _pageSize;
        _isSearchingSelesai = false;
      });
    } catch (e) {
      debugPrint('🔴 Error reloading selesai search: $e');
      if (!mounted) return;
      setState(() {
        _isSearchingSelesai = false;
      });
    }
  }

  // Scroll listeners for pagination
  void _onScrollDraft() {
    if (_scrollControllerDraft.position.pixels >=
        _scrollControllerDraft.position.maxScrollExtent - 200) {
      _loadMoreDraft();
    }
  }

  void _onScrollRunning() {
    if (_scrollControllerRunning.position.pixels >=
        _scrollControllerRunning.position.maxScrollExtent - 200) {
      _loadMoreRunning();
    }
  }

  void _onScrollPelaporan() {
    if (_scrollControllerPelaporan.position.pixels >=
        _scrollControllerPelaporan.position.maxScrollExtent - 200) {
      _loadMorePelaporan();
    }
  }

  void _onScrollSelesai() {
    if (_scrollControllerSelesai.position.pixels >=
        _scrollControllerSelesai.position.maxScrollExtent - 200) {
      _loadMoreSelesai();
    }
  }

  Future<void> _loadJadwalData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasMoreDraft = true;
      _hasMoreRunning = true;
      _hasMorePelaporan = true;
      _hasMoreSelesai = true;
    });

    try {
      final bool isAsesi = currentUser.role == 'asesi';
      final bool isAsesor = currentUser.role == 'asesor';
      final bool isAdmin =
          currentUser.role == 'admin' || (!isAsesi && !isAsesor);

      // Custom parameters per role
      String status1 = isAsesi ? '0' : '3';
      String path1 = isAsesi ? ApiRoutes.asesiJadwal : ApiRoutes.jadwalActive;
      if (isAsesor) {
        status1 = '0'; // Menunggu
        path1 = ApiRoutes.asesorJadwal;
      }

      String status2 = isAsesi ? '3' : '4';
      String path2 = isAsesi
          ? ApiRoutes.asesiJadwal
          : ApiRoutes.jadwalCompleted;
      if (isAsesor) {
        status2 = '2'; // Dibatalkan
        path2 = ApiRoutes.asesorJadwal;
      }

      String status3 = '1';
      String path3 = isAsesi
          ? ApiRoutes.asesiJadwal
          : ApiRoutes.jadwalCompleted;
      if (isAsesor) {
        status3 = '1,4'; // Selesai & Pelaporan
        path3 = ApiRoutes.asesorJadwal;
      }

      // Fetch data untuk setiap tab secara parallel + statistics (badge)
      final listFutures = <Future<List<JadwalItem>>>[
        if (isAdmin)
          ApiService.getJadwalList(
            limit: _pageSize,
            statusJadwal: '0', // Draft only
            sortBy: 'tanggal',
            sortOrder: 'desc',
            customRoutePath: ApiRoutes.jadwalDraft,
          ),
        ApiService.getJadwalList(
          limit: _pageSize,
          statusJadwal: status1,
          sortBy: 'tanggal',
          sortOrder: 'desc',
          customRoutePath: path1,
        ),
        ApiService.getJadwalList(
          limit: _pageSize,
          statusJadwal: status2,
          sortBy: 'tanggal',
          sortOrder: 'desc',
          customRoutePath: path2,
        ),
        ApiService.getJadwalList(
          limit: _pageSize,
          statusJadwal: status3,
          search: _selesaiSearchParam,
          sortBy: 'tanggal',
          sortOrder: 'desc',
          customRoutePath: path3,
        ),
      ];

      final results = await Future.wait([
        Future.wait(listFutures),
        if (isAdmin) ApiService.getJadwalStatistics(),
      ]);

      if (!mounted) return;

      final lists = results[0] as List<List<JadwalItem>>;
      final stats = isAdmin ? results[1] as JadwalStatistik : null;

      setState(() {
        int resultIndex = 0;
        if (isAdmin) {
          final rawDraft = lists[resultIndex];
          draftList = _sortJadwalList(
            rawDraft.where((item) => item.isDraft).toList(),
          );
          _hasMoreDraft = rawDraft.length >= _pageSize;
          resultIndex++;
        }

        final rawRunning = lists[resultIndex];
        runningList = _sortJadwalList(
          (isAdmin || (!isAsesi && !isAsesor))
              ? rawRunning.where((item) => item.isRunning).toList()
              : rawRunning,
        );
        _hasMoreRunning = rawRunning.length >= _pageSize;
        resultIndex++;

        final rawPelaporan = lists[resultIndex];
        pelaporanList = _sortJadwalList(rawPelaporan);
        _hasMorePelaporan = rawPelaporan.length >= _pageSize;
        resultIndex++;

        final rawSelesai = lists[resultIndex];
        selesaiList = _sortJadwalList(
          _filterSelesaiByTanggalDanTuk(rawSelesai),
        );
        _hasMoreSelesai = rawSelesai.length >= _pageSize;

        _statistik = stats;
        totalAsesmen =
            stats?.totalJadwal ??
            (runningList.length +
                pelaporanList.length +
                selesaiList.length +
                draftList.length);
        trendPercentage = stats?.trendPercentage ?? trendPercentage;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading jadwal data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load more methods for pagination
  Future<void> _loadMoreDraft() async {
    if (_isLoadingMore || !_hasMoreDraft) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newData = await ApiService.getJadwalList(
        limit: _pageSize,
        offset: draftList.length,
        statusJadwal: '0',
        sortBy: 'tanggal',
        sortOrder: 'desc',
        customRoutePath: ApiRoutes.jadwalDraft,
      );

      if (!mounted) return;

      setState(() {
        if (newData.length < _pageSize) {
          _hasMoreDraft = false;
        }
        draftList.addAll(
          _sortJadwalList(newData.where((item) => item.isDraft).toList()),
        );
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading more draft data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreRunning() async {
    if (_isLoadingMore || !_hasMoreRunning) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final bool isAsesi = currentUser.role == 'asesi';
      final bool isAsesor = currentUser.role == 'asesor';
      final bool isAdmin =
          currentUser.role == 'admin' || (!isAsesi && !isAsesor);

      String status = isAsesi ? '0' : '3';
      String sortBy = 'tanggal';
      String path = isAsesi ? ApiRoutes.asesiJadwal : ApiRoutes.jadwalActive;

      if (isAsesor) {
        status = '0';
        path = ApiRoutes.asesorJadwal;
      }

      final newData = await ApiService.getJadwalList(
        limit: _pageSize,
        offset: runningList.length,
        statusJadwal: status,
        sortBy: sortBy,
        sortOrder: 'desc',
        customRoutePath: path,
      );

      if (!mounted) return;

      final filtered = isAdmin
          ? newData.where((item) => item.isRunning).toList()
          : newData;

      setState(() {
        if (newData.length < _pageSize) {
          _hasMoreRunning = false;
        }
        runningList.addAll(_sortJadwalList(filtered));
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading more running data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMorePelaporan() async {
    if (_isLoadingMore || !_hasMorePelaporan) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final bool isAsesi = currentUser.role == 'asesi';
      final bool isAsesor = currentUser.role == 'asesor';

      String status = isAsesi ? '3' : '4';
      String path = isAsesi ? ApiRoutes.asesiJadwal : ApiRoutes.jadwalCompleted;

      if (isAsesor) {
        status = '2'; // Dibatalkan
        path = ApiRoutes.asesorJadwal;
      }

      final newData = await ApiService.getJadwalList(
        limit: _pageSize,
        offset: pelaporanList.length,
        statusJadwal: status,
        sortBy: 'tanggal',
        sortOrder: 'desc',
        customRoutePath: path,
      );

      if (!mounted) return;

      setState(() {
        if (newData.length < _pageSize) {
          _hasMorePelaporan = false;
        }
        pelaporanList.addAll(_sortJadwalList(newData));
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading more pelaporan data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreSelesai() async {
    if (_isLoadingMore || !_hasMoreSelesai) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final bool isAsesi = currentUser.role == 'asesi';
      final bool isAsesor = currentUser.role == 'asesor';

      String status = isAsesor
          ? '1,4'
          : '1'; // Selesai; asesor = Selesai & Pelaporan
      String path = isAsesi ? ApiRoutes.asesiJadwal : ApiRoutes.jadwalCompleted;

      if (isAsesor) {
        path = ApiRoutes.asesorJadwal;
      }

      final newData = await ApiService.getJadwalList(
        limit: _pageSize,
        offset: selesaiList.length,
        statusJadwal: status,
        search: _selesaiSearchParam,
        sortBy: 'tanggal',
        sortOrder: 'desc',
        customRoutePath: path,
      );

      if (!mounted) return;

      setState(() {
        if (newData.length < _pageSize) {
          _hasMoreSelesai = false;
        }
        selesaiList.addAll(
          _sortJadwalList(_filterSelesaiByTanggalDanTuk(newData)),
        );
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('🔴 Error loading more selesai data: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Sort jadwal list by tanggal DESC, then by ID DESC for consistent ordering
  List<JadwalItem> _sortJadwalList(List<JadwalItem> items) {
    final sorted = List<JadwalItem>.from(items);
    sorted.sort((a, b) {
      // Primary sort: by tanggalMulai DESC (terbaru dulu)
      final dateCompare = b.tanggalMulai.compareTo(a.tanggalMulai);
      if (dateCompare != 0) return dateCompare;

      // Secondary sort: by ID DESC (ID lebih besar = data lebih baru)
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  Future<void> _selectDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _reloadSelesaiOnly();
    }
  }

  Widget _buildSearchAndDateRow() {
    final bool hasSelectedDate = _selectedDate != null;
    final String dateLabel = hasSelectedDate
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : 'Tanggal';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Search TextField container
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
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
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _onSearchChanged(val);
                      },
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Cari tanggal asesmen atau TUK',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_isSearchingSelesai) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ] else if (_searchQuery.isNotEmpty) ...[
                    GestureDetector(
                      onTap: _resetSelesaiSearch,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Date filter button
          GestureDetector(
            onTap: _selectDateFilter,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: hasSelectedDate
                    ? const Color(0xFFEFF6FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasSelectedDate
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFCBD5E1),
                  width: hasSelectedDate ? 1.5 : 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: hasSelectedDate
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: hasSelectedDate
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: hasSelectedDate
                          ? const Color(0xFF1E40AF)
                          : const Color(0xFF475569),
                    ),
                  ),
                  if (hasSelectedDate) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _resetSelesaiSearch,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadJadwalData();

    // Tampilkan feedback ke user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Header dengan style dari statistik_screen
          _buildAppBar(),

          // Search field & Date filter — hanya tab Selesai (tanggal asesmen + TUK)
          if (_isOnSelesaiTab) _buildSearchAndDateRow(),

          // Loading indicator
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: JadwalTabBar(
                controller: _tabController,
                draftCount: _draftBadgeCount,
                runningCount: _runningBadgeCount,
                pelaporanCount: _pelaporanBadgeCount,
                selesaiCount: _selesaiBadgeCount,
              ),
            ),

            // Tab Content with caching
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Draft (Only for Admin) — status_jadwal=0
                  if (currentUser.role == 'admin' ||
                      (currentUser.role != 'asesi' &&
                          currentUser.role != 'asesor'))
                    _JadwalTabContent(
                      key: const PageStorageKey('draft_tab'),
                      child: _buildJadwalList(
                        draftList,
                        'draft',
                        _scrollControllerDraft,
                        _hasMoreDraft,
                        showCreatedDate: true,
                      ),
                    ),

                  // Tab 1: Sedang Berjalan (Mendatang for Asesi)
                  _JadwalTabContent(
                    key: const PageStorageKey('sedang_berjalan_tab'),
                    child: _buildJadwalList(
                      runningList,
                      'running',
                      _scrollControllerRunning,
                      _hasMoreRunning,
                    ),
                  ),

                  // Tab 2: Berjalan (Pelaporan for Admin/Asesor)
                  _JadwalTabContent(
                    key: const PageStorageKey('pelaporan_tab'),
                    child: _buildJadwalList(
                      pelaporanList,
                      'sedang_berjalan',
                      _scrollControllerPelaporan,
                      _hasMorePelaporan,
                    ),
                  ),

                  // Tab 3: Selesai (Only for non-Asesi)
                  if (!_isAsesiRole)
                    _JadwalTabContent(
                      key: const PageStorageKey('selesai_tab'),
                      child: _buildJadwalList(
                        selesaiList,
                        'selesai',
                        _scrollControllerSelesai,
                        _hasMoreSelesai,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJadwalList(
    List<JadwalItem> items,
    String status,
    ScrollController controller,
    bool hasMore, {
    bool showCreatedDate = false,
  }) {
    if (items.isEmpty && !_isLoading) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 300,
            child: Center(
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
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: items.length + 1, // +1 for loading indicator
        itemBuilder: (context, index) {
          // Loading indicator at the end
          if (index == items.length) {
            if (_isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (!hasMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Tidak ada data lagi',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              );
            } else {
              return const SizedBox(height: 80);
            }
          }

          // List items
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index < items.length - 1 ? 8 : 0),
            child: JadwalListItem(
              key: ValueKey(item.id),
              item: item,
              showCreatedDate: showCreatedDate,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JadwalDetailScreen(jadwal: item, userRole: currentUser),
                  ),
                );

                // Refresh data if status was updated
                if (result == true) {
                  _loadJadwalData();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    final bool isAsesi = currentUser.role == 'asesi';
    final bool isAsesor = currentUser.role == 'asesor';

    return CustomAppBar(
      title: (isAsesi || isAsesor) ? 'Jadwal Saya' : 'Jadwal Asesmen',
      onBack: () {
        if (widget.onBackToHome != null) {
          widget.onBackToHome!();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

// Custom Painter untuk Mini Line Chart
class MiniLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Data points untuk line chart (simulasi data)
    final dataPoints = [0.3, 0.5, 0.4, 0.6, 0.8, 0.7, 0.9, 0.85, 1.0];

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

// ============================================================================
// Tab Content Wrapper with AutomaticKeepAlive
// ============================================================================
// Wrapper untuk keep tab state agar tidak re-render saat pindah tab
class _JadwalTabContent extends StatefulWidget {
  final Widget child;

  const _JadwalTabContent({super.key, required this.child});

  @override
  State<_JadwalTabContent> createState() => _JadwalTabContentState();
}

class _JadwalTabContentState extends State<_JadwalTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Must call super.build for AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
