import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../models/asesor_dashboard_models.dart';
import '../../services/dashboard/dashboard_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'widgets/mitra_card.dart';

class AsesorMitraListScreen extends StatefulWidget {
  final List<AsesorMitra>? mitra;

  const AsesorMitraListScreen({super.key, this.mitra});

  @override
  State<AsesorMitraListScreen> createState() => _AsesorMitraListScreenState();
}

class _AsesorMitraListScreenState extends State<AsesorMitraListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AsesorMitra> _allMitra = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedStatus = 'Semua'; // 'Semua', 'Aktif', 'Menunggu', 'Selesai'
  int _activeMitraCount = 0;
  int _waitingMitraCount = 0;
  int _finishedMitraCount = 0;
  int _uniqueKotaCount = 0;

  void _recalculateMetrics() {
    int active = 0;
    int waiting = 0;
    int finished = 0;
    final kotas = <String>{};

    for (final m in _allMitra) {
      if (m.isAktif) active++;
      if (m.statusMitra == 0) waiting++;
      if (m.statusMitra == 2) finished++;
      final k = m.kota.trim().toLowerCase();
      if (k.isNotEmpty && k != '-') {
        kotas.add(k);
      }
    }

    _activeMitraCount = active;
    _waitingMitraCount = waiting;
    _finishedMitraCount = finished;
    _uniqueKotaCount = kotas.length;
  }
  @override
  void initState() {
    super.initState();
    if (widget.mitra != null) {
      _allMitra = List<AsesorMitra>.from(widget.mitra!);
      _recalculateMetrics();
    } else {
      _fetchMitraData();
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _fetchMitraData() async {
    setState(() => _isLoading = true);
    try {
      final dashboardData = await DashboardService.getAsesorDashboard();
      if (mounted) {
        setState(() {
          _allMitra = dashboardData.mitra;
          _recalculateMetrics();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error fetching asesor mitra data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<AsesorMitra> get _filteredMitra {
    return _allMitra.where((item) {
      // 1. Status Filter
      if (_selectedStatus != 'Semua') {
        if (item.statusLabel.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }

      // 2. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final nama = item.namaTuk.toLowerCase();
        final kota = item.kota.toLowerCase();
        final alamat = item.alamat.toLowerCase();
        final deskripsi = item.deskripsiMitra.toLowerCase();
        final proyeksi = item.proyeksiMitra.toLowerCase();
        final idStr = item.idTuk.toString();

        final match = nama.contains(_searchQuery) ||
            kota.contains(_searchQuery) ||
            alamat.contains(_searchQuery) ||
            deskripsi.contains(_searchQuery) ||
            proyeksi.contains(_searchQuery) ||
            idStr.contains(_searchQuery);

        if (!match) return false;
      }

      return true;
    }).toList();
  }

  int get _totalMitraCount => _allMitra.length;
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMitra;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            CustomAppBar(
              title: 'Daftar Mitra',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchMitraData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryBanner(),
                            const SizedBox(height: 16),
                            _buildSearchBar(),
                            const SizedBox(height: 12),
                            _buildFilterChips(),
                            const SizedBox(height: 16),
                            _buildListHeader(filtered.length),
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
                    else if (filtered.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: _buildEmptyState(),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        sliver: SliverList.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return MitraCard(
                              key: ValueKey(filtered[index].id),
                              mitra: filtered[index],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x202563EB),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jaringan Kemitraan TUK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kelola kemitraan Tempat Uji Kompetensi strategis',
                      style: TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildBannerMetricItem(
                    label: 'Total Mitra',
                    value: '$_totalMitraCount',
                    icon: Icons.domain_rounded,
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0x26FFFFFF)),
                Expanded(
                  child: _buildBannerMetricItem(
                    label: 'Mitra Aktif',
                    value: '$_activeMitraCount',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0x26FFFFFF)),
                Expanded(
                  child: _buildBannerMetricItem(
                    label: 'Kota/Wilayah',
                    value: '$_uniqueKotaCount',
                    icon: Icons.location_city_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerMetricItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF93C5FD)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFDBEAFE),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
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
                hintText: 'Cari mitra, TUK, kota, alamat...',
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

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'Semua', 'label': 'Semua', 'count': _totalMitraCount},
      {'key': 'Aktif', 'label': 'Aktif', 'count': _activeMitraCount},
      {'key': 'Menunggu', 'label': 'Menunggu', 'count': _waitingMitraCount},
      if (_finishedMitraCount > 0)
        {'key': 'Selesai', 'label': 'Selesai', 'count': _finishedMitraCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStatus == f['key'];
          final count = f['count'] as int;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStatus = f['key'] as String;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  ),
                  boxShadow: [
                    if (isSelected)
                      const BoxShadow(
                        color: Color(0x202563EB),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f['label'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0x33FFFFFF) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListHeader(int displayedCount) {
    final isFiltered = _searchQuery.isNotEmpty || _selectedStatus != 'Semua';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Daftar Mitra',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$displayedCount',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
        if (isFiltered)
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _selectedStatus = 'Semua';
              });
            },
            child: const Text(
              'Reset Filter',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _searchQuery.isNotEmpty || _selectedStatus != 'Semua';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.handshake_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isFiltered ? 'Mitra Tidak Ditemukan' : 'Belum Ada Mitra Terdaftar',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isFiltered
                ? 'Tidak ada mitra yang cocok dengan filter atau kata kunci pencarian "$_searchQuery".'
                : 'Daftar Tempat Uji Kompetensi yang bermitra dengan Anda akan muncul di sini.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          if (isFiltered) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedStatus = 'Semua';
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reset Pencarian'),
            ),
          ],
        ],
      ),
    );
  }
}

