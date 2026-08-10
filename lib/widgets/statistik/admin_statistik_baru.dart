import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../helpers/number_format_helper.dart';
import '../../widgets/custom_app_bar.dart';
import 'indonesia_map.dart';
import 'island_data.dart';
import 'detail_breakdown_card.dart';
import '../../screens/dashboard/distribusi_asesor_sertifikasi_screen.dart';
import '../../screens/dashboard/statistik_detail_screen.dart';

class AdminStatistikBaru extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AdminStatistikBaru({super.key, this.onBackToHome});

  @override
  State<AdminStatistikBaru> createState() => _AdminStatistikBaruState();
}



class _AdminStatistikBaruState extends State<AdminStatistikBaru> {
  bool _isLoading = true;

  // Cached API Data
  StatistikOverview? _overview;
  AsesorStats? _asesorStats;
  List<TopProvinsi> _topProvinces = [];
  List<AsesorHomebase> _homebaseList = [];
  Map<String, IslandData> _islandDataMap = {};
  IslandData? _selectedIsland;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        ApiService.getStatistikOverview(),
        ApiService.getAsesorStats(),
        ApiService.getTopProvinces(),
        ApiService.getAsesorHomebase(),
        ApiService.getPenyebaranRegional(),
      ]);

      if (mounted) {
        final homebase = results[3] as List<AsesorHomebase>;
        final regional = results[4] as List<RegionalDistribution>;
        final islandMap = islandDataFromApi(regional);
        setState(() {
          _overview = results[0] as StatistikOverview;
          _asesorStats = results[1] as AsesorStats;
          _topProvinces = results[2] as List<TopProvinsi>;
          // Preview only — full list lives on AsesorHomebaseScreen
          _homebaseList = homebase.length > 4
              ? homebase.sublist(0, 4)
              : homebase;
          _islandDataMap = islandMap;
          if (_selectedIsland != null) {
            _selectedIsland = islandMap[_selectedIsland!.id];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading admin statistics data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final data = _overview ?? StatistikOverview.fallback();
    final stats = _asesorStats ?? AsesorStats.fallback();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: const Color(0xFF2563EB),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: statusBarHeight + 8),

              // 1. App Bar
              CustomAppBar(
                title: 'Dashboard Statistik',
                onBack:
                    widget.onBackToHome ?? () => Navigator.of(context).pop(),
              ),

              _isLoading
                  ? _buildLoadingState()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Row of 3 KPI Cards
                          _buildKpiRow(stats, data),
                          const SizedBox(height: 16),

                          // 3. Section: Sebaran Wilayah Asessor/Skema
                          const Text(
                            'Sebaran Wilayah Asessor/Skema',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IndonesiaMap(
                            isAdminDashboard: true,
                            onIslandSelected: (islandId) {
                              setState(() {
                                if (_selectedIsland?.id == islandId) {
                                  _selectedIsland = null;
                                } else {
                                  _selectedIsland = _islandDataMap[islandId];
                                }
                              });
                            },
                            onProvinceSelected: (province) {
                              _showTUKDistributionBottomSheet(
                                context,
                                province.id,
                                province.name,
                              );
                            },
                          ),
                          if (_selectedIsland != null) ...[
                            const SizedBox(height: 8),
                            DetailBreakdownCard(selectedData: _selectedIsland!),
                          ],
                          const SizedBox(height: 16),

                          // 4. Section: Menu Button Grid (matches dropdown items)
                          _buildMenuButtonGrid(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3.0,
              color: Color(0xFF2563EB),
            ),
            SizedBox(height: 16),
            Text(
              'Menyinkronkan data statistik...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Row containing the 3 KPI Cards stretching to the same height
  Widget _buildKpiRow(AsesorStats stats, StatistikOverview overview) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildTotalAsesorCard(stats)),
          const SizedBox(width: 8),
          Expanded(child: _buildJumlahAsesiCard(overview)),
          const SizedBox(width: 8),
          Expanded(child: _buildTotalTukCard(stats)),
        ],
      ),
    );
  }

  Widget _buildTotalAsesorCard(AsesorStats stats) {
    final String valStr = NumberFormatHelper.formatWithDots(stats.totalAsesor);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DistribusiAsesorSertifikasiScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x03000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Total Asesor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F4C81),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    valStr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Terdaftar',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Internal',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Eksternal',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: stats.asesorInternal > 0
                          ? stats.asesorInternal
                          : 75,
                      child: Container(color: const Color(0xFF3B82F6)),
                    ),
                    Expanded(
                      flex: stats.asesorExternal > 0
                          ? stats.asesorExternal
                          : 25,
                      child: Container(color: const Color(0xFF10B981)),
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

  Widget _buildJumlahAsesiCard(StatistikOverview overview) {
    final String valStr = NumberFormatHelper.formatWithDots(
      overview.totalAsesi,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAD2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people,
                  color: Color(0xFFEA580C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Jumlah Asesi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F4C81),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valStr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Terdaftar',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTukCard(AsesorStats stats) {
    final String valStr = NumberFormatHelper.formatWithDots(stats.totalTuk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.domain,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Total TUK',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valStr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Tempat Uji Kompetensi',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtonGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuGroup(
          title: 'Asesor Kompetensi',
          items: [
            _MenuItem('domisili_asesor', 'Domisili Asesor', Icons.location_on_outlined, const Color(0xFF0284C7)),
            _MenuItem('kompetensi_teknis', 'Kompetensi Teknis', Icons.build_outlined, const Color(0xFF7C3AED)),
            _MenuItem('masa_berlaku', 'Masa Berlaku', Icons.event_outlined, const Color(0xFF059669)),
            _MenuItem('spt_2026', 'SPT 2026', Icons.assignment_ind_outlined, const Color(0xFFD97706)),
          ],
        ),
        const SizedBox(height: 6),
        _buildMenuGroup(
          title: 'Skema Sertifikasi',
          items: [
            _MenuItem('jenis_skema', 'Jenis Skema', Icons.schema_outlined, const Color(0xFF2563EB)),
            _MenuItem('muk', 'MUK', Icons.folder_open_outlined, const Color(0xFFDC2626)),
            _MenuItem('praktisi', 'Praktisi', Icons.people_outline, const Color(0xFF0891B2)),
          ],
        ),
        const SizedBox(height: 6),
        _buildMenuGroup(
          title: 'Pemegang Sertifikat',
          items: [
            _MenuItem('tahun_2026', 'Tahun 2026', Icons.calendar_today_outlined, const Color(0xFF16A34A)),
            _MenuItem('3_tahun', '3 Tahun', Icons.history_outlined, const Color(0xFF9333EA)),
            _MenuItem('kompetensi', 'Kompetensi', Icons.verified_outlined, const Color(0xFFEA580C)),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildMenuButton(items[index]),
        ),
      ],
    );
  }

  Widget _buildMenuButton(_MenuItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatistikDetailScreen(menuKey: item.value),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x03000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTUKDistributionBottomSheet(
    BuildContext context,
    String provinceId,
    String provinceName,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Penyebaran TUK: $provinceName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<TUKKabupaten>>(
                  future: ApiService.getTUKKabupaten(provinceId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF2563EB),
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada data penyebaran TUK di provinsi ini.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: data.length,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return _buildTukKabListItem(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTukKabListItem(TUKKabupaten item) {
    if (item.detail.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.kabupaten,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.jumlah} TUK',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        title: Text(
          item.kabupaten,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF334155),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.jumlah} TUK',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ],
        ),
        children: item.detail
            .map(
              (tukName) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tukName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MenuItem {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MenuItem(this.value, this.label, this.icon, this.color);
}
