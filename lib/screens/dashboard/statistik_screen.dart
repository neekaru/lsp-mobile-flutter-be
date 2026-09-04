import 'package:material_ui/material_ui.dart';
import '../../utils/bps_code_helper.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../models/jadwal_models.dart';
import '../../widgets/statistik/indonesia_map.dart';
import '../../widgets/statistik/wilayah_detail_inline_card.dart';
import '../../widgets/statistik/statistik_app_bar.dart';
import '../../widgets/statistik/admin_statistik_baru.dart';
import '../../widgets/statistik/running_jadwal_card.dart';
import '../../widgets/statistik/top_provinsi_card.dart';
import '../../widgets/statistik/asesor_metrics_card.dart';
import '../../widgets/statistik/skema_metrics_card.dart';
import '../../widgets/statistik/skema_filter_header.dart';
import '../../widgets/statistik/all_skemas_list_card.dart';

class StatistikScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const StatistikScreen({super.key, this.onBackToHome});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  @override
  Widget build(BuildContext context) {
    return AdminStatistikBaru(
      onBackToHome: widget.onBackToHome,
    );
  }
}

class StatistikDistribusiView extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final ValueChanged<String>? onSwitchView;

  const StatistikDistribusiView({
    super.key,
    this.onBackToHome,
    this.onSwitchView,
  });

  @override
  State<StatistikDistribusiView> createState() =>
      _StatistikDistribusiViewState();
}

class _StatistikDistribusiViewState extends State<StatistikDistribusiView> {
  bool _isActiveAsesorSelected = true;
  String? _selectedProvinceId;
  String? _selectedProvinceName;
  late Future<AsesorStats> _asesorStatsFuture;
  late Future<List<TopProvinsi>> _topProvincesFuture;
  late Future<List<JadwalItem>> _runningJadwalsFuture;

  List<SebaranSkemaAsesorItem> _sebaranSkemaAsesorList = [];
  bool _isSebaranSkemaAsesorLoading = false;
  SebaranSkemaAsesorItem? _selectedSkema;
  String _skemaSearchQuery = '';


  SebaranSkemaAsesorItem? _cachedSkemaForMap;
  Map<String, int>? _cachedSkemaMapData;

  Map<String, int> _getSkemaMapData(SebaranSkemaAsesorItem? skema) {
    if (skema == null) {
      _cachedSkemaForMap = null;
      _cachedSkemaMapData = const {};
      return const {};
    }
    if (identical(skema, _cachedSkemaForMap) && _cachedSkemaMapData != null) {
      return _cachedSkemaMapData!;
    }
    final Map<String, int> mapData = {};
    for (var detail in skema.wilayahDetail) {
      final code = BpsCodeHelper.mapCodeFromProvinsiId(detail.provinsiId);
      if (code != null) {
        mapData[code] = detail.jumlahAsesor;
      }
    }
    _cachedSkemaForMap = skema;
    _cachedSkemaMapData = mapData;
    return mapData;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _asesorStatsFuture = ApiService.getAsesorStats();
    _topProvincesFuture = ApiService.getTopProvinces();
    _runningJadwalsFuture = ApiService.getJadwalList(statusJadwal: "3");

    _isSebaranSkemaAsesorLoading = true;
    ApiService.getSebaranSkemaAsesor().then((value) {
      if (mounted) {
        setState(() {
          _sebaranSkemaAsesorList = value;
          _isSebaranSkemaAsesorLoading = false;
          if (value.isNotEmpty) {
            _selectedSkema = value.first;
          }
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isSebaranSkemaAsesorLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        color: const Color(0xFF2C6C9C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: statusBarHeight + 8),

              // 1. Custom App Bar
              _buildAppBar(),

              // 2. Switching Tab Bar
              _buildTabBar(),

              // 3. Dynamic Metrics Cards Layout based on active tab
              _isActiveAsesorSelected
                  ? AsesorMetricsCard(asesorStatsFuture: _asesorStatsFuture)
                  : SkemaMetricsCard(
                      isLoading: _isSebaranSkemaAsesorLoading,
                      sebaranSkemaAsesorList: _sebaranSkemaAsesorList,
                      selectedSkema: _selectedSkema,
                      searchQuery: _skemaSearchQuery,
                      onSelectSkema: (val) {
                        setState(() {
                          _selectedSkema = val;
                        });
                      },
                    ),

              // 3.5 Lateness Tracker for Asesor Aktif tab
              if (_isActiveAsesorSelected)
                RunningJadwalCard(
                  runningJadwalsFuture: _runningJadwalsFuture,
                ),

              // 4. Additional search & date picker inputs specifically for Sebaran Skema
              if (!_isActiveAsesorSelected)
                SkemaFilterHeader(
                  onSearchChanged: (value) {
                    setState(() {
                      _skemaSearchQuery = value;
                    });
                  },
                ),

              const SizedBox(height: 16),

              // 5. Peta Penyebaran Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _isActiveAsesorSelected
                      ? 'Peta Penyebaran Asesor'
                      : 'Sebaran Asesor berdasarkan Skema',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 6. Interactive choropleth map
              IndonesiaMap(
                provinceData: _isActiveAsesorSelected
                    ? null
                    : _getSkemaMapData(_selectedSkema),
                onIslandSelected: (islandId) {
                  debugPrint('Island selected: $islandId');
                },
                onProvinceSelected: (province) {
                  debugPrint(
                      'Province selected: ${province.name} (ID: ${province.id})');
                  setState(() {
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: WilayahDetailInlineCard(
                    provinceId: _selectedProvinceId!,
                    provinceName: _selectedProvinceName!,
                    onClose: () {
                      setState(() {
                        _selectedProvinceId = null;
                        _selectedProvinceName = null;
                      });
                    },
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // 7. Dynamic Top 5 Cards at bottom based on active tab
              _isActiveAsesorSelected
                  ? TopProvinsiCard(topProvincesFuture: _topProvincesFuture)
                  : AllSkemasListCard(
                      sebaranSkemaAsesorList: _sebaranSkemaAsesorList,
                      isLoading: _isSebaranSkemaAsesorLoading,
                      searchQuery: _skemaSearchQuery,
                      onSelectSkema: (item) {
                        setState(() {
                          _selectedSkema = item;
                        });
                      },
                    ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return StatistikAppBar(
      title: 'Distribusi Asesor & Skema',
      currentView: 'distribusi',
      onBack: () {
        if (widget.onBackToHome != null) {
          widget.onBackToHome!();
        } else {
          Navigator.of(context).pop();
        }
      },
      onSwitchView: (value) {
        if (widget.onSwitchView != null) {
          widget.onSwitchView!(value);
        }
      },
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isActiveAsesorSelected = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isActiveAsesorSelected
                        ? const Color(0xFF768CA7)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Asesor Aktif',
                    style: TextStyle(
                      color: _isActiveAsesorSelected
                          ? Colors.white
                          : const Color(0xFF5F6E7D),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isActiveAsesorSelected = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isActiveAsesorSelected
                        ? const Color(0xFF768CA7)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sebaran Skema',
                    style: TextStyle(
                      color: !_isActiveAsesorSelected
                          ? Colors.white
                          : const Color(0xFF5F6E7D),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
