import 'package:material_ui/material_ui.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../utils/bps_code_helper.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'indonesia_map.dart';
import 'island_data.dart';
import 'detail_breakdown_card.dart';
import 'wilayah_detail_inline_card.dart';
import 'statistics_menu_accordion.dart';
import 'statistik_menu_grid.dart';
import 'admin_kpi_row.dart';
import 'skema_wilayah_card.dart';

import '../../screens/statistik/statistik_detail_screen.dart';

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

  Map<String, IslandData> _islandDataMap = {};
  Map<String, int> _provinceMapData = {};
  IslandData? _selectedIsland;
  String? _selectedProvinceId;
  String? _selectedProvinceName;

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
        ApiService.getPenyebaranRegional(),
        ApiService.getDomisiliAsesor(),
      ]);

      if (mounted) {
        final regional = results[3] as List<RegionalDistribution>;
        final domisili = results[4] as DomisiliAsesorData?;
        final islandMap = islandDataFromApi(regional);

        final Map<String, int> provData = {};
        if (domisili != null) {
          for (var item in domisili.items) {
            final code = BpsCodeHelper.mapCodeFromProvinsiId(item.provinsiId);
            if (code != null) {
              provData[code] = item.totalAsesor;
            }
          }
        }

        setState(() {
          _overview = results[0] as StatistikOverview;
          _asesorStats = results[1] as AsesorStats;
          _topProvinces = results[2] as List<TopProvinsi>;

          _islandDataMap = islandMap;
          _provinceMapData = provData;
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
                rightWidget: Theme(
                  data: Theme.of(context).copyWith(
                    dividerTheme: const DividerThemeData(
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 3,
                    onSelected: _handleStatisticsMenuSelection,
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        enabled: false,
                        padding: EdgeInsets.zero,
                        child: SizedBox(
                          width: 280,
                          child: StatisticsMenuAccordion(
                            onSelected: _handleStatisticsMenuSelection,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                          AdminKpiRow(stats: stats, overview: data),
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
                            provinceData: _provinceMapData.isNotEmpty
                                ? _provinceMapData
                                : null,
                            onIslandSelected: (islandId) {
                              setState(() {
                                _selectedProvinceId = null;
                                _selectedProvinceName = null;
                                if (_selectedIsland?.id == islandId) {
                                  _selectedIsland = null;
                                } else {
                                  _selectedIsland = _islandDataMap[islandId];
                                }
                              });
                            },
                            onProvinceSelected: (province) {
                              setState(() {
                                _selectedIsland = null;
                                if (_selectedProvinceId == province.id) {
                                  _selectedProvinceId = null;
                                  _selectedProvinceName = null;
                                } else {
                                  _selectedProvinceId = province.id;
                                  _selectedProvinceName = province.name;
                                }
                              });
                            },
                          ),
                          if (_selectedProvinceId != null &&
                              _selectedProvinceName != null) ...[
                            const SizedBox(height: 12),
                            WilayahDetailInlineCard(
                              provinceId: _selectedProvinceId!,
                              provinceName: _selectedProvinceName!,
                              onClose: () {
                                setState(() {
                                  _selectedProvinceId = null;
                                  _selectedProvinceName = null;
                                });
                              },
                            ),
                          ],
                          if (_selectedIsland != null) ...[
                            const SizedBox(height: 8),
                            DetailBreakdownCard(selectedData: _selectedIsland!),
                          ],
                          const SizedBox(height: 16),

                          // 4. Section: Menu Button Grid (Asesor Kompetensi, Skema, Pemegang Sertifikat)
                          const StatistikMenuGrid(),
                          const SizedBox(height: 16),

                          // 5. Section: Skema/Wilayah Asesor Card
                          SkemaWilayahCard(topProvinces: _topProvinces),
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

  void _handleStatisticsMenuSelection(String value) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatistikDetailScreen(menuKey: value),
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
}
