import 'package:flutter/material.dart';
import '../pengajuan/pengajuan_sertifikat_screen.dart';

class DetailSkemaScreen extends StatefulWidget {
  final Map<String, dynamic> scheme;

  const DetailSkemaScreen({super.key, required this.scheme});

  @override
  State<DetailSkemaScreen> createState() => _DetailSkemaScreenState();
}

class _DetailSkemaScreenState extends State<DetailSkemaScreen> {
  int _activeTab = 0; // 0: Unit kompetensi, 1: Persyaratan
  bool _showAllUnits = false;

  // Custom unit details mapping to match the screenshots
  final Map<String, Map<String, String>> _unitDetails = {
    // Pemasaran Digital
    'Mengolah Data Riset': {
      'code': 'M.702090.002.02',
      'sub': 'Processing Research Data',
    },
    'Melaksanakan Kegiatan Analisis di Media Sosial': {
      'code': 'M.702090.012.1',
      'sub': 'Carrying out Analytical Activities on Social Media and Digital Business Media',
    },
    'Melakukan Aktivitas Pemasaran Digital': {
      'code': 'G.46MTS00.019.1',
      'sub': 'Conducting Digital Marketing activities for Retail Business',
    },
    'Menggunakan Media Sosial & Aplikasi Daring': {
      'code': 'M.702090.010.1',
      'sub': 'Using Social Media and Online Tools',
    },
    'Mempersiapkan Konten Digital': {
      'code': 'M.702090.014.1',
      'sub': 'Preparing Digital Content',
    },
    'Merancang Strategi Pemasaran Digital': {
      'code': 'M.702090.015.1',
      'sub': 'Designing Digital Marketing Strategy',
    },
    'Mengelola Hubungan Pelanggan secara Digital': {
      'code': 'M.702090.016.1',
      'sub': 'Managing Customer Relations Digitally',
    },
    'Mengukur Efektivitas Pemasaran Digital': {
      'code': 'M.702090.017.1',
      'sub': 'Measuring Digital Marketing Effectiveness',
    },
    'Mengoptimalkan Search Engine Optimization (SEO)': {
      'code': 'M.702090.018.1',
      'sub': 'Optimizing Search Engine Optimization (SEO)',
    },
    'Merencanakan Kampanye Iklan Berbayar (SEM)': {
      'code': 'M.702090.019.1',
      'sub': 'Planning Paid Advertising Campaigns (SEM)',
    },
    'Menganalisis Kinerja Pemasaran Digital': {
      'code': 'M.702090.020.1',
      'sub': 'Analyzing Digital Marketing Performance',
    },

    // Desain Multimedia Muda
    'Membuat Gambar Vektor': {
      'code': 'I.591200.001.01',
      'sub': 'Creating Vector Images',
    },
    'Editing Foto Digital': {
      'code': 'I.591200.002.01',
      'sub': 'Digital Photo Editing',
    },
    'Penyuntingan Audio & Video': {
      'code': 'I.591200.003.01',
      'sub': 'Audio & Video Editing',
    },
    'Desain Layout Publikasi': {
      'code': 'I.591200.004.01',
      'sub': 'Designing Publication Layouts',
    },
    'Pembuatan Animasi Dasar': {
      'code': 'I.591200.005.01',
      'sub': 'Basic Animation Creation',
    },
    'Pemodelan Objek 3D': {
      'code': 'I.591200.006.01',
      'sub': '3D Object Modeling',
    },
    'Integrasi Elemen Multimedia': {
      'code': 'I.591200.007.01',
      'sub': 'Multimedia Element Integration',
    },
    'Uji Kelayakan Produk Multimedia': {
      'code': 'I.591200.008.01',
      'sub': 'Multimedia Product Feasibility Testing',
    },

    // Manajer Proyek TIK
    'Penyusunan Project Charter': {
      'code': 'J.620100.001.02',
      'sub': 'Project Charter Compilation',
    },
    'Estimasi Biaya & Jadwal': {
      'code': 'J.620100.002.02',
      'sub': 'Cost & Schedule Estimation',
    },
    'Alokasi SDM Proyek': {
      'code': 'J.620100.003.01',
      'sub': 'Project HR Allocation',
    },
    'Mitigasi Risiko Proyek TIK': {
      'code': 'J.620100.004.02',
      'sub': 'ICT Project Risk Mitigation',
    },
    'Monitoring & Closing Proyek': {
      'code': 'J.620100.005.01',
      'sub': 'Project Monitoring & Closing',
    },

    // Pemprogram Basis Data
    'Merancang Entity Relationship Diagram': {
      'code': 'J.611000.001.01',
      'sub': 'Designing Entity Relationship Diagrams',
    },
    'Menulis Query SQL Kompleks': {
      'code': 'J.611000.002.01',
      'sub': 'Writing Complex SQL Queries',
    },
    'Optimasi Indeks & Kueri': {
      'code': 'J.611000.003.01',
      'sub': 'Index & Query Optimization',
    },
    'Backup & Recovery Data': {
      'code': 'J.611000.004.01',
      'sub': 'Data Backup & Recovery',
    },
    'Keamanan Database': {
      'code': 'J.611000.005.01',
      'sub': 'Database Security Management',
    },

    // Network Administrator Muda
    'Merancang Topologi Jaringan': {
      'code': 'J.611000.006.01',
      'sub': 'Designing Network Topology',
    },
    'Mengonfigurasi Switch & Router': {
      'code': 'J.611000.007.01',
      'sub': 'Configuring Switch & Router',
    },
    'Mengamankan Jaringan Nirkabel': {
      'code': 'J.611000.008.01',
      'sub': 'Securing Wireless Network',
    },
    'Melakukan Troubleshooting Jaringan': {
      'code': 'J.611000.009.01',
      'sub': 'Troubleshooting Network Issues',
    },
    'Membuat Dokumentasi Jaringan': {
      'code': 'J.611000.010.01',
      'sub': 'Creating Network Documentation',
    },

    // Ilmuwan Big Data
    'Pengumpulan Data Massal': {
      'code': 'J.620100.006.01',
      'sub': 'Massive Data Collection',
    },
    'Preprocessing & Cleaning Data': {
      'code': 'J.620100.007.01',
      'sub': 'Data Preprocessing & Cleaning',
    },
    'Analisis Statistik Deskriptif': {
      'code': 'J.620100.008.01',
      'sub': 'Descriptive Statistical Analysis',
    },
    'Implementasi Model Machine Learning': {
      'code': 'J.620100.009.01',
      'sub': 'Implementing Machine Learning Models',
    },
    'Visualisasi Data Interaktif': {
      'code': 'J.620100.010.01',
      'sub': 'Interactive Data Visualization',
    },

    // Graphic Design Expert
    'Mengaplikasikan Prinsip Dasar Desain': {
      'code': 'M.74100.001.02',
      'sub': 'Applying Basic Design Principles',
    },
    'Membuat Logo & Brand Identity': {
      'code': 'M.74100.002.02',
      'sub': 'Creating Logo & Brand Identity',
    },
    'Merancang Desain Publikasi': {
      'code': 'M.74100.003.01',
      'sub': 'Designing Publication Layouts',
    },
    'Membuat Kemasan Produk Kreatif': {
      'code': 'M.74100.004.02',
      'sub': 'Creating Creative Product Packaging',
    },
  };

  // Helper to get custom code or generate a consistent mock code based on text
  String _getUnitCode(String unitTitle) {
    if (_unitDetails.containsKey(unitTitle)) {
      return _unitDetails[unitTitle]!['code']!;
    }
    // Consistent fallback generator
    final int hash = unitTitle.split('').fold(0, (prev, char) => prev + char.codeUnitAt(0));
    return 'M.70100.0${(hash % 90 + 10)}.${(hash % 9 + 1)}';
  }

  // Helper to get English subtitle or generate a consistent fallback
  String _getUnitSubtitle(String unitTitle) {
    if (_unitDetails.containsKey(unitTitle)) {
      return _unitDetails[unitTitle]!['sub']!;
    }
    // Fallback translation approximation
    return 'Execution of competency in $unitTitle';
  }

  // Map scheme titles to specific scheme codes
  String _getSchemeCode(String title) {
    switch (title) {
      case 'Pemasaran Digital':
        return 'SKK-26-10/2024';
      case 'Desain Multimedia Muda':
        return 'SKK-08-05/2024';
      case 'Manajer Proyek TIK':
        return 'SKK-15-12/2024';
      case 'Pemprogram Basis Data':
        return 'SKK-14-06/2024';
      case 'Network Administrator Muda':
        return 'SKK-05-02/2024';
      case 'Ilmuwan Big Data':
        return 'SKK-10-09/2024';
      case 'Graphic Design Expert':
        return 'SKK-12-07/2024';
      default:
        final int hash = title.split('').fold(0, (prev, char) => prev + char.codeUnitAt(0));
        return 'SKK-${(hash % 90 + 10)}-${(hash % 12 + 1)}/2024';
    }
  }

