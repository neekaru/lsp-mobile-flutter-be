import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/lead_model.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/marketing/lead_storage_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'widgets/lead_bottom_sheets.dart';
import 'widgets/lead_card.dart';
import 'widgets/lead_helpers.dart';
import 'widgets/lead_section_widgets.dart';

class LeadGeneratorScreen extends StatefulWidget {
  const LeadGeneratorScreen({super.key});

  @override
  State<LeadGeneratorScreen> createState() => _LeadGeneratorScreenState();
}

class _LeadGeneratorScreenState extends State<LeadGeneratorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _kabupatenFilterController =
      TextEditingController(text: 'Kota Surabaya');

  bool _isLoading = true;
  List<LeadModel> _leads = [];
  String _selectedKategori = 'Semua';
  final String _selectedStatus = 'Semua';
  int _idAsesor = 4;

  final List<String> _kategoriList = [
    'Semua',
    'SMK',
    'LPK',
    'LKP',
    'Kampus',
    'BLK',
    'Dinas Pemda',
    'Perusahaan Swasta',
  ];

  @override
  void initState() {
    super.initState();
    _resolveAsesorAndLoad();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _kabupatenFilterController.dispose();
    super.dispose();
  }

  Future<void> _resolveAsesorAndLoad() async {
    setState(() => _isLoading = true);
    final user = AuthRepository.currentUserInstance;
    if (user != null && user.id.isNotEmpty) {
      _idAsesor = int.tryParse(user.id) ?? 4;
    }
    final data = await LeadStorageService.getLeads(_idAsesor);
    if (mounted) {
      setState(() {
        _leads = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _changeStatus(LeadModel lead, String newStatus) async {
    await LeadStorageService.updateLeadStatus(_idAsesor, lead.id, newStatus);
    await _resolveAsesorAndLoad();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status ${lead.namaInstitusi} diubah menjadi ${formatLeadStatus(newStatus)}',
          ),
          backgroundColor: leadStatusColor(newStatus),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _runAiGenerator(LeadModel lead) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text(
                  'AI sedang menganalisis potensi institusi...',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final updated = await LeadStorageService.generateAiPotensi(lead);
    await LeadStorageService.saveLead(updated);
    if (mounted) {
      Navigator.pop(context); // close loading
      await _resolveAsesorAndLoad();
      _showDetailBottomSheet(updated);
    }
  }

  void _openGoogleMapsByKeyword(String keyword) async {
    final kab = _kabupatenFilterController.text.trim();
    final queryStr = kab.isNotEmpty ? '$keyword di $kab' : keyword;
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(queryStr)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka Google Maps.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddLeadDialog({String defaultKategori = 'SMK', String defaultName = ''}) {
    showAddLeadSheet(
      context,
      idAsesor: _idAsesor,
      kategoriList: _kategoriList,
      defaultKabupaten: _kabupatenFilterController.text,
      defaultKategori: defaultKategori,
      defaultName: defaultName,
      onSaved: _resolveAsesorAndLoad,
    );
  }

  void _showDetailBottomSheet(LeadModel lead) {
    showLeadDetailSheet(
      context,
      lead: lead,
      onChangeStatus: _changeStatus,
      onRunAi: _runAiGenerator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final filteredLeads = _leads.where((l) {
      final matchesCat = _selectedKategori == 'Semua' || l.leadKategori == _selectedKategori;
      final matchesStatus = _selectedStatus == 'Semua' || l.leadStatus == _selectedStatus;
      final matchesSearch = _searchController.text.isEmpty ||
          l.namaInstitusi.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          l.leadLocation.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCat && matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Lead Generator',
            onBack: () => Navigator.pop(context),
            rightWidget: IconButton(
              icon: const Icon(LucideIcons.plus, color: Colors.white),
              onPressed: () => _showAddLeadDialog(),
              tooltip: 'Tambah Lead Baru',
            ),
          ),

          // 1. KPI Summary Header
          LeadKpiSummaryHeader(leads: _leads, kabupaten: _kabupatenFilterController.text),

          // 2. Google Maps Nearby Quick Explore Keywords
          LeadQuickExplore(onOpenKeyword: _openGoogleMapsByKeyword),

          // 3. Search & Filter Bar
          LeadSearchAndFilters(
            searchController: _searchController,
            onSearchChanged: () => setState(() {}),
            kategoriList: _kategoriList,
            selectedKategori: _selectedKategori,
            onSelectKategori: (cat) => setState(() => _selectedKategori = cat),
          ),

          // 4. Lead List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredLeads.isEmpty
                    ? LeadEmptyState(onAddLead: () => _showAddLeadDialog())
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                        itemCount: filteredLeads.length,
                        itemBuilder: (context, index) {
                          return LeadCard(
                            lead: filteredLeads[index],
                            onTap: () => _showDetailBottomSheet(filteredLeads[index]),
                            onOpenMaps: () async {
                              final query = Uri.encodeComponent(
                                '${filteredLeads[index].namaInstitusi}, ${filteredLeads[index].leadLocation}',
                              );
                              final uri = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$query',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            onRunAi: () => _runAiGenerator(filteredLeads[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeadDialog(),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Simpan Lead', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
