import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/lead_model.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/marketing/lead_storage_service.dart';
import '../../widgets/common/custom_app_bar.dart';

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
  String _selectedStatus = 'Semua';
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

  final List<Map<String, dynamic>> _quickGmapsKeywords = [
    {
      'label': 'SMK Terdekat',
      'keyword': 'SMK terdekat',
      'kategori': 'SMK',
      'icon': LucideIcons.graduation_cap,
      'color': Color(0xFF2563EB),
    },
    {
      'label': 'Kampus Terdekat',
      'keyword': 'Kampus Universitas terdekat',
      'kategori': 'Kampus',
      'icon': LucideIcons.building,
      'color': Color(0xFF7C3AED),
    },
    {
      'label': 'LPK Terdekat',
      'keyword': 'LPK Lembaga Pelatihan Kerja terdekat',
      'kategori': 'LPK',
      'icon': LucideIcons.award,
      'color': Color(0xFF0D9488),
    },
    {
      'label': 'LKP Terdekat',
      'keyword': 'LKP Lembaga Kursus dan Pelatihan terdekat',
      'kategori': 'LKP',
      'icon': LucideIcons.book_open,
      'color': Color(0xFF0284C7),
    },
    {
      'label': 'BLK Terdekat',
      'keyword': 'BLK Balai Latihan Kerja terdekat',
      'kategori': 'BLK',
      'icon': LucideIcons.hammer,
      'color': Color(0xFFEA580C),
    },
    {
      'label': 'Dinas Pemda',
      'keyword': 'Dinas Pemerintah Daerah terdekat',
      'kategori': 'Dinas Pemda',
      'icon': LucideIcons.landmark,
      'color': Color(0xFF059669),
    },
    {
      'label': 'Perusahaan Swasta',
      'keyword': 'Perusahaan Kawasan Industri terdekat',
      'kategori': 'Perusahaan Swasta',
      'icon': LucideIcons.briefcase,
      'color': Color(0xFF4F46E5),
    },
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
            'Status ${lead.namaInstitusi} diubah menjadi ${_formatStatus(newStatus)}',
          ),
          backgroundColor: _getStatusColor(newStatus),
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

  void _openLeadInGoogleMaps(LeadModel lead) async {
    final query = Uri.encodeComponent('${lead.namaInstitusi}, ${lead.leadLocation}');
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddLeadDialog({String defaultKategori = 'SMK', String defaultName = ''}) {
    final namaCtrl = TextEditingController(text: defaultName);
    final lokasiCtrl = TextEditingController();
    final kabCtrl = TextEditingController(text: _kabupatenFilterController.text);
    final descCtrl = TextEditingController();
    String kategori = defaultKategori;
    String status = 'lead';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Simpan Lead ke Database Lokal',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: namaCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nama Institusi / Sekolah / Mitra',
                        hintText: 'Contoh: SMK Negeri 2 Surabaya',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: kategori,
                      decoration: InputDecoration(
                        labelText: 'Kategori Lead',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: _kategoriList
                          .where((e) => e != 'Semua')
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => kategori = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lokasiCtrl,
                      decoration: InputDecoration(
                        labelText: 'Alamat Lokasi (Google Maps)',
                        hintText: 'Jl. Pemuda No. 10...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: kabCtrl,
                      decoration: InputDecoration(
                        labelText: 'Kabupaten / Kota',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi / Potensi Kerjasama',
                        hintText: 'Keterangan awal institusi...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: InputDecoration(
                        labelText: 'Status Lead',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: ['lead', 'prospek', 'interest', 'sales']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(_formatStatus(e)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => status = v);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (namaCtrl.text.trim().isEmpty) return;
                          final newLead = LeadModel(
                            id: 'lead-${DateTime.now().millisecondsSinceEpoch}',
                            idAsesor: _idAsesor,
                            namaInstitusi: namaCtrl.text.trim(),
                            leadKategori: kategori,
                            leadLocation: lokasiCtrl.text.trim().isNotEmpty
                                ? lokasiCtrl.text.trim()
                                : kabCtrl.text.trim(),
                            kabupaten: kabCtrl.text.trim(),
                            leadDescription: descCtrl.text.trim(),
                            leadStatus: status,
                            updatedAt: DateTime.now(),
                          );
                          Navigator.pop(ctx);
                          await LeadStorageService.saveLead(newLead);
                          await _resolveAsesorAndLoad();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lead baru berhasil disimpan ke database lokal!'),
                                backgroundColor: Color(0xFF16A34A),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: const Text(
                          'Simpan ke Database Lokal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailBottomSheet(LeadModel lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(lead.leadKategori).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(lead.leadKategori),
                            color: _getCategoryColor(lead.leadKategori),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lead.namaInstitusi,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      lead.leadKategori,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(lead.leadStatus).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _formatStatus(lead.leadStatus),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(lead.leadStatus),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.map_pin, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              lead.leadLocation,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 18),
                              const SizedBox(width: 6),
                              const Text(
                                'Analisis Potensi AI',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                              const Spacer(),
                              if (lead.estimasiSiswa > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '±${lead.estimasiSiswa} Siswa/Thn',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lead.leadPotensi.isNotEmpty
                                ? lead.leadPotensi
                                : 'Klik tombol "AI Analisis" untuk mengestimasi jumlah siswa dan pemetaan skema kejuruan yang cocok.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (lead.jurusanList.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: lead.jurusanList.map((j) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF93C5FD)),
                                  ),
                                  child: Text(
                                    j,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Perbarui Status Lead:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['lead', 'prospek', 'interest', 'sales'].map((st) {
                        final isSel = lead.leadStatus == st;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Center(
                                child: Text(
                                  _formatStatus(st),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                              selected: isSel,
                              selectedColor: _getStatusColor(st),
                              backgroundColor: const Color(0xFFF1F5F9),
                              showCheckmark: false,
                              onSelected: (_) {
                                Navigator.pop(ctx);
                                _changeStatus(lead, st);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openLeadInGoogleMaps(lead),
                            icon: const Icon(LucideIcons.map_pin, size: 16),
                            label: const Text('Buka Maps'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _runAiGenerator(lead);
                            },
                            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                            label: const Text('AI Analisis'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
          _buildKpiSummaryHeader(),

          // 2. Google Maps Nearby Quick Explore Keywords
          _buildGoogleMapsQuickExplore(),

          // 3. Search & Filter Bar
          _buildSearchAndCategoryFilters(),

          // 4. Lead List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredLeads.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                        itemCount: filteredLeads.length,
                        itemBuilder: (context, index) {
                          return _buildLeadCard(filteredLeads[index]);
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

  Widget _buildKpiSummaryHeader() {
    final total = _leads.length;
    final prospek = _leads.where((e) => e.leadStatus == 'prospek').length;
    final interest = _leads.where((e) => e.leadStatus == 'interest').length;
    final sales = _leads.where((e) => e.leadStatus == 'sales').length;
    final totalSiswa = _leads.fold<int>(0, (sum, item) => sum + item.estimasiSiswa);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.map_pin, color: Colors.white, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    'Peta Potensi: ${_kabupatenFilterController.text}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '±$totalSiswa Siswa/Thn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildKpiItem('Total Leads', total.toString(), Colors.white),
              _buildKpiItem('Prospek', prospek.toString(), const Color(0xFFFDE047)),
              _buildKpiItem('Interest', interest.toString(), const Color(0xFF93C5FD)),
              _buildKpiItem('Sales', sales.toString(), const Color(0xFF86EFAC)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String title, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMapsQuickExplore() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.map, size: 14, color: Color(0xFF2563EB)),
              const SizedBox(width: 6),
              const Text(
                'Jelajah Google Maps Terdekat:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                'Klik untuk buka Maps ↗',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickGmapsKeywords.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: Icon(item['icon'] as IconData, size: 14, color: item['color'] as Color),
                    label: Text(
                      item['label'].toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item['color'] as Color,
                      ),
                    ),
                    backgroundColor: (item['color'] as Color).withValues(alpha: 0.08),
                    side: BorderSide(color: (item['color'] as Color).withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onPressed: () {
                      _openGoogleMapsByKeyword(item['keyword'].toString());
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndCategoryFilters() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(LucideIcons.search, size: 15, color: Color(0xFF94A3B8)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 12.5),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama institusi atau alamat...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: const Icon(Icons.close_rounded, size: 15, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
        ),

        // Category Filter Chips
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _kategoriList.length,
            separatorBuilder: (context, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final cat = _kategoriList[index];
              final isSel = _selectedKategori == cat;
              return ChoiceChip(
                label: Text(cat),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? Colors.white : const Color(0xFF334155),
                ),
                selected: isSel,
                selectedColor: const Color(0xFF2563EB),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                ),
                showCheckmark: false,
                onSelected: (_) {
                  setState(() => _selectedKategori = cat);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeadCard(LeadModel lead) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailBottomSheet(lead),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(lead.leadKategori).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lead.leadKategori,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(lead.leadKategori),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (lead.kabupaten.isNotEmpty)
                    Text(
                      lead.kabupaten,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(lead.leadStatus).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatStatus(lead.leadStatus),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(lead.leadStatus),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lead.namaInstitusi,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.map_pin, size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      lead.leadLocation,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (lead.leadPotensi.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFF2563EB)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lead.leadPotensi,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF334155),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _openLeadInGoogleMaps(lead),
                    icon: const Icon(LucideIcons.map_pin, size: 12),
                    label: const Text('Buka Maps', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: () => _runAiGenerator(lead),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 12),
                    label: const Text('AI Analisis', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.map_pin_off, size: 44, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada lead ditemukan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gunakan tombol pencarian Maps di atas atau tambah lead baru',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddLeadDialog(),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Simpan Lead Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'SMK':
        return const Color(0xFF2563EB);
      case 'Kampus':
        return const Color(0xFF7C3AED);
      case 'LPK':
      case 'LKP':
        return const Color(0xFF0D9488);
      case 'BLK':
        return const Color(0xFFEA580C);
      case 'Dinas Pemda':
        return const Color(0xFF0284C7);
      case 'Perusahaan Swasta':
        return const Color(0xFF4F46E5);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'SMK':
        return LucideIcons.graduation_cap;
      case 'Kampus':
        return LucideIcons.building;
      case 'LPK':
      case 'LKP':
        return LucideIcons.award;
      case 'BLK':
        return LucideIcons.hammer;
      case 'Dinas Pemda':
        return LucideIcons.landmark;
      case 'Perusahaan Swasta':
        return LucideIcons.briefcase;
      default:
        return LucideIcons.map_pin;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sales':
        return const Color(0xFF16A34A);
      case 'interest':
        return const Color(0xFF2563EB);
      case 'prospek':
        return const Color(0xFFD97706);
      case 'lead':
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sales':
        return 'Sales';
      case 'interest':
        return 'Interest';
      case 'prospek':
        return 'Prospek';
      case 'lead':
      default:
        return 'Lead';
    }
  }
}
