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
import 'widgets/lead_crm_card.dart';
import 'widgets/lead_map_canvas.dart';
import 'widgets/marketing_kpi_header.dart';
import 'widgets/place_search_card.dart';

class AsesorMarketingScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AsesorMarketingScreen({super.key, this.onBackToHome});

  @override
  State<AsesorMarketingScreen> createState() => _AsesorMarketingScreenState();
}

class _AsesorMarketingScreenState extends State<AsesorMarketingScreen> {
  // Navigation Mode: 0 = Lead Generator (Peta & Search), 1 = Pipeline CRM Saya
  int _selectedMode = 0;

  // Search state
  final TextEditingController _searchController =
      TextEditingController(text: 'SMK');
  String _selectedCategory = 'Semua';
  bool _isLoadingPlaces = false;
  List<PlaceResult> _places = [];
  PlaceResult? _selectedPlace;
  UserGeoLocation? _userLocation;

  // CRM Leads state
  bool _isLoadingLeads = false;
  List<LeadModel> _savedLeads = [];
  LeadSummaryStats _stats = const LeadSummaryStats();
  String _crmFilterStatus = 'all'; // all, lead, prospek, interest, sales
  final TextEditingController _crmSearchController = TextEditingController();

  final Set<String> _savedPlaceIds = {};
  final Set<String> _savedNames = {};
  Timer? _debounceTimer;

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
      query: 'SMK',
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
  }

  Future<void> _handleMyLocation() async {
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = loc;
      });
    }
    await _fetchPlaces(
      query: _searchController.text.trim(),
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
        _savedPlaceIds.clear();
        _savedPlaceIds.addAll(ids);
        _savedNames.clear();
        _savedNames.addAll(names);
        _isLoadingLeads = false;
      });
    }
  }

  Future<void> _fetchPlaces({String? query, double? latitude, double? longitude}) async {
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
    );

    if (mounted) {
      setState(() {
        _places = results;
        _selectedPlace = results.isNotEmpty ? results.first : null;
        _isLoadingPlaces = false;
      });
    }
  }

  void _onCategoryFilter(String category) {
    setState(() {
      _selectedCategory = category;
    });
    String q = category == 'Semua' ? 'SMK' : category;
    _searchController.text = q;
    _fetchPlaces(query: q);
  }

  Future<void> _handleSavePlaceToLead(PlaceResult place) async {
    final newLead = place.toLeadModel(_idAsesor);

    // Auto-generate AI Potential student estimate & relevant LSP schemes
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

  void _showAddCustomLeadDialog() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final picCtrl = TextEditingController();
    String category = 'SMK';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Tambah Calon Mitra Manual',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Institusi *',
                        hintText: 'Contoh: SMK Negeri 3 Sampit',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration:
                          const InputDecoration(labelText: 'Kategori Institusi'),
                      items: [
                        'SMK',
                        'Kampus',
                        'BLK',
                        'LPK',
                        'LKP',
                        'Dinas Pemda',
                        'Perusahaan Swasta'
                      ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setDlgState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Alamat / Kota',
                        hintText: 'Contoh: Jl. Walter Condrat, Sampit',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: picCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama PIC / Kontak',
                        hintText: 'Contoh: Drs. Bambang (Kepala Sekolah)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'No. WhatsApp / Telp',
                        hintText: '0853-xxxx-xxxx',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;

                    final customLead = LeadModel(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      idAsesor: _idAsesor,
                      namaInstitusi: nameCtrl.text.trim(),
                      leadKategori: category,
                      leadLocation: addressCtrl.text.trim(),
                      picName: picCtrl.text.trim(),
                      telepon: phoneCtrl.text.trim(),
                      leadStatus: 'lead',
                      updatedAt: DateTime.now(),
                    );

                    final aiLead =
                        await LeadStorageService.generateAiPotensi(customLead);
                    await LeadStorageService.saveLead(aiLead);
                    await _loadSavedLeads();

                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
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
                ? IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Color(0xFF2563EB)),
                    onPressed: _showAddCustomLeadDialog,
                    tooltip: 'Tambah Mitra Manual',
                  )
                : const SizedBox(width: 32),
          ),

          // Mode Switcher Tabs (Lead Generator vs Pipeline CRM)
          _buildModeSwitcher(),

          // Main View Content
          Expanded(
            child: _selectedMode == 0
                ? _buildLeadGeneratorView()
                : _buildCrmPipelineView(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedMode = 0),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedMode == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedMode == 0
                      ? const [
                          BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 4,
                              offset: Offset(0, 1)),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      size: 16,
                      color: _selectedMode == 0
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Peta Lead Generator',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: _selectedMode == 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: _selectedMode == 0
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedMode = 1),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedMode == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedMode == 1
                      ? const [
                          BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 4,
                              offset: Offset(0, 1)),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.view_kanban_rounded,
                      size: 16,
                      color: _selectedMode == 1
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Prospek Saya (${_savedLeads.length})',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: _selectedMode == 1
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: _selectedMode == 1
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MODE 1: Lead Generator (Peta & Search Explorer)
  // --------------------------------------------------------------------------
  Widget _buildLeadGeneratorView() {
    return Stack(
      children: [
        // 1. Fullscreen / Interactive Map Canvas
        Positioned.fill(
          child: LeadMapCanvas(
            places: _places,
            selectedPlace: _selectedPlace,
            userLocation: _userLocation,
            savedPlaceIds: _savedPlaceIds,
            savedNames: _savedNames,
            isLoading: _isLoadingPlaces,
            onSelectPlace: (place) {
              setState(() {
                _selectedPlace = place;
              });
            },
            onSearchArea: () => _fetchPlaces(),
            onMyLocationPressed: _handleMyLocation,
          ),
        ),

        // 2. Floating Top Search & Category Filter Chips
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Search Input Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (val) => _fetchPlaces(query: val),
                  decoration: InputDecoration(
                    hintText: 'Cari SMK, Kampus, BLK, Dinas...',
                    hintStyle: const TextStyle(
                        fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF2563EB)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _fetchPlaces(query: 'smk terdekat');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Category Filter Horizontal Scroll
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip('Semua', Icons.explore_rounded),
                    _buildCategoryChip('SMK', Icons.school_rounded),
                    _buildCategoryChip('Kampus', Icons.account_balance_rounded),
                    _buildCategoryChip('BLK', Icons.build_circle_rounded),
                    _buildCategoryChip('LPK', Icons.menu_book_rounded),
                    _buildCategoryChip('Dinas Pemda', Icons.domain_rounded),
                    _buildCategoryChip('Perusahaan Swasta', Icons.business_center_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. Draggable Bottom Sheet (Sesuai Referensi Google Maps)
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.12,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // Drag Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header info + Legend + Dynamic GPS Lokasi Saya Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hasil Pencarian (${_places.length} Tempat)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 13, color: Colors.red),
                                  SizedBox(width: 2),
                                  Text('Baru',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                  SizedBox(width: 8),
                                  Icon(Icons.location_on,
                                      size: 13, color: Colors.green),
                                  SizedBox(width: 2),
                                  Text('Tersimpan di DB',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_isLoadingPlaces)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2563EB),
                            ),
                          )
                        else
                          InkWell(
                            onTap: _handleMyLocation,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFBFDBFE), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.my_location_rounded,
                                      size: 14, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _userLocation?.locationName ?? 'Lokasi Saya',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Cards List
                  if (_places.isEmpty && !_isLoadingPlaces)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Tidak ada tempat ditemukan. Coba ubah kata kunci atau geser peta.',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._places.map((place) {
                      final isSaved = _savedPlaceIds.contains(place.placeId) ||
                          _savedNames.contains(place.name.toLowerCase().trim());
                      final isSelected =
                          _selectedPlace?.placeId == place.placeId;
                      return PlaceSearchCard(
                        place: place,
                        isSaved: isSaved,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedPlace = place;
                          });
                        },
                        onSaveLead: isSaved
                            ? () {
                                setState(() => _selectedMode = 1);
                              }
                            : () => _handleSavePlaceToLead(place),
                        onDirectPitch: () {
                          final dummyLead = place.toLeadModel(_idAsesor);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProposalPreviewScreen(lead: dummyLead),
                            ),
                          );
                        },
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 14,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        onSelected: (_) => _onCategoryFilter(label),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MODE 2: Pipeline CRM Saya (Lead Management)
  // --------------------------------------------------------------------------
  Widget _buildCrmPipelineView() {
    if (_isLoadingLeads) {
      return const Center(child: CircularProgressIndicator());
    }

    final q = _crmSearchController.text.trim().toLowerCase();
    final filteredLeads = _savedLeads.where((l) {
      final matchesStatus = _crmFilterStatus == 'all' ||
          l.leadStatus.toLowerCase() == _crmFilterStatus.toLowerCase();
      final matchesQuery = q.isEmpty ||
          l.namaInstitusi.toLowerCase().contains(q) ||
          l.leadLocation.toLowerCase().contains(q) ||
          l.leadKategori.toLowerCase().contains(q);
      return matchesStatus && matchesQuery;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadSavedLeads,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          // KPI Metric Header
          MarketingKpiHeader(
            stats: _stats,
            activeTab: _crmFilterStatus,
            onSelectStatusTab: (statusKey) {
              setState(() {
                _crmFilterStatus =
                    _crmFilterStatus == statusKey ? 'all' : statusKey;
              });
            },
          ),

          // Search in CRM Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _crmSearchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari di daftar prospek saya...',
                hintStyle:
                    const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                suffixIcon: _crmSearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _crmSearchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),

          // Status Filter Tabs Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildStatusFilterChip('all', 'Semua (${_savedLeads.length})'),
                _buildStatusFilterChip('lead', 'Lead (${_stats.countLead})'),
                _buildStatusFilterChip(
                    'prospek', 'Proposal (${_stats.countProspek})'),
                _buildStatusFilterChip(
                    'interest', 'Follow Up (${_stats.countInterest})'),
                _buildStatusFilterChip(
                    'sales', 'Deal / MoU (${_stats.countSales})'),
              ],
            ),
          ),

          // List of Leads
          if (filteredLeads.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.folder_open_rounded,
                        size: 48, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada data prospek pada filter ini',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gunakan tab "Peta Lead Generator" untuk menemukan calon mitra uji kompetensi terdekat.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _selectedMode = 0),
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: const Text('Buka Peta Generator'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredLeads.map((lead) {
              return LeadCrmCard(
                lead: lead,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeadDetailScreen(
                        lead: lead,
                        onLeadUpdated: (updated) => _loadSavedLeads(),
                      ),
                    ),
                  ).then((_) => _loadSavedLeads());
                },
                onWhatsApp: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProposalPreviewScreen(lead: lead),
                    ),
                  );
                },
                onProposal: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProposalPreviewScreen(lead: lead),
                    ),
                  );
                },
                onStatusChange: (newStatus) async {
                  await LeadStorageService.updateLeadStatus(
                      _idAsesor, lead.id, newStatus);
                  await _loadSavedLeads();
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String statusKey, String label) {
    final isSelected = _crmFilterStatus.toLowerCase() == statusKey.toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        onSelected: (_) {
          setState(() {
            _crmFilterStatus = statusKey;
          });
        },
      ),
    );
  }
}