import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_models.dart';
import '../models/jadwal_models.dart';
import '../helpers/number_format_helper.dart';
import '../widgets/statistik/indonesia_map.dart';

class StatistikScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const StatistikScreen({super.key, this.onBackToHome});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  bool _isActiveAsesorSelected = true; // True for Asesor Aktif, False for Sebaran Skema
  late Future<AsesorStats> _asesorStatsFuture;
  late Future<List<TopProvinsi>> _topProvincesFuture;
  late Future<List<JadwalItem>> _runningJadwalsFuture;

  List<SebaranSkemaAsesorItem> _sebaranSkemaAsesorList = [];
  bool _isSebaranSkemaAsesorLoading = false;
  SebaranSkemaAsesorItem? _selectedSkema;
  String _skemaSearchQuery = '';

  static const Map<String, String> provinsiIdToMapCode = {
    "11": "IDAC", // Aceh
    "12": "IDSU", // Sumatera Utara
    "13": "IDSB", // Sumatera Barat
    "14": "IDRI", // Riau
    "15": "IDJA", // Jambi
    "16": "IDSS", // Sumatera Selatan
    "17": "IDBE", // Bengkulu
    "18": "IDLA", // Lampung
    "19": "IDBB", // Bangka Belitung
    "21": "IDKR", // Kepulauan Riau
    "31": "IDJK", // DKI Jakarta
    "32": "IDJB", // Jawa Barat
    "33": "IDJT", // Jawa Tengah
    "34": "IDYO", // DI Yogyakarta
    "35": "IDJI", // Jawa Timur
    "36": "IDBT", // Banten
    "51": "IDBA", // Bali
    "52": "IDNB", // Nusa Tenggara Barat
    "53": "IDNT", // Nusa Tenggara Timur
    "61": "IDKB", // Kalimantan Barat
    "62": "IDKT", // Kalimantan Tengah
    "63": "IDKS", // Kalimantan Selatan
    "64": "IDKI", // Kalimantan Timur
    "65": "IDKU", // Kalimantan Utara
    "71": "IDSA", // Sulawesi Utara
    "72": "IDST", // Sulawesi Tengah
    "73": "IDSG", // Sulawesi Selatan
    "74": "IDSN", // Sulawesi Tenggara
    "75": "IDGO", // Gorontalo
    "76": "IDSR", // Sulawesi Barat
    "81": "IDMA", // Maluku
    "82": "IDMU", // Maluku Utara
    "91": "IDPB", // Papua Barat
    "92": "IDPA", // Papua
  };

  Map<String, int> _getSkemaMapData(SebaranSkemaAsesorItem? skema) {
    if (skema == null) return {};
    final Map<String, int> mapData = {};
    for (var detail in skema.wilayahDetail) {
      final code = provinsiIdToMapCode[detail.provinsiId];
      if (code != null) {
        mapData[code] = detail.jumlahAsesor;
      }
    }
    return mapData;
  }

  void _showSkemaAsesorDetailDialog(BuildContext context, String skemaName, String provinceName, int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFF2C6C9C)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Detail Wilayah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skema:',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              skemaName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Provinsi:',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              provinceName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Jumlah Asesor:',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '$count Asesor',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C6C9C)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF2C6C9C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _asesorStatsFuture = ApiService.getAsesorStats();
    _topProvincesFuture = ApiService.getTopProvinces();
    _runningJadwalsFuture = ApiService.getJadwalList(statusJadwal: "2");
    
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
              _isActiveAsesorSelected ? _buildAsesorMetrics() : _buildSkemaMetrics(),

              // 3.5 Lateness Tracker for Asesor Aktif tab
              if (_isActiveAsesorSelected) _buildRunningJadwalCard(),

              // 4. Additional search & date picker inputs specifically for Sebaran Skema
              if (!_isActiveAsesorSelected) _buildDatePickerAndSearch(),

              const SizedBox(height: 16),

              // 5. Peta Penyebaran Title Header
              // 5. Peta Penyebaran Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _isActiveAsesorSelected ? 'Peta Penyebaran Asesor' : 'Sebaran Asesor berdasarkan Skema',
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
                provinceData: _isActiveAsesorSelected ? null : _getSkemaMapData(_selectedSkema),
                onIslandSelected: (islandId) {
                  debugPrint('Island selected: $islandId');
                },
                onProvinceSelected: (province) {
                  debugPrint('Province selected: ${province.name} (ID: ${province.id})');
                  if (_isActiveAsesorSelected) {
                    _showTUKDistributionBottomSheet(context, province.id, province.name);
                  } else {
                    if (_selectedSkema != null) {
                      final detail = _selectedSkema!.wilayahDetail.firstWhere(
                        (d) => d.provinsiId == province.id,
                        orElse: () => SkemaAsesorProvinsi(provinsiId: province.id, provinsiNama: province.name, jumlahAsesor: 0),
                      );
                      _showSkemaAsesorDetailDialog(context, _selectedSkema!.skema, province.name, detail.jumlahAsesor);
                    }
                  }
                },
              ),

              const SizedBox(height: 8),

              // 7. Dynamic Top 5 Cards at bottom based on active tab
              _isActiveAsesorSelected ? _buildTopProvinsiCard() : _buildAllSkemasListCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Black Back Arrow Button
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
          
          // Bold screen title
          const Text(
            'Distribusi Asesor & Skema',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          
          // More options horizontal ellipsis
          const Icon(
            Icons.more_horiz_rounded,
            color: Colors.black,
            size: 24,
          ),
        ],
      ),
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
                    color: _isActiveAsesorSelected ? const Color(0xFF768CA7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Asesor Aktif',
                    style: TextStyle(
                      color: _isActiveAsesorSelected ? Colors.white : const Color(0xFF5F6E7D),
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
                    color: !_isActiveAsesorSelected ? const Color(0xFF768CA7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sebaran Skema',
                    style: TextStyle(
                      color: !_isActiveAsesorSelected ? Colors.white : const Color(0xFF5F6E7D),
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

  // Active Advisor metrics layout (Enhanced with internal/external assessor breakdown, total TUK, online/offline status)
  Widget _buildAsesorMetrics() {
    return FutureBuilder<AsesorStats>(
      future: _asesorStatsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? AsesorStats.fallback();
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Total Asesor (Breakdown) & Total TUK
              Row(
                children: [
                  // Total Asesor Card with Breakdown
                  Expanded(
                    flex: 7,
                    child: Container(
                      height: 125,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Asesor',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5F6E7D),
                                ),
                              ),
                              if (!isLoading)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    data.trendTotalAsesor,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoading ? '...' : NumberFormatHelper.formatWithDots(data.totalAsesor),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          // Internal / External Breakdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2C6C9C),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('Internal', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLoading ? '...' : NumberFormatHelper.formatWithDots(data.asesorInternal),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53935),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('External', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLoading ? '...' : NumberFormatHelper.formatWithDots(data.asesorExternal),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Premium Segmented Progress Bar
                          if (!isLoading && data.totalAsesor > 0)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: SizedBox(
                                height: 4,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: data.asesorInternal,
                                      child: Container(color: const Color(0xFF2C6C9C)),
                                    ),
                                    Expanded(
                                      flex: data.asesorExternal,
                                      child: Container(color: const Color(0xFFE53935)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 4, child: LinearProgressIndicator(value: 0, backgroundColor: Color(0xFFECEFF1))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Total TUK Card
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 125,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.domain_rounded,
                              color: Color(0xFF009688),
                              size: 18,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Total TUK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5F6E7D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isLoading ? '...' : NumberFormatHelper.formatWithDots(data.totalTuk),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tempat Uji Kompetensi',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row 2: Status Asesmen Card (Online vs Offline)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status Asesmen',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C6C9C),
                          ),
                        ),
                        Icon(
                          Icons.insights_rounded,
                          size: 16,
                          color: Color(0xFF2C6C9C),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Online count
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.cloud_done_rounded,
                                  color: Color(0xFF4CAF50),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Online',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLoading ? '...' : NumberFormatHelper.formatWithDots(data.onlineAsesmen),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(width: 16),
                        // Offline count
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1FC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF2C6C9C),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Offline',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLoading ? '...' : NumberFormatHelper.formatWithDots(data.offlineAsesmen),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C6C9C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Segmented Bar for Online / Offline
                    if (!isLoading && (data.onlineAsesmen + data.offlineAsesmen) > 0)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 6,
                          child: Row(
                            children: [
                              Expanded(
                                flex: data.onlineAsesmen,
                                child: Container(color: const Color(0xFF4CAF50)),
                              ),
                              Expanded(
                                flex: data.offlineAsesmen,
                                child: Container(color: const Color(0xFF2C6C9C)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 6, child: LinearProgressIndicator(value: 0, backgroundColor: Color(0xFFECEFF1))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Beautiful Lateness Tracker Widget for Running Schedules
  Widget _buildRunningJadwalCard() {
    return FutureBuilder<List<JadwalItem>>(
      future: _runningJadwalsFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        // Filter only running schedules that are late
        final lateSchedules = items.where((item) => item.status == 'sedang_berjalan' && item.daysLate != null && item.daysLate! > 0).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Color(0xFFE53935),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Keterlambatan Jadwal Running',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (!isLoading && lateSchedules.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${lateSchedules.length} Jadwal',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C6C9C)),
                    ),
                  )
                else if (lateSchedules.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4CAF50), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Semua jadwal berjalan tepat waktu.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lateSchedules.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = lateSchedules[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.skema,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer_rounded, color: Color(0xFFE53935), size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Telat ${item.daysLate} Hari',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE53935),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.domain_rounded, color: Colors.grey, size: 13),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.tuk,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
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
                                const Icon(Icons.date_range_rounded, color: Colors.grey, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  'Selesai: ${item.tanggalSelesai}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Schema Sebaran metrics layout (Enhanced with dynamic Dropdown selector, assessor stats, and regional breakdown list)
  Widget _buildSkemaMetrics() {
    if (_isSebaranSkemaAsesorLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C6C9C)),
        ),
      );
    }

    if (_sebaranSkemaAsesorList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text('Tidak ada data skema yang disetujui.'),
        ),
      );
    }

    // Filter list for dropdown/selector search
    final filteredDropdownList = _sebaranSkemaAsesorList.where((item) {
      return item.skema.toLowerCase().contains(_skemaSearchQuery.toLowerCase()) ||
          item.kodeSkema.toLowerCase().contains(_skemaSearchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Dropdown selector for Scheme
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9ECF0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SebaranSkemaAsesorItem>(
                value: _selectedSkema != null && _sebaranSkemaAsesorList.contains(_selectedSkema) ? _selectedSkema : null,
                hint: const Text('Pilih Skema Sertifikasi', style: TextStyle(fontSize: 13, color: Colors.grey)),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFF2C6C9C), size: 20),
                items: filteredDropdownList.map((item) {
                  return DropdownMenuItem<SebaranSkemaAsesorItem>(
                    value: item,
                    child: Text(
                      '${item.skema} (${item.jumlahAsesor} Asesor)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSkema = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Scheme metrics cards
          if (_selectedSkema != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildSkemaMetricTile(
                    icon: Icons.people_outline_rounded,
                    iconColor: const Color(0xFF2C6C9C),
                    title: 'Jumlah Asesor',
                    value: '${_selectedSkema!.jumlahAsesor}',
                    subtitle: 'Terdaftar',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSkemaMetricTile(
                    icon: Icons.star_border_rounded,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Wilayah Terbanyak',
                    value: _selectedSkema!.wilayahTerbanyak,
                    subtitle: 'Konsentrasi',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Regional Breakdown List for the selected Scheme
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE9ECF0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lokasi/Wilayah Asesor Skema',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F1FC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_selectedSkema!.wilayahDetail.length} Provinsi',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2C6C9C)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_selectedSkema!.wilayahDetail.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          'Tidak ada data wilayah untuk skema ini.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedSkema!.wilayahDetail.length > 5 ? 5 : _selectedSkema!.wilayahDetail.length,
                      itemBuilder: (context, idx) {
                        final det = _selectedSkema!.wilayahDetail[idx];
                        double pct = _selectedSkema!.jumlahAsesor > 0 ? (det.jumlahAsesor / _selectedSkema!.jumlahAsesor * 100) : 0.0;
                        return _buildListItem(_ListModel(
                          name: det.provinsiNama,
                          value: '${det.jumlahAsesor} Asesor',
                          percentage: '${pct.toStringAsFixed(1).replaceAll('.', ',')}%',
                          color: const Color(0xFF2C6C9C),
                        ));
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllSkemasListCard() {
    // Filter schemes based on search query
    final filteredList = _sebaranSkemaAsesorList.where((item) {
      return item.skema.toLowerCase().contains(_skemaSearchQuery.toLowerCase()) ||
          item.kodeSkema.toLowerCase().contains(_skemaSearchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Sebaran Skema & Asesor',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (_isSebaranSkemaAsesorLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C6C9C)),
                ),
              )
            else if (filteredList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Tidak ada skema yang cocok dengan pencarian.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length > 8 ? 8 : filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.skema,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.kodeSkema,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F1FC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${item.jumlahAsesor} Asesor',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C6C9C),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedSkema = item;
                          });
                        },
                      ),
                      Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkemaMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5F6E7D),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8E99A4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerAndSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant date picker trigger button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE9ECF0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  'Juni 2026',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Search input bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xFFE9ECF0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _skemaSearchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atau kode skema...',
                      hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Active Advisor top 5 provinsi breakdown list card
  Widget _buildTopProvinsiCard() {
    return FutureBuilder<List<TopProvinsi>>(
      future: _topProvincesFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top 5 Provinsi (Asesor Aktif)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C6C9C)),
                    ),
                  )
                else
                  ...items.map((item) => _buildListItem(_ListModel(
                    name: item.name,
                    value: NumberFormatHelper.formatWithDots(item.value),
                    percentage: item.percentage,
                    color: const Color(0xFF0F4C81),
                  ))),
                const SizedBox(height: 16),
                _buildOutlineButton('Lihat Semua Provinsi'),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildListItem(_ListModel item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 48,
                child: Text(
                  item.percentage,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildOutlineButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE9ECF0), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: const Color(0xFFF9FAFB),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Interactive Bottom Sheet to display TUK sebaran on tapped provinces
  void _showTUKDistributionBottomSheet(BuildContext context, String provinceId, String provinceName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
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
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
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
                          color: Color(0xFF2C6C9C),
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada data penyebaran TUK di provinsi ini.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: data.length,
                      physics: const BouncingScrollPhysics(),
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return _TUKListItem(item: item);
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
}

class _ListModel {
  final String name;
  final String value;
  final String percentage;
  final Color color;

  _ListModel({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

// Optimized TUK List Item Widget
class _TUKListItem extends StatelessWidget {
  final TUKKabupaten item;

  const _TUKListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.detail.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.kabupaten,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.jumlah} TUK',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C6C9C),
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
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.jumlah} TUK',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C6C9C),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
          ],
        ),
        children: item.detail.map((tukName) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(Icons.domain_rounded, size: 12, color: Color(0xFF2C6C9C)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tukName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