  void _handleDownloadDokumen() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mengunduh dokumen skema ${widget.scheme['title']}...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    final title = scheme['title'] as String;
    final code = _getSchemeCode(title);
    final isOpen = scheme['isOpen'] as bool? ?? false;
    final unitList = scheme['unitList'] as List<dynamic>? ?? [];

    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CARD 1: Upper Detail Card
                  _buildUpperDetailCard(scheme, code, isOpen),
                  const SizedBox(height: 16),
                  // CARD 2: Tabs & Units Card
                  _buildTabsAndUnitsCard(unitList),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Black Back Arrow Button
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // Bold screen title
          const Text(
            'Detail Skema',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),

          // More options placeholder
          const Icon(
            Icons.more_horiz_rounded,
            color: Colors.black,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildUpperDetailCard(Map<String, dynamic> scheme, String code, bool isOpen) {
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
                        colors: scheme['colors'] as List<Color>? ?? [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      scheme['icon'] as IconData? ?? Icons.workspace_premium_rounded,
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
                          (scheme['title'] as String? ?? '').toUpperCase(),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PengajuanSertifikatScreen(),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: isOpen ? const Color(0xFF53A1E9) : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOpen ? 'Daftar Sekarang' : 'Pendaftaran Ditutup',
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
                _buildTableRow('Kode Skema', code),
                _buildTableRow('Nama Skema', scheme['title'] as String? ?? '-'),
                _buildTableRow('Jenis Skema', scheme['jenjang'] as String? ?? 'Klaster'),
                _buildTableRow('Izin Kemenkes', 'Belum'),
                _buildTableRow('Harga', scheme['price'] as String? ?? 'Rp. 0'),
                _buildTableRow('Dokumen Skema', 'Download', isLink: true),
                _buildTableRow('Ringkasan Skema', scheme['description'] as String? ?? '-'),
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

  Widget _buildTabsAndUnitsCard(List<dynamic> unitList) {
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

              // Cards List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: displayCount,
                itemBuilder: (context, index) {
                  final String unitTitle = unitList[index] as String;
                  final String unitCode = _getUnitCode(unitTitle);
                  final String unitSub = _getUnitSubtitle(unitTitle);

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
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
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
                                  unitCode,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  unitTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  unitSub,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ],
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
              _buildRequirementItem('1', 'Kartu Tanda Penduduk (KTP)'),
              _buildRequirementItem('2', 'Pas Foto Terbaru background merah'),
              _buildRequirementItem('3', 'Ijazah Terakhir'),
              _buildRequirementItem('4', 'Curriculum Vitae (CV) Terbaru'),
              _buildRequirementItem('5', 'Surat Rekomendasi Kerja / Sertifikat Pelatihan Terkait'),
            ],
          ],
        ),
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
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
          if (isSelected)
            Container(
              height: 2,
              width: 40,
              color: const Color(0xFF3B82F6),
            )
          else
            const SizedBox(height: 2),
        ],
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
}
