import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../models/lead_model.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/marketing/lead_storage_service.dart';
import '../../services/marketing/location_service.dart';
import '../../services/marketing/places_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'lead_detail_screen.dart';
import 'proposal_preview_screen.dart';
import 'widgets/add_custom_lead_dialog.dart';
import 'widgets/crm_pipeline_view.dart';
import 'widgets/lead_generator_view.dart';
import 'widgets/marketing_filter_sheet.dart';
import 'widgets/marketing_options_sheet.dart';

class AsesorMarketingScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AsesorMarketingScreen({super.key, this.onBackToHome});

  @override
  State<AsesorMarketingScreen> createState() => _AsesorMarketingScreenState();
}

class _AsesorMarketingScreenState extends State<AsesorMarketingScreen> {
  int _selectedMode = 0;

  final TextEditingController _searchController =
      TextEditingController(text: 'SMK');
  String _selectedCategory = 'Semua';
  bool _isLoadingPlaces = false;
  List<PlaceResult> _places = [];
  PlaceResult? _selectedPlace;
  UserGeoLocation? _userLocation;

  bool _isLoadingLeads = false;
  List<LeadModel> _savedLeads = [];
  LeadSummaryStats _stats = const LeadSummaryStats();
  String _crmFilterStatus = 'all';
  final TextEditingController _crmSearchController = TextEditingController();

  final Set<String> _savedPlaceIds = {};
  final Set<String> _savedNames = {};
  Timer? _debounceTimer;

  bool _filterRetailNoise = true;
  int _searchRadiusKm = 12;
  final Set<String> _customAllowedCategories = {
    'SMK',
    'Kampus',
    'BLK',
    'LPK',
    'Dinas Pemda',
    'Perusahaan Swasta',
  };
  final Set<String> _blacklistKeywords =
      Set.from(PlacesService.defaultBlacklist);

