import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';

class AsesorHomebaseScreen extends StatefulWidget {
  const AsesorHomebaseScreen({super.key});

  @override
  State<AsesorHomebaseScreen> createState() => _AsesorHomebaseScreenState();
}

class _AsesorHomebaseScreenState extends State<AsesorHomebaseScreen> {
  static const int _pageSize = 40;

  List<AsesorHomebase> _allItems = const [];
  List<AsesorHomebase> _visibleItems = const [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || _visibleItems.length >= _allItems.length) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final list = await ApiService.getAsesorHomebase();
      if (!mounted) return;
      setState(() {
        _allItems = list;
        _visibleItems = list.take(_pageSize).toList(growable: false);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _loadMore() {
    if (_isLoadingMore || _visibleItems.length >= _allItems.length) return;
    setState(() => _isLoadingMore = true);

    final nextEnd = (_visibleItems.length + _pageSize).clamp(0, _allItems.length);
    final next = _allItems.sublist(0, nextEnd);

    setState(() {
      _visibleItems = next;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Asessor Berdasarkan Homebase',
            onBack: () => Navigator.of(context).pop(),
            rightWidget: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black87),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data Asesor',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_allItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'Tidak ada data asesor berdasarkan homebase.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    final showFooter = _visibleItems.length < _allItems.length || _isLoadingMore;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        // ignore: deprecated_member_use
        cacheExtent: 800,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        padding: const EdgeInsets.all(16),
        itemCount: _visibleItems.length + 1 + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Daftar Asessor Berdasarkan Homebase (${_allItems.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          }

          final itemIndex = index - 1;
          if (itemIndex >= _visibleItems.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final item = _visibleItems[itemIndex];
          return RepaintBoundary(
            child: _AsesorHomebaseTile(
              key: ValueKey('homebase_${item.name}_$itemIndex'),
              item: item,
            ),
          );
        },
      ),
    );
  }
}

class _AsesorHomebaseTile extends StatelessWidget {
  final AsesorHomebase item;

  const _AsesorHomebaseTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = item.scheme.isNotEmpty ? item.scheme : '-';
    final homebase = item.homebase.isNotEmpty ? item.homebase : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isNotEmpty ? item.name : '-',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.domain, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        scheme,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      homebase,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.assessments} Asesmen',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
