import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../models/jadwal_models.dart';
import '../../models/sertifikat_models.dart';
import '../../helpers/number_format_helper.dart';
import '../../widgets/custom_app_bar.dart';

class DistribusiAsesorSertifikasiScreen extends StatefulWidget {
  final bool initialShowSebaranSkema;

  const DistribusiAsesorSertifikasiScreen({
    super.key,
    this.initialShowSebaranSkema = false,
  });

  @override
  State<DistribusiAsesorSertifikasiScreen> createState() => _DistribusiAsesorSertifikasiScreenState();
}

class _DistribusiAsesorSertifikasiScreenState extends State<DistribusiAsesorSertifikasiScreen> {
  late bool _isActiveAsesorSelected;
  bool _isLoading = true;

  // Futures for API data
  late Future<AsesorStats> _asesorStatsFuture;
  late Future<List<JadwalItem>> _runningJadwalsFuture;
  late Future<SertifikatApiResponse> _sertifikatPerSkemaFuture;

  // API Data caches
  AsesorStats? _asesorStats;
  List<JadwalItem> _runningJadwals = [];
  List<SertifikatDistribusi> _sertifikatPerSkema = [];

  @override
  void initState() {
    super.initState();
    _isActiveAsesorSelected = !widget.initialShowSebaranSkema;
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      _isLoading = true;
    });

    _asesorStatsFuture = ApiService.getAsesorStats();
    _runningJadwalsFuture = ApiService.getJadwalList(statusJadwal: "3");
    _sertifikatPerSkemaFuture = ApiService.getSertifikatPerSkema(limit: 50);

    Future.wait([
      _asesorStatsFuture,
      _runningJadwalsFuture,
      _sertifikatPerSkemaFuture,
    ]).then((results) {
      if (mounted) {
        setState(() {
          _asesorStats = results[0] as AsesorStats;
          _runningJadwals = results[1] as List<JadwalItem>;
          final certResponse = results[2] as SertifikatApiResponse;
          _sertifikatPerSkema = certResponse.data;
          _isLoading = false;
        });
      }
    }).catchError((e) {
      debugPrint('Error loading distributions data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final stats = _asesorStats ?? AsesorStats.fallback();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // 1. Standard custom header template with dynamic tab-based title
          CustomAppBar(
            title: _isActiveAsesorSelected 
                ? 'Distribusi Asessor & Sertifikasi' 
                : 'Distribusi Asessor & Skema',
            onBack: () => Navigator.of(context).pop(),
            rightWidget: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black87),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),

          // 2. Switch Tab Bar
          _buildTabBar(),

          // 3. Tab Body content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadAllData();
              },
              color: const Color(0xFF2563EB),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _isLoading 
                    ? _buildLoadingState() 
                    : (_isActiveAsesorSelected 
                        ? _buildAsesorAktifTab(stats) 
                        : _buildSebaranSkemaTab(stats)),
              ),
            ),
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
          color: const Color(0xFFE2E8F0),
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
                    color: _isActiveAsesorSelected ? const Color(0xFF475569) : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Asesor Aktif',
                    style: TextStyle(
                      color: _isActiveAsesorSelected ? Colors.white : const Color(0xFF64748B),
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
                    color: !_isActiveAsesorSelected ? const Color(0xFF475569) : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sebaran Skema',
                    style: TextStyle(
                      color: !_isActiveAsesorSelected ? Colors.white : const Color(0xFF64748B),
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

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
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
              'Memuat data distribusi...',
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

  // ============================================================================
  // TAB 1: Asesor Aktif
  // ============================================================================
  Widget _buildAsesorAktifTab(AsesorStats stats) {
    // Filter only running schedules that are late
    final lateSchedules = _runningJadwals
        .where((item) => item.status == 'running' && item.daysLate != null && item.daysLate! > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Row: Total Asesor & Total TUK
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card 1: Total Asesor
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x02000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
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
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stats.trendTotalAsesor,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormatHelper.formatWithDots(stats.totalAsesor),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      // Internal / External Breakdown labels
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
                                      color: const Color(0xFF3B82F6),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('Internal', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                NumberFormatHelper.formatWithDots(stats.asesorInternal),
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
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('External', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                NumberFormatHelper.formatWithDots(stats.asesorExternal),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          height: 4,
                          child: Row(
                            children: [
                              Expanded(
                                flex: stats.asesorInternal > 0 ? stats.asesorInternal : 75,
                                child: Container(color: const Color(0xFF3B82F6)),
                              ),
                              Expanded(
                                flex: stats.asesorExternal > 0 ? stats.asesorExternal : 25,
                                child: Container(color: const Color(0xFF10B981)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Card 2: Total TUK
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x02000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.domain_rounded,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Total TUK',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberFormatHelper.formatWithDots(stats.totalTuk),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tempat Uji Kompetensi',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Row 2: Status Asesmen Card (Online vs Offline)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x02000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status Asesmen',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  Icon(
                    Icons.insights_rounded,
                    size: 16,
                    color: Colors.blue[800],
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
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.cloud_done_rounded,
                            color: Color(0xFF10B981),
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
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              NumberFormatHelper.formatWithDots(stats.onlineAsesmen),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
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
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF3B82F6),
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
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              NumberFormatHelper.formatWithDots(stats.offlineAsesmen),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: [
                      Expanded(
                        flex: stats.onlineAsesmen > 0 ? stats.onlineAsesmen : 1,
                        child: Container(color: const Color(0xFF10B981)),
                      ),
                      Expanded(
                        flex: stats.offlineAsesmen > 0 ? stats.offlineAsesmen : 1,
                        child: Container(color: const Color(0xFF3B82F6)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Row 3: Keterlambatan Jadwal Running
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x02000000),
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
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Keterlambatan Jadwal Running',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${lateSchedules.length} Jadwal',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              lateSchedules.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Tidak ada jadwal running yang terlambat.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: lateSchedules.length > 5 ? 5 : lateSchedules.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = lateSchedules[index];
                        return _buildLateScheduleItem(
                          title: item.skema,
                          daysLate: item.daysLate ?? 1,
                          tuk: item.tuk,
                          endDate: item.tanggalSelesai,
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLateScheduleItem({
    required String title,
    required int daysLate,
    required String tuk,
    required String endDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
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
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_rounded, color: Color(0xFFEF4444), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Telat $daysLate Hari',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
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
                  tuk,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
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
                'Selesai: $endDate',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 2: Sebaran Skema
  // ============================================================================
  Widget _buildSebaranSkemaTab(AsesorStats stats) {
    final displaySkemas = _sertifikatPerSkema;
    int maxVal = 1;
    for (final item in displaySkemas) {
      if (item.totalPemegang > maxVal) maxVal = item.totalPemegang;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Title "Sertifikasi Jarak Jauh"
        const Text(
          'Sertifikasi Jarak Jauh',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // 2 Cards Row: Total Asesor & Sedang Berlangsung
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card 1: Total Asesor (globe icon, light-blue)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x02000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.public,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Total Asesor',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              NumberFormatHelper.formatWithDots(stats.totalAsesor),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Card 2: Sedang Berlangsung (calendar icon, light-green)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x02000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sedang Berlangsung',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_runningJadwals.length} Asesmen',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section: "Sertifikasi Berdasarkan Skema"
        const Text(
          'Sertifikasi Berdasarkan Skema',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // Card displaying the list of skemas
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x02000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: displaySkemas.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Tidak ada data sertifikasi per skema.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: displaySkemas.length > 8 ? 8 : displaySkemas.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = displaySkemas[index];
                    final count = item.totalPemegang;
                    final ratio = maxVal > 0 ? (count / maxVal) : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.skema,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$count Asesi',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
