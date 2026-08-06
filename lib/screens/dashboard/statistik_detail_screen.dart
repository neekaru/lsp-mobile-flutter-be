import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../models/sertifikat_models.dart';
import '../../widgets/custom_app_bar.dart';

class StatistikDetailScreen extends StatefulWidget {
  final String menuKey;

  const StatistikDetailScreen({super.key, required this.menuKey});

  @override
  State<StatistikDetailScreen> createState() => _StatistikDetailScreenState();
}

class _StatistikDetailScreenState extends State<StatistikDetailScreen> {
  bool _isLoading = true;
  String _searchQuery = '';

  // Data state
  DomisiliAsesorData? _domisiliData;
  List<KompetensiTeknisItem> _kompetensiList = [];
  MasaBerlakuAsesorData? _masaBerlakuData;
  List<JenisSkemaItem> _jenisSkemaList = [];
  List<MUKDistribusiItem> _mukList = [];
  List<MonthlyAssessment> _monthlyAssessments = [];
  List<SertifikatDistribusi> _sertifikatPerSkema = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

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
        case 'jenis_skema':
          _jenisSkemaList = await ApiService.getJenisSkema();
          break;
        case 'muk':
          _mukList = await ApiService.getMUKDistribusi();
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
    } catch (e) {
      debugPrint('Error loading statistik detail data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String get _screenTitle {
    switch (widget.menuKey) {
      case 'domisili_asesor':
        return 'Domisili Asesor';
      case 'kompetensi_teknis':
        return 'Kompetensi Teknis';
      case 'masa_berlaku':
        return 'Masa Berlaku Asesor';
      case 'jenis_skema':
        return 'Jenis Skema';
      case 'muk':
        return 'MUK (Materi Uji Kompetensi)';
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
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
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
      case 'jenis_skema':
        return _buildJenisSkemaContent();
      case 'muk':
        return _buildMUKContent();
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
        else
          ...items
              .where((i) =>
                  _searchQuery.isEmpty ||
                  i.provinsiNama.toLowerCase().contains(_searchQuery.toLowerCase()))
              .map((item) => _buildDomisiliCard(item)),
      ],
    );
  }

  Widget _buildDomisiliCard(DomisiliAsesorProvinsiItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        ],
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
            _KpiItem('Total Asesor', '${_kompetensiList.fold(0, (sum, i) => sum + i.jumlahAsesor)}', Colors.indigo),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  ],
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
        _buildStatusCard('Sertifikat Aktif', '${data?.aktif ?? 0}', 'Masa berlaku masih aktif', Colors.green, Icons.check_circle_outline),
        const SizedBox(height: 10),
        _buildStatusCard('Masa Tenggang', '${data?.tenggang ?? 0}', 'Kurang dari 3 bulan menuju expired', Colors.orange, Icons.warning_amber_rounded),
        const SizedBox(height: 10),
        _buildStatusCard('Expired / Kadaluarsa', '${data?.expired ?? 0}', 'Sertifikat sudah habis masa berlaku', Colors.red, Icons.cancel_outlined),
      ],
    );
  }

  Widget _buildStatusCard(String title, String count, String desc, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
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
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
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
            _KpiItem('Total Skema', '${_jenisSkemaList.fold(0, (sum, i) => sum + i.jumlahSkema)}', Colors.indigo),
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
            _KpiItem('Total MUK/MAPA', '${_mukList.fold(0, (sum, i) => sum + i.jumlahMuk)}', Colors.teal),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  ],
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
                    Text('${item.totalSertifikat} Kompeten', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF16A34A))),
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

  Widget _buildSearchField(String hint) {
    return TextField(
      onChanged: (val) => setState(() => _searchQuery = val),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
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
