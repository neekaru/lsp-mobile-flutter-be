import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../models/dashboard_models.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class MasaBerlakuAsesorDetailScreen extends StatefulWidget {
  final String statusFilter; // 'tenggang' or 'expired'
  final int count;

  const MasaBerlakuAsesorDetailScreen({
    super.key,
    required this.statusFilter,
    required this.count,
  });

  @override
  State<MasaBerlakuAsesorDetailScreen> createState() =>
      _MasaBerlakuAsesorDetailScreenState();
}

class _MasaBerlakuAsesorDetailScreenState
    extends State<MasaBerlakuAsesorDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  static const int _pageSize = 50;
  List<MasaBerlakuAsesorDetailItem> _asesorList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  late int _totalCount;

  bool get _isTenggang => widget.statusFilter.toLowerCase() == 'tenggang';

  Color get _themeColor =>
      _isTenggang ? const Color(0xFFD97706) : const Color(0xFFDC2626);
  Color get _bgBadgeColor =>
      _isTenggang ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2);
  IconData get _statusIcon =>
      _isTenggang ? Icons.warning_amber_rounded : Icons.cancel_outlined;

  String get _displayTitle =>
      _isTenggang ? 'Asesor Masa Tenggang' : 'Asesor Expired';

  @override
  void initState() {
    super.initState();
    _totalCount = widget.count;
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _fetchData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 250) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _loadMore();
      }
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });

    try {
      final result = await DashboardService.getMasaBerlakuAsesorDetail(
        status: widget.statusFilter,
        search: _searchController.text.trim(),
        limit: _pageSize,
        offset: 0,
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _asesorList = result.asesorList;
          _totalCount = result.totalCount > 0 ? result.totalCount : result.asesorList.length;
          _hasMore = _asesorList.length < _totalCount;
          _isLoading = false;
        });
      } else {
        setState(() {
          _asesorList = [];
          _totalCount = 0;
          _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _asesorList = [];
        _hasMore = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextOffset = _asesorList.length;
      final result = await DashboardService.getMasaBerlakuAsesorDetail(
        status: widget.statusFilter,
        search: _searchController.text.trim(),
        limit: _pageSize,
        offset: nextOffset,
      );

      if (!mounted) return;

      if (result != null && result.asesorList.isNotEmpty) {
        setState(() {
          _asesorList.addAll(result.asesorList);
          if (result.totalCount > 0) _totalCount = result.totalCount;
          _hasMore = _asesorList.length < _totalCount;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasMore = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: _displayTitle,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKpiCard(),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          _buildListHeader(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  else if (_asesorList.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList.builder(
                        itemCount: _asesorList.length,
                        itemBuilder: (context, index) {
                          return _buildAsesorCard(_asesorList[index]);
                        },
                      ),
                    ),
                    if (_isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        ),
                      )
                    else if (!_hasMore && _asesorList.length >= 10)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24, top: 8),
                          child: Center(
                            child: Text(
                              'Semua asesor telah dimuat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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

  Widget _buildKpiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _themeColor.withAlpha(50)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _themeColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_statusIcon, color: _themeColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _themeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isTenggang
                      ? 'Asesor dengan masa berlaku kurang dari 3 bulan'
                      : 'Asesor dengan sertifikat telah expired/habis masa berlaku',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _bgBadgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalCount Asesor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: _themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari nama asesor, MET, skema, atau kota...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () {
                  _searchController.clear();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    final countLabel = _totalCount > _asesorList.length
        ? 'Daftar Asesor (${_asesorList.length} dari $_totalCount)'
        : 'Daftar Asesor ($_totalCount)';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          countLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        if (_searchController.text.isNotEmpty)
          GestureDetector(
            onTap: () {
              _searchController.clear();
            },
            child: Text(
              'Reset Pencarian',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _themeColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAsesorCard(MasaBerlakuAsesorDetailItem item) {
    final names = item.namaAsesor.trim().split(' ');
    String initials = 'A';
    if (names.isNotEmpty && names[0].isNotEmpty) {
      initials = names[0][0].toUpperCase();
      if (names.length > 1 && names[1].isNotEmpty) {
        initials += names[1][0].toUpperCase();
      }
    }

    final int sisaHari = item.sisaHari;
    final String labelSisaHari = sisaHari > 0
        ? '$sisaHari hari lagi'
        : (sisaHari < 0 ? '${-sisaHari} hari lewat' : 'Expired hari ini');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isTenggang
                        ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                        : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaAsesor,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'No. MET: ${item.noMet}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _bgBadgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labelSisaHari,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _themeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: _themeColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Tgl Expired: ${item.tanggalExpired}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (item.skemaKeahlian.isNotEmpty && item.skemaKeahlian != '-') ...[
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.skemaKeahlian,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (item.kabupatenKota.isNotEmpty || item.provinsi.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.kabupatenKota.isNotEmpty && item.provinsi.isNotEmpty
                        ? '${item.kabupatenKota}, ${item.provinsi}'
                        : (item.kabupatenKota.isNotEmpty
                            ? item.kabupatenKota
                            : item.provinsi),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if ((item.email.isNotEmpty && item.email != '-') ||
              (item.noHp.isNotEmpty && item.noHp != '-')) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (item.email.isNotEmpty && item.email != '-') ...[
                  const Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (item.noHp.isNotEmpty && item.noHp != '-') ...[
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.noHp,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 48,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            'Asesor Tidak Ditemukan',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _searchController.text.isNotEmpty
                ? 'Tidak ada asesor yang cocok dengan "${_searchController.text}".'
                : 'Belum ada data asesor untuk status ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset Pencarian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
