import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../models/sertifikat_models.dart';
import '../../helpers/date_format_helper.dart';
import '../../widgets/custom_app_bar.dart';
import 'domisili_asesor_detail_screen.dart';
import 'masa_berlaku_asesor_detail_screen.dart';
import 'kompetensi_teknis_detail_screen.dart';
import 'muk_detail_screen.dart';

class StatistikDetailScreen extends StatefulWidget {
  final String menuKey;

  const StatistikDetailScreen({super.key, required this.menuKey});

  @override
  State<StatistikDetailScreen> createState() => _StatistikDetailScreenState();
}

class _StatistikDetailScreenState extends State<StatistikDetailScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilterAsesi = 'Semua';
  String _statusFilterSpt = 'Semua';

  // ── Cache state: avoid re-fetching on search/rebuild ──────────────────────
  bool _hasCachedData = false;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Debounce for search field
  Timer? _debounceTimer;

  // Data state
  DomisiliAsesorData? _domisiliData;
  List<KompetensiTeknisItem> _kompetensiList = [];
  MasaBerlakuAsesorData? _masaBerlakuData;
  MasaTenggangSertifikatData? _masaTenggangData;
  List<JenisSkemaItem> _jenisSkemaList = [];
  List<MUKDistribusiItem> _mukList = [];
  SptAsesorData? _sptData;
  Asesi2026Data? _asesi2026Data;
  List<MonthlyAssessment> _monthlyAssessments = [];
  List<SertifikatDistribusi> _sertifikatPerSkema = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool get _isCacheValid =>
      _hasCachedData &&
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;

  Future<void> _loadData({bool forceRefresh = false}) async {
    // Use cache if valid and not a pull-to-refresh
    if (!forceRefresh && _isCacheValid) {
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      switch (widget.menuKey) {
        case 'domisili_asesor':
          _domisiliData = await ApiService.getDomisiliAsesor();
          break;
        case 'kompetensi_teknis':
          _kompetensiList = await ApiService.getKompetensiTeknis();
          break;
        case 'masa_berlaku':
          _masaBerlakuData = await ApiService.getMasaBerlakuAsesor();
          break;
        case 'masa_tenggang_sertifikat':
          _masaTenggangData = await ApiService.getMasaTenggangSertifikat();
          break;
        case 'jenis_skema':
          _jenisSkemaList = await ApiService.getJenisSkema();
          break;
        case 'muk':
          _mukList = await ApiService.getMUKDistribusi();
          break;
        case 'spt_2026':
          _sptData = await ApiService.getSptAsesor2026();
          break;
        case 'asesi_2026':
          _asesi2026Data = await ApiService.getAsesi2026();
          break;
        case 'tahun_2026':
          _monthlyAssessments = await ApiService.getMonthlyAssessments();
          break;
        case '3_tahun':
          _monthlyAssessments = await ApiService.getAssessmentGraph(months: 36);
          break;
        case 'kompetensi':
          final response = await ApiService.getSertifikatPerSkema(limit: 50);
          _sertifikatPerSkema = response.data;
          break;
      }
      _hasCachedData = true;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      debugPrint('Error loading statistik detail data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Debounced search — avoids re-rendering the whole list on every keystroke
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _searchQuery = value);
    });
  }

  String get _screenTitle {
    switch (widget.menuKey) {
      case 'domisili_asesor':
        return 'Domisili Asesor';
      case 'kompetensi_teknis':
        return 'Kompetensi Teknis';
      case 'masa_berlaku':
        return 'Masa Berlaku Asesor';
      case 'masa_tenggang_sertifikat':
        return 'Masa Tenggang Sertifikat';
      case 'jenis_skema':
        return 'Jenis Skema';
      case 'muk':
        return 'MUK (Materi Uji Kompetensi)';
      case 'spt_2026':
        return 'Penugasan Asesor (SPT 2026)';
      case 'asesi_2026':
        return 'Asesi 2026';
      case 'praktisi':
        return 'Praktisi Skema';
      case 'tahun_2026':
        return 'Grafik Asesi Tahun 2026';
      case '3_tahun':
        return 'Grafik Asesi 3 Tahun (2024 - 2026)';
      case 'kompetensi':
        return 'Kompetensi Per Skema';
      default:
        return 'Detail Statistik';
    }
  }

  // ── Contextual dropdown: menu dalam group yang sama ──────────────────────
  static const Map<String, List<Map<String, String>>> _menuGroups = {
    'asesor_kompetensi': [
      {'value': 'domisili_asesor', 'label': 'Domisili Asesor'},
      {'value': 'kompetensi_teknis', 'label': 'Kompetensi Teknis'},
      {'value': 'masa_berlaku', 'label': 'Masa Berlaku'},
      {'value': 'spt_2026', 'label': 'SPT 2026'},
      {'value': 'asesi_2026', 'label': 'Asesi 2026'},
    ],
    'skema_sertifikasi': [
      {'value': 'jenis_skema', 'label': 'Jenis Skema'},
      {'value': 'muk', 'label': 'MUK'},
      {'value': 'praktisi', 'label': 'Praktisi'},
    ],
    'pemegang_sertifikat': [
      {'value': 'masa_tenggang_sertifikat', 'label': 'Masa Tenggang'},
      {'value': 'tahun_2026', 'label': 'Tahun 2026'},
      {'value': '3_tahun', 'label': '3 Tahun'},
      {'value': 'kompetensi', 'label': 'Kompetensi'},
    ],
  };

  String get _menuGroup {
    for (final entry in _menuGroups.entries) {
      if (entry.value.any((m) => m['value'] == widget.menuKey)) {
        return entry.key;
      }
    }
    return '';
  }

  List<Map<String, String>> get _siblingMenus {
    return _menuGroups[_menuGroup] ?? [];
  }


  Widget _buildMenuButton() {
    final siblings = _siblingMenus;
    if (siblings.length <= 1) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 22),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 4,
      offset: const Offset(0, 40),
      onSelected: (value) {
        if (value != widget.menuKey) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => StatistikDetailScreen(menuKey: value),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        for (final m in siblings)
          PopupMenuItem<String>(
            value: m['value'],
            child: Row(
              children: [
                Icon(
                  m['value'] == widget.menuKey
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: m['value'] == widget.menuKey
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Text(
                  m['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: m['value'] == widget.menuKey
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: m['value'] == widget.menuKey
                        ? const Color(0xFF2563EB)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
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
            title: _screenTitle,
            onBack: () => Navigator.of(context).pop(),
            rightWidget: _buildMenuButton(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadData(forceRefresh: true),
                    child: (widget.menuKey == 'spt_2026' || widget.menuKey == 'asesi_2026')
                        ? (widget.menuKey == 'spt_2026'
                            ? _buildSpt2026Content()
                            : _buildAsesi2026Content())
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            child: _buildBodyContent(),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (widget.menuKey) {
      case 'domisili_asesor':
        return _buildDomisiliAsesorContent();
      case 'kompetensi_teknis':
        return _buildKompetensiTeknisContent();
      case 'masa_berlaku':
        return _buildMasaBerlakuContent();
      case 'masa_tenggang_sertifikat':
        return _buildMasaTenggangSertifikatContent();
      case 'jenis_skema':
        return _buildJenisSkemaContent();
      case 'muk':
        return _buildMUKContent();
      case 'spt_2026':
        return _buildSpt2026Content();
      case 'asesi_2026':
        return _buildAsesi2026Content();
      case 'praktisi':
        return _buildPraktisiContent();
      case 'tahun_2026':
        return _buildTahun2026Content();
      case '3_tahun':
        return _buildTigaTahunContent();
      case 'kompetensi':
        return _buildKompetensiContent();
      default:
        return const Center(child: Text('Data tidak ditemukan'));
    }
  }

  // 1. Domisili Asesor Content
  Widget _buildDomisiliAsesorContent() {
    final data = _domisiliData;
    final items = data?.items ?? [];
    final filtered = items
        .where((i) =>
            _searchQuery.isEmpty ||
            i.provinsiNama.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKpiCardGroup(
          items: [
            _KpiItem('Total Asesor', '${data?.totalAsesor ?? 0}', Colors.blue),
            _KpiItem('Homebase Internal', '${data?.totalInternal ?? 0}', Colors.green),
            _KpiItem('Homebase External', '${data?.totalExternal ?? 0}', Colors.orange),
          ],
        ),
        const SizedBox(height: 16),
        _buildSearchField('Cari Provinsi...'),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _buildEmptyState('Belum ada data sebaran domisili asesor.')
        else if (filtered.isEmpty)
          _buildEmptyState('Tidak ada provinsi yang cocok dengan pencarian.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) => _buildDomisiliCard(filtered[index]),
          ),
      ],
    );
  }

  Widget _buildDomisiliCard(DomisiliAsesorProvinsiItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DomisiliAsesorDetailScreen(
                  provinsiId: item.provinsiId,
                  provinsiNama: item.provinsiNama,
                  totalAsesor: item.totalAsesor,
                  totalInternal: item.asesorInternal,
                  totalExternal: item.asesorExternal,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.provinsiNama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.totalAsesor} Asesor',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Internal: ${item.asesorInternal}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'External: ${item.asesorExternal}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFD97706), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.totalAsesor > 0
                        ? (item.asesorInternal / item.totalAsesor).clamp(0.0, 1.0)
                        : 0.0,
                    backgroundColor: const Color(0xFFFEF3C7),
                    color: const Color(0xFF16A34A),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'Lihat Daftar Asesor',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Color(0xFF2563EB),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2. Kompetensi Teknis Content
  Widget _buildKompetensiTeknisContent() {
    final filteredList = _kompetensiList
        .where((i) =>
            _searchQuery.isEmpty ||
            i.namaSkema.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            i.kodeSkema.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKpiCardGroup(
          items: [
            _KpiItem('Total Skema', '${_kompetensiList.length}', Colors.blue),
            _KpiItem('Total Asesor', '${_kompetensiList.fold<int>(0, (sum, i) => sum + i.jumlahAsesor)}', Colors.indigo),
          ],
        ),
        const SizedBox(height: 16),
        _buildSearchField('Cari Skema / Kode...'),
        const SizedBox(height: 12),
        if (filteredList.isEmpty)
          _buildEmptyState('Belum ada data kompetensi teknis asesor.')
        else
          ...filteredList.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => KompetensiTeknisDetailScreen(
                            skemaId: item.skemaId,
                            kodeSkema: item.kodeSkema,
                            namaSkema: item.namaSkema,
                            jumlahAsesor: item.jumlahAsesor,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.build_outlined, color: Color(0xFF2563EB), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaSkema,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kode: ${item.kodeSkema}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.jumlahAsesor}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
                              ),
                              const Text('Asesor', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  // 3. Masa Berlaku Content
  Widget _buildMasaBerlakuContent() {
    final data = _masaBerlakuData;
    final total = data?.totalAsesor ?? ( (data?.aktif ?? 0) + (data?.tenggang ?? 0) + (data?.expired ?? 0) );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Masa Berlaku Sertifikat Asesor',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Terdaftar: $total Asesor',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildStatusCard(
          title: 'Sertifikat Aktif',
          count: '${data?.aktif ?? 0}',
          desc: 'Masa berlaku masih aktif',
          color: const Color(0xFF16A34A),
          icon: Icons.check_circle_outline,
          statusKey: null,
          numericCount: data?.aktif ?? 0,
        ),
        const SizedBox(height: 10),
        _buildStatusCard(
          title: 'Masa Tenggang',
          count: '${data?.tenggang ?? 0}',
          desc: 'Kurang dari 3 bulan menuju expired',
          color: const Color(0xFFD97706),
          icon: Icons.warning_amber_rounded,
          statusKey: 'tenggang',
          numericCount: data?.tenggang ?? 0,
        ),
        const SizedBox(height: 10),
        _buildStatusCard(
          title: 'Expired / Kadaluarsa',
          count: '${data?.expired ?? 0}',
          desc: 'Sertifikat sudah habis masa berlaku',
          color: const Color(0xFFDC2626),
          icon: Icons.cancel_outlined,
          statusKey: 'expired',
          numericCount: data?.expired ?? 0,
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String count,
    required String desc,
    required Color color,
    required IconData icon,
    String? statusKey,
    int numericCount = 0,
  }) {
    final bool isClickable = statusKey != null;

    Widget cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
        boxShadow: isClickable
            ? [
                BoxShadow(
                  color: color.withAlpha(15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: color)),
                    const SizedBox(height: 2),
                    Text(desc,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Text(count,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: color)),
              if (isClickable) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: color,
                ),
              ],
            ],
          ),
          if (isClickable) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lihat Daftar Asesor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: color,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (!isClickable) return cardContent;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MasaBerlakuAsesorDetailScreen(
                statusFilter: statusKey,
                count: numericCount,
              ),
            ),
          );
        },
        child: cardContent,
      ),
    );
  }

  // 3b. Masa Tenggang Sertifikat Content
  Widget _buildMasaTenggangSertifikatContent() {
    final data = _masaTenggangData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sertifikat Akan Expired',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${data?.totalSertifikatAkanExpired ?? 0} sertifikat (${data?.periodeAwal ?? '-'} s/d ${data?.periodeAkhir ?? '-'})',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...?data?.data.expand((bulanItem) => [
          _buildBulanTenggangCard(bulanItem),
          const SizedBox(height: 10),
        ]),
      ],
    );
  }

  Widget _buildBulanTenggangCard(MasaTenggangSertifikatBulanItem item) {
    final color = const Color(0xFFD97706);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_outlined, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.bulan.isEmpty ? item.tahunBulan : item.bulan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.totalExpired} sertifikat expired',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...item.skemaDetail.map((skema) => Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    skema.namaSkema,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  '${skema.jumlahAsesi} asesi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // 4. Jenis Skema Content
  Widget _buildJenisSkemaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKpiCardGroup(
          items: [
            _KpiItem('Total Kategori', '${_jenisSkemaList.length}', Colors.blue),
            _KpiItem('Total Skema', '${_jenisSkemaList.fold<int>(0, (sum, i) => sum + i.jumlahSkema)}', Colors.indigo),
          ],
        ),
        const SizedBox(height: 16),
        if (_jenisSkemaList.isEmpty)
          _buildEmptyState('Belum ada data kategori jenis skema.')
        else
          ..._jenisSkemaList.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schema_outlined, color: Color(0xFF2563EB), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.kategori,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.jumlahSkema} Skema',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB)),
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  // 5. MUK Content
  Widget _buildMUKContent() {
    final filteredList = _mukList
        .where((i) =>
            _searchQuery.isEmpty ||
            i.namaSkema.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            i.kodeSkema.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKpiCardGroup(
          items: [
            _KpiItem('Total Skema', '${_mukList.length}', Colors.blue),
            _KpiItem('Total MUK/MAPA', '${_mukList.fold<int>(0, (sum, i) => sum + i.jumlahMuk)}', Colors.teal),
          ],
        ),
        const SizedBox(height: 16),
        _buildSearchField('Cari Skema MUK...'),
        const SizedBox(height: 12),
        if (filteredList.isEmpty)
          _buildEmptyState('Belum ada data distribusi MUK per skema.')
        else
          ...filteredList.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MUKDetailScreen(
                            skemaId: item.skemaId,
                            kodeSkema: item.kodeSkema,
                            namaSkema: item.namaSkema,
                            totalMuk: item.jumlahMuk,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_open_outlined, color: Color(0xFF0D9488), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.namaSkema, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('Kode: ${item.kodeSkema}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Text('${item.jumlahMuk} MUK', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D9488))),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  // 6. Praktisi Content
  Widget _buildPraktisiContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF2563EB)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tabel Praktisi Skema (praktisi_skema) dikelompokkan berdasarkan skema sertifikasi.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildEmptyState('Belum ada data praktisi skema terdaftar.'),
      ],
    );
  }

  // 7. Tahun 2026 Content
  Widget _buildTahun2026Content() {
    final list = _monthlyAssessments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah Asesi Setiap Bulan Tahun 2026',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          _buildEmptyState('Belum ada data grafik asesi tahun 2026.')
        else
          ...list.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(m.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (m.total / 100).clamp(0.05, 1.0),
                          minHeight: 10,
                          color: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${m.total} Asesi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              )),
      ],
    );
  }

  // 8. 3 Tahun Content (2024 - 2026)
  Widget _buildTigaTahunContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grafik Asesi Pertahun (2024 - 2026)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildYearCard('Tahun 2024', '1,240 Asesi', 0.6, Colors.blue),
        const SizedBox(height: 10),
        _buildYearCard('Tahun 2025', '1,890 Asesi', 0.85, Colors.indigo),
        const SizedBox(height: 10),
        _buildYearCard('Tahun 2026', '2,150 Asesi', 1.0, Colors.teal),
      ],
    );
  }

  Widget _buildYearCard(String year, String total, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(year, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(total, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: color.withAlpha(25),
            ),
          ),
        ],
      ),
    );
  }

  // 9. Kompetensi Content
  Widget _buildKompetensiContent() {
    final list = _sertifikatPerSkema;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kompetensi Berdasarkan Skema (3 Tahun Terakhir)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          _buildEmptyState('Belum ada data kompetensi per skema.')
        else
          ...list.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Color(0xFF16A34A), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item.skema, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Text('${item.totalPemegang} Kompeten', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF16A34A))),
                  ],
                ),
              )),
      ],
    );
  }

  // Helpers
  Widget _buildKpiCardGroup({required List<_KpiItem> items}) {
    return Row(
      children: items
          .map((kpi) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kpi.label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Text(kpi.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kpi.color)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  // SPT 2026 Content — CustomScrollView + SliverList for virtualization
  Widget _buildSpt2026Content() {
    final data = _sptData;
    final items = data?.items ?? [];
    final filtered = items.where((i) {
      final matchesSearch = _searchQuery.isEmpty ||
          i.namaAsesor.toLowerCase().contains(_searchQuery.toLowerCase());
      final statusLower = i.statusMasaBerlaku.toLowerCase();
      final filterLower = _statusFilterSpt.toLowerCase();
      bool matchesStatus = true;
      if (filterLower == 'aktif') {
        matchesStatus = statusLower == 'aktif';
      } else if (filterLower == 'tenggang') {
        matchesStatus = statusLower == 'tenggang';
      } else if (filterLower == 'expired') {
        matchesStatus = statusLower == 'expired' || statusLower == 'kadaluarsa';
      }
      return matchesSearch && matchesStatus;
    }).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Header: KPI + search + status filter ───────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiCardGroup(
                  items: [
                    _KpiItem('Total Asesor', '${data?.totalAsesor ?? items.length}', Colors.blue),
                    _KpiItem('Total Penugasan', '${data?.totalJadwal ?? items.fold<int>(0, (sum, i) => sum + i.total)}', Colors.indigo),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSearchField('Cari Nama Asesor...'),
                const SizedBox(height: 12),
                _buildStatusFilterCards(
                  totalAll: items.length,
                  totalAktif: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'aktif').length,
                  totalTenggang: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'tenggang').length,
                  totalExpired: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'expired' || i.statusMasaBerlaku.toLowerCase() == 'kadaluarsa').length,
                  selectedFilter: _statusFilterSpt,
                  onSelectFilter: (newFilter) {
                    setState(() {
                      _statusFilterSpt = newFilter;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // ── Virtualized list: only builds visible cards ─────────────────────
        if (filtered.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
                    SizedBox(height: 8),
                    Text('Belum ada data penugasan asesor (SPT) 2026.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSptAsesorCard(filtered[index]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  // Pre-allocated month labels — avoid re-creating list on every card build
  static const List<String> _monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  Widget _buildSptAsesorCard(SptAsesorItem item) {
    Color statusColor;
    if (item.statusMasaBerlaku == 'Aktif') {
      statusColor = const Color(0xFF16A34A);
    } else if (item.statusMasaBerlaku == 'Tenggang') {
      statusColor = const Color(0xFFD97706);
    } else {
      statusColor = const Color(0xFFDC2626);
    }

    return RepaintBoundary(
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline, size: 20, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaAsesor,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                    ),
                    if (item.tglExpired.isNotEmpty)
                      Text(
                        'Expired: ${DateFormatHelper.formatToIndonesian(item.tglExpired)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.statusMasaBerlaku,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${item.total} SPT',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Penugasan per Bulan (2026):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _monthLabels.map((m) {
              final count = item.bulanan[m] ?? 0;
              final isAssigned = count > 0;
              return Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isAssigned ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Text(m, style: TextStyle(fontSize: 10, color: isAssigned ? Colors.white70 : const Color(0xFF64748B))),
                    Text(
                      '$count',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isAssigned ? Colors.white : Colors.black54),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
    );
  }

  // Asesi 2026 Content — CustomScrollView + SliverList for virtualization
  Widget _buildAsesi2026Content() {
    final data = _asesi2026Data;
    final items = data?.items ?? [];
    final filtered = items.where((i) {
      final matchesSearch = _searchQuery.isEmpty ||
          i.namaAsesor.toLowerCase().contains(_searchQuery.toLowerCase());
      final statusLower = i.statusMasaBerlaku.toLowerCase();
      final filterLower = _statusFilterAsesi.toLowerCase();
      bool matchesStatus = true;
      if (filterLower == 'aktif') {
        matchesStatus = statusLower == 'aktif';
      } else if (filterLower == 'tenggang') {
        matchesStatus = statusLower == 'tenggang';
      } else if (filterLower == 'expired') {
        matchesStatus = statusLower == 'expired' || statusLower == 'kadaluarsa';
      }
      return matchesSearch && matchesStatus;
    }).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Header: KPI + search + status filter ───────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiCardGroup(
                  items: [
                    _KpiItem('Total Asesor', '${data?.totalAsesor ?? items.length}', Colors.blue),
                    _KpiItem('Total Asesi', '${data?.totalAsesi ?? items.fold<int>(0, (sum, i) => sum + i.totalAsesi)}', const Color(0xFF16A34A)),
                    _KpiItem('Total Jadwal', '${data?.totalJadwal ?? items.fold<int>(0, (sum, i) => sum + i.totalJadwal)}', Colors.indigo),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSearchField('Cari Nama Asesor...'),
                const SizedBox(height: 12),
                _buildStatusFilterCards(
                  totalAll: items.length,
                  totalAktif: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'aktif').length,
                  totalTenggang: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'tenggang').length,
                  totalExpired: items.where((i) => i.statusMasaBerlaku.toLowerCase() == 'expired' || i.statusMasaBerlaku.toLowerCase() == 'kadaluarsa').length,
                  selectedFilter: _statusFilterAsesi,
                  onSelectFilter: (newFilter) {
                    setState(() {
                      _statusFilterAsesi = newFilter;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // ── Virtualized list: only builds visible cards ─────────────────────
        if (filtered.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
                    SizedBox(height: 8),
                    Text('Belum ada data penugasan asesi 2026.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAsesi2026Card(filtered[index]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusFilterCards({
    required int totalAll,
    required int totalAktif,
    required int totalTenggang,
    required int totalExpired,
    required String selectedFilter,
    required ValueChanged<String> onSelectFilter,
  }) {
    final filters = [
      {'label': 'Semua', 'key': 'Semua', 'count': totalAll, 'color': const Color(0xFF2563EB), 'icon': Icons.apps_rounded},
      {'label': 'Aktif', 'key': 'Aktif', 'count': totalAktif, 'color': const Color(0xFF16A34A), 'icon': Icons.check_circle_outline_rounded},
      {'label': 'Tenggang', 'key': 'Tenggang', 'count': totalTenggang, 'color': const Color(0xFFD97706), 'icon': Icons.warning_amber_rounded},
      {'label': 'Expired', 'key': 'Expired', 'count': totalExpired, 'color': const Color(0xFFDC2626), 'icon': Icons.cancel_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final key = f['key'] as String;
          final label = f['label'] as String;
          final count = f['count'] as int;
          final color = f['color'] as Color;
          final icon = f['icon'] as IconData;
          final isSelected = selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                onSelectFilter(isSelected && key != 'Semua' ? 'Semua' : key);
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(20) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withAlpha(30),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? color : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : color,
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

  Widget _buildAsesi2026Card(Asesi2026Item item) {
    Color statusBgColor;
    Color statusTextColor;
    if (item.statusMasaBerlaku == 'Aktif') {
      statusBgColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF16A34A);
    } else if (item.statusMasaBerlaku == 'Tenggang') {
      statusBgColor = const Color(0xFFFFF8E1);
      statusTextColor = const Color(0xFFD97706);
    } else {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFDC2626);
    }

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_outline, size: 20, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaAsesor,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                      ),
                      if (item.tglExpired.isNotEmpty)
                        Text(
                          'Expired: ${DateFormatHelper.formatToIndonesian(item.tglExpired)}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.statusMasaBerlaku,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusTextColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.totalAsesi} Asesi',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.totalJadwal} Jadwal',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Jumlah Asesi per Bulan (2026):',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _monthLabels.map((m) {
                final count = item.bulanan[m] ?? 0;
                final isAssigned = count > 0;
                return Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isAssigned ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        m,
                        style: TextStyle(fontSize: 10, color: isAssigned ? Colors.white70 : const Color(0xFF64748B)),
                      ),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isAssigned ? Colors.white : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(String hint) {
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
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
          const SizedBox(height: 8),
          Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ],
      ),
    );
  }
}

class _KpiItem {
  final String label;
  final String value;
  final Color color;

  _KpiItem(this.label, this.value, this.color);
}
