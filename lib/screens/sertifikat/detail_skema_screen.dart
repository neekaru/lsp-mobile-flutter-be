import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/sertifikat_models.dart';
import '../../services/sertifikat_service.dart';
import '../pengajuan/pengajuan_sertifikat_screen.dart';
import '../pengajuan/konfirmasi_pendaftaran_screen.dart';

class DetailSkemaScreen extends StatefulWidget {
  final int skemaId;
  final Map<String, dynamic>? schemePreview;

  const DetailSkemaScreen({
    super.key,
    required this.skemaId,
    this.schemePreview,
  });

  @override
  State<DetailSkemaScreen> createState() => _DetailSkemaScreenState();
}

class _DetailSkemaScreenState extends State<DetailSkemaScreen> {
  int _activeTab = 0; // 0: Unit kompetensi, 1: Persyaratan
  bool _showAllUnits = false;
  final Set<int> _expandedUnitIndices = {};

  SkemaSertifikatDetailResponse? _detail;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      final detail = await SertifikatService.getSkemaDetail(widget.skemaId);
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _handleDownloadDokumen() {
    final link = _detail?.linkDownload ?? '';
    if (link.isNotEmpty) {
      // TODO: implement actual download via url_launcher
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mengunduh dokumen skema ${_detail?.title ?? ""}...'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dokumen skema tidak tersedia.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A9EDF)))
                : _isError
                    ? _buildErrorState()
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildUpperDetailCard(),
                            const SizedBox(height: 16),
                            _buildTabsAndUnitsCard(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return const CustomAppBar(
      title: 'Detail Skema',
    );
  }

  Widget _buildUpperDetailCard() {
    final detail = _detail!;
    final preview = widget.schemePreview;
    final colors = preview?['colors'] as List<Color>? ??
        [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)];
    final icon = preview?['icon'] as IconData? ?? Icons.workspace_premium_rounded;
    final isOpen = preview?['isOpen'] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Icon + Title + Daftar Sekarang Button wrapped in light blue container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon block
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: isOpen
                              ? () {
                                  if (detail.isAlreadyRegistered) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => KonfirmasiPendaftaranScreen(
                                          skemaId: widget.skemaId,
                                          title: detail.title,
                                          kodeSkema: detail.kodeSkema,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PengajuanSertifikatScreen(),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: isOpen ? const Color(0xFF53A1E9) : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              detail.isAlreadyRegistered
                                  ? 'Sudah Terdaftar'
                                  : isOpen
                                      ? 'Daftar Sekarang'
                                      : 'Pendaftaran Ditutup',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Table of fields
            Table(
              columnWidths: const {
                0: FixedColumnWidth(110),
                1: FixedColumnWidth(20),
                2: FlexColumnWidth(),
              },
              border: TableBorder.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
              children: [
                _buildTableRow('Kode Skema', detail.kodeSkema),
                _buildTableRow('Nama Skema', detail.title),
                _buildTableRow('Jenis Skema', detail.jenjang),
                _buildTableRow('Izin Kemenkes', 'Belum'),
                _buildTableRow('Harga', detail.price),
                _buildTableRow('Dokumen Skema', 'Download', isLink: true),
                _buildTableRow('Ringkasan Skema', detail.description),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, {bool isLink = false}) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              ':',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: isLink
                ? GestureDetector(
                    onTap: _handleDownloadDokumen,
                    child: const Text(
                      'Download',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabsAndUnitsCard() {
    final detail = _detail!;
    final unitList = detail.unitList;
    final persyaratan = detail.persyaratan;
    final int displayCount = _showAllUnits ? unitList.length : (unitList.length > 5 ? 5 : unitList.length);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Tabs Layout
            Row(
              children: [
                _buildTabItem(0, 'Unit kompetensi'),
                const SizedBox(width: 16),
                _buildTabItem(1, 'Persyaratan'),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Tab Content
            if (_activeTab == 0) ...[
              // Tab: Unit Kompetensi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Unit kompetensi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '${unitList.length} Unit',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cards List (Accordion Accordion)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: displayCount,
                itemBuilder: (context, index) {
                  final unit = unitList[index];
                  final bool isExpanded = _expandedUnitIndices.contains(index);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedUnitIndices.remove(index);
                          } else {
                            _expandedUnitIndices.add(index);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        unit.code,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        unit.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      if (unit.subtitle.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          unit.subtitle,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.chevron_right_rounded,
                                  color: const Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              if (unit.deskripsi.isNotEmpty || unit.elemen.isNotEmpty || unit.kriteria.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                
                                if (unit.deskripsi.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildDetailSection(
                                    titleLetter: 'A.',
                                    titleText: 'Deskripsi Unit',
                                    child: Text(
                                      unit.deskripsi,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                                
                                if (unit.elemen.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildDetailSection(
                                    titleLetter: 'B.',
                                    titleText: 'Elemen Kompetensi',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: unit.elemen.map((e) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '> ',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                e,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )).toList(),
                                    ),
                                  ),
                                ],
                                
                                if (unit.kriteria.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildDetailSection(
                                    titleLetter: 'C.',
                                    titleText: 'Kriteria Untuk Ujian',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: unit.kriteria.asMap().entries.map((entry) {
                                        final idx = entry.key + 1;
                                        final val = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$idx. ',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  val,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF64748B),
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ] else ...[
                                const SizedBox(height: 12),
                                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                const SizedBox(height: 12),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Detail unit kompetensi tidak tersedia.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Lainnya Button
              if (unitList.length > 5 && !_showAllUnits)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAllUnits = true;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Lainnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
            ] else ...[
              // Tab: Persyaratan
              const Text(
                'Syarat & Ketentuan Pendaftaran',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              if (persyaratan.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Tidak ada persyaratan yang tercantum.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: persyaratan.length,
                  itemBuilder: (context, index) {
                    return _buildRequirementItem(
                      (index + 1).toString(),
                      persyaratan[index],
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String titleLetter,
    required String titleText,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Text(
                titleLetter,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Expanded(
              child: Text(
                titleText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Expanded(child: child),
          ],
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, String title) {
    final bool isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String num, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, size: 36, color: Color(0xFFDC2626)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal Memuat Detail Skema',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A9EDF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
