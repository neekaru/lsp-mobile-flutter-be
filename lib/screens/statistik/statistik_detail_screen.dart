import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../models/sertifikat_models.dart';
import '../../widgets/statistik/statistik_detail_sections.dart';
import '../../widgets/statistik/statistik_detail_sliver_sections.dart';
import '../../widgets/common/custom_app_bar.dart';

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

  void _clearSearch() {
    setState(() => _searchQuery = '');
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
                        ? _buildBodyContent()
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
        return DomisiliAsesorSection(
          data: _domisiliData,
          searchQuery: _searchQuery,
          onSearchChanged: _onSearchChanged,
          onClearSearch: _clearSearch,
        );
      case 'kompetensi_teknis':
        return KompetensiTeknisSection(
          items: _kompetensiList,
          searchQuery: _searchQuery,
          onSearchChanged: _onSearchChanged,
          onClearSearch: _clearSearch,
        );
      case 'masa_berlaku':
        return MasaBerlakuSection(data: _masaBerlakuData);
      case 'masa_tenggang_sertifikat':
        return MasaTenggangSection(data: _masaTenggangData);
      case 'jenis_skema':
        return JenisSkemaSection(items: _jenisSkemaList);
      case 'muk':
        return MUKSection(
          items: _mukList,
          searchQuery: _searchQuery,
          onSearchChanged: _onSearchChanged,
          onClearSearch: _clearSearch,
        );
      case 'spt_2026':
        return Spt2026Section(
          data: _sptData,
          searchQuery: _searchQuery,
          statusFilter: _statusFilterSpt,
          onSearchChanged: _onSearchChanged,
          onClearSearch: _clearSearch,
          onFilterChanged: (newFilter) {
            setState(() {
              _statusFilterSpt = newFilter;
            });
          },
        );
      case 'asesi_2026':
        return Asesi2026Section(
          data: _asesi2026Data,
          searchQuery: _searchQuery,
          statusFilter: _statusFilterAsesi,
          onSearchChanged: _onSearchChanged,
          onClearSearch: _clearSearch,
          onFilterChanged: (newFilter) {
            setState(() {
              _statusFilterAsesi = newFilter;
            });
          },
        );
      case 'praktisi':
        return const PraktisiSection();
      case 'tahun_2026':
        return Tahun2026Section(list: _monthlyAssessments);
      case '3_tahun':
        return const TigaTahunSection();
      case 'kompetensi':
        return KompetensiSection(list: _sertifikatPerSkema);
      default:
        return const Center(child: Text('Data tidak ditemukan'));
    }
  }
}