  int get _idAsesor =>
      int.tryParse(AuthRepository.currentUserInstance?.id ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _crmSearchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadSavedLeads();
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = loc;
      });
    }
    _fetchPlaces(
      query: 'SMK Kampus BLK LPK Dinas',
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
  }

  Future<void> _handleMyLocation() async {
    PlacesService.clearSearchCache();
    setState(() {
      _selectedPlace = null;
    });
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = loc;
      });
    }
    final q = _searchController.text.trim().isNotEmpty
        ? _searchController.text.trim()
        : 'SMK';
    await _fetchPlaces(
      query: q,
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
  }

  Future<void> _loadSavedLeads() async {
    setState(() => _isLoadingLeads = true);
    final leads = await LeadStorageService.getLeads(_idAsesor);
    final stats = await LeadStorageService.getSummaryStats(_idAsesor);

    final Set<String> ids = {};
    final Set<String> names = {};
    for (final l in leads) {
      if (l.placeId.isNotEmpty) ids.add(l.placeId);
      if (l.namaInstitusi.isNotEmpty) {
        names.add(l.namaInstitusi.toLowerCase().trim());
      }
    }

    if (mounted) {
      setState(() {
        _savedLeads = leads;
        _stats = stats;
        _savedPlaceIds
          ..clear()
          ..addAll(ids);
        _savedNames
          ..clear()
          ..addAll(names);
        _isLoadingLeads = false;
      });
    }
  }

  Future<void> _fetchPlaces(
      {String? query, double? latitude, double? longitude}) async {
    final q = query ?? _searchController.text.trim();
    if (q.isEmpty) return;

    setState(() {
      _isLoadingPlaces = true;
    });

    final lat = latitude ?? _userLocation?.latitude;
    final lng = longitude ?? _userLocation?.longitude;

    final results = await PlacesService.searchPlaces(
      query: q,
      latitude: lat,
      longitude: lng,
      radius: _searchRadiusKm * 1000,
      filterRetail: _filterRetailNoise,
      customBlacklist: _blacklistKeywords.toList(),
      allowedCategories: _customAllowedCategories.isEmpty
          ? null
          : _customAllowedCategories.toList(),
    );

    if (mounted) {
      setState(() {
        _places = results;
        _selectedPlace = results.isNotEmpty ? results.first : null;
        _isLoadingPlaces = false;
      });
    }
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    final query = val.trim();
    if (query.isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        _fetchPlaces(query: query);
      });
    }
  }

  void _openFilterSheet() {
    showMarketingFilterSheet(
      context: context,
      filterRetail: _filterRetailNoise,
      radiusKm: _searchRadiusKm,
      blacklist: _blacklistKeywords,
      allowedCategories: _customAllowedCategories,
      onApply: (v) {
        setState(() {
          _filterRetailNoise = v.filterRetail;
          _searchRadiusKm = v.radiusKm;
          _blacklistKeywords
            ..clear()
            ..addAll(v.blacklist);
          _customAllowedCategories
            ..clear()
            ..addAll(v.allowedCategories);
        });
        _fetchPlaces();
      },
    );
  }

  void _openOptionsSheet() {
    showMarketingOptionsSheet(
      context: context,
      searchRadiusKm: _searchRadiusKm,
      locationName: _userLocation?.locationName,
      onOpenFilter: _openFilterSheet,
      onSyncLocation: _handleMyLocation,
    );
  }

  void _openAddLeadDialog() {
    showAddCustomLeadDialog(
      context: context,
      idAsesor: _idAsesor,
      onSaved: _loadSavedLeads,
    );
  }

  void _onCategoryFilter(String category) {
    setState(() {
      _selectedCategory = category;
    });
    String q = category;
    if (category == 'Semua') {
      q = 'SMK Kampus BLK LPK Dinas';
      _searchController.clear();
    } else if (category == 'Kampus') {
      q = 'Kampus';
      _searchController.text = 'Kampus';
    } else if (category == 'BLK') {
      q = 'BLK';
      _searchController.text = 'BLK';
    } else if (category == 'LPK') {
      q = 'LPK';
      _searchController.text = 'LPK';
    } else if (category == 'Dinas Pemda') {
      q = 'Dinas';
      _searchController.text = 'Dinas';
    } else if (category == 'Perusahaan Swasta') {
      q = 'Perusahaan';
      _searchController.text = 'Perusahaan';
    } else {
      _searchController.text = category;
    }
    _fetchPlaces(query: q);
  }

  Future<void> _handleSavePlaceToLead(PlaceResult place) async {
    final newLead = place.toLeadModel(_idAsesor);
    final leadWithAi = await LeadStorageService.generateAiPotensi(newLead);
    await LeadStorageService.saveLead(leadWithAi);
    await _loadSavedLeads();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Berhasil menyimpan "${place.name}" ke daftar Prospek!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Lihat',
            textColor: const Color(0xFF93C5FD),
            onPressed: () {
              setState(() => _selectedMode = 1);
            },
          ),
        ),
      );
    }
  }

  void _openProposal(LeadModel lead) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProposalPreviewScreen(lead: lead),
      ),
    );
  }

  void _openLeadDetail(LeadModel lead) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeadDetailScreen(
          lead: lead,
          onLeadUpdated: (updated) => _loadSavedLeads(),
        ),
      ),
    ).then((_) => _loadSavedLeads());
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Marketing & Lead Generator',
            onBack: widget.onBackToHome,
            rightWidget: _selectedMode == 1
                ? GestureDetector(
                    onTap: _openAddLeadDialog,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _openOptionsSheet,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
          ),
          MarketingModeSwitcher(
            selectedMode: _selectedMode,
            savedCount: _savedLeads.length,
            onSelect: (m) => setState(() => _selectedMode = m),
          ),
          Expanded(
            child: _selectedMode == 0
                ? LeadGeneratorView(
                    searchController: _searchController,
                    selectedCategory: _selectedCategory,
                    isLoadingPlaces: _isLoadingPlaces,
                    places: _places,
                    selectedPlace: _selectedPlace,
                    userLocation: _userLocation,
                    savedPlaceIds: _savedPlaceIds,
                    savedNames: _savedNames,
                    filterRetailNoise: _filterRetailNoise,
                    idAsesor: _idAsesor,
                    onSearchChanged: _onSearchChanged,
                    onSelectPlace: (p) =>
                        setState(() => _selectedPlace = p),
                    onFetchPlaces: _fetchPlaces,
                    onMyLocation: _handleMyLocation,
                    onOpenFilter: _openFilterSheet,
                    onCategoryFilter: _onCategoryFilter,
                    onSavePlace: _handleSavePlaceToLead,
                    onShowSaved: () =>
                        setState(() => _selectedMode = 1),
                    onDirectPitch: (place) => _openProposal(
                        place.toLeadModel(_idAsesor)),
                  )
                : CrmPipelineView(
                    isLoading: _isLoadingLeads,
                    savedLeads: _savedLeads,
                    stats: _stats,
                    filterStatus: _crmFilterStatus,
                    searchController: _crmSearchController,
                    onSearchChanged: () => setState(() {}),
                    onClearSearch: () {
                      _crmSearchController.clear();
                      setState(() {});
                    },
                    onSelectStatus: (s) =>
                        setState(() => _crmFilterStatus = s),
                    onToggleKpiTab: (s) => setState(() {
                      _crmFilterStatus =
                          _crmFilterStatus == s ? 'all' : s;
                    }),
                    onOpenMap: () =>
                        setState(() => _selectedMode = 0),
                    onTapLead: _openLeadDetail,
                    onOpenProposal: _openProposal,
                    onRefresh: _loadSavedLeads,
                    idAsesor: _idAsesor,
                  ),
          ),
        ],
      ),
    );
  }
}
