import 'package:material_ui/material_ui.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../models/jadwal_models.dart';
import '../../models/sertifikat_models.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/statistik/asesor_aktif_tab.dart';
import '../../widgets/statistik/distribusi_asesor_widgets.dart';
import '../../widgets/statistik/distribusi_tab_bar.dart';
import '../../widgets/statistik/sebaran_skema_tab.dart';

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
          DistribusiTabBar(
            isAsesorAktifSelected: _isActiveAsesorSelected,
            onChanged: (value) {
              setState(() {
                _isActiveAsesorSelected = value;
              });
            },
          ),

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
                    ? const DistribusiLoadingState() 
                    : (_isActiveAsesorSelected 
                        ? AsesorAktifTab(stats: stats, runningJadwals: _runningJadwals) 
                        : SebaranSkemaTab(
                            stats: stats,
                            sertifikatPerSkema: _sertifikatPerSkema,
                            runningCount: _runningJadwals.length,
                          )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
