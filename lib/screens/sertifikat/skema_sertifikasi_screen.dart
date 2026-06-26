// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../pengajuan/pengajuan_sertifikat_screen.dart';

class SkemaSertifikasiScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const SkemaSertifikasiScreen({super.key, this.onBackToHome});

  @override
  State<SkemaSertifikasiScreen> createState() => _SkemaSertifikasiScreenState();
}

class _SkemaSertifikasiScreenState extends State<SkemaSertifikasiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua Skema';
  int _currentPage = 1;

  final List<Map<String, dynamic>> _schemes = [
    {
      'title': 'Skema Digital Marketing',
      'status': 'Pendaftaran Dibuka',
      'isOpen': true,
      'tags': ['S.S.D. Kemitraan'],
      'units': '8 Unit Kompetensi',
      'price': 'Rp. 1.500.000',
      'colors': [Color(0xFFFFF9C4), Color(0xFFFFB74D)],
      'icon': Icons.campaign_rounded,
      'description': 'Mempelajari strategi pemasaran digital, SEO, SEM, social media marketing, dan analytics.',
      'unitList': [
        'Mengolah Data Riset',
        'Melaksanakan Kegiatan Analisis di Media Sosial',
        'Melakukan Aktivitas Pemasaran Digital',
        'Menggunakan Media Sosial & Aplikasi Daring',
        'Mempersiapkan Konten Digital',
        'Merancang Strategi Pemasaran Digital',
        'Mengelola Hubungan Pelanggan secara Digital',
        'Mengukur Efektivitas Pemasaran Digital'
      ]
    },
    {
      'title': 'Network Administrator Muda',
      'status': 'Pendaftaran Dibuka',
      'isOpen': true,
      'tags': ['S.S.D. Mandiri'],
      'units': '5 Unit Kompetensi',
      'price': 'Rp. 1.520.000',
      'colors': [Color(0xFFE3F2FD), Color(0xFF64B5F6)],
      'icon': Icons.dns_rounded,
      'description': 'Mempersiapkan tenaga ahli dalam instalasi, konfigurasi, dan pemeliharaan jaringan komputer skala kecil-menengah.',
      'unitList': [
        'Merancang Topologi Jaringan',
        'Mengonfigurasi Switch & Router',
        'Mengamankan Jaringan Nirkabel',
        'Melakukan Troubleshooting Jaringan',
        'Membuat Dokumentasi Jaringan'
      ]
    },
    {
      'title': 'Ilmuwan Big Data',
      'status': 'Pendaftaran Dibuka',
      'isOpen': true,
      'tags': ['Populer'],
      'units': '10 Unit Kompetensi',
      'price': 'Rp. 1.650.000',
      'colors': [Color(0xFFF3E5F5), Color(0xFFBA68C8)],
      'icon': Icons.analytics_rounded,
      'description': 'Melatih keterampilan analitik tingkat lanjut untuk mengolah big data, machine learning, dan visualisasi data.',
      'unitList': [
        'Pengumpulan Data Massal',
        'Preprocessing & Cleaning Data',
        'Analisis Statistik Deskriptif',
        'Implementasi Model Machine Learning',
        'Visualisasi Data Interaktif'
      ]
    },
    {
      'title': 'Pemprogram Basis Data',
      'status': 'Pendaftaran Ditutup',
      'isOpen': false,
      'tags': ['Sertifikasi'],
      'units': '14 Unit Kompetensi',
      'price': 'Rp. 1.500.000',
      'colors': [Color(0xFFFFEBEE), Color(0xFFE57373)],
      'icon': Icons.storage_rounded,
      'description': 'Fokus pada pemodelan data, query SQL, optimasi database, keamanan, dan administrasi RDBMS.',
      'unitList': [
        'Merancang Entity Relationship Diagram',
        'Menulis Query SQL Kompleks',
        'Optimasi Indeks & Kueri',
        'Backup & Recovery Data',
        'Keamanan Database'
      ]
    },
    {
      'title': 'Desain Multimedia Muda',
      'status': 'Pendaftaran Dibuka',
      'isOpen': true,
      'tags': ['Populer'],
      'units': '6 Unit Kompetensi',
      'price': 'Rp. 900.000',
      'colors': [Color(0xFFE0F7FA), Color(0xFF4DD0E1)],
      'icon': Icons.palette_rounded,
      'description': 'Pengembangan aset visual 2D/3D, audio/video editing, dan pembuatan layout kreatif.',
      'unitList': [
        'Membuat Gambar Vektor',
        'Editing Foto Digital',
        'Penyuntingan Audio & Video',
        'Desain Layout Publikasi',
        'Pembuatan Animasi Dasar'
      ]
    },
    {
      'title': 'Manajer Proyek TIK',
      'status': 'Pendaftaran Dibuka',
      'isOpen': true,
      'tags': ['E-Uji', 'Populer'],
      'units': '15 Unit Kompetensi',
      'price': 'Rp. 2.000.000',
      'colors': [Color(0xFFE8EAF6), Color(0xFF7986CB)],
      'icon': Icons.assignment_rounded,
      'description': 'Manajemen siklus hidup proyek IT menggunakan framework Agile & Waterfall, alokasi resource, dan risk mitigation.',
      'unitList': [
        'Penyusunan Project Charter',
        'Estimasi Biaya & Jadwal',
        'Alokasi SDM Proyek',
        'Mitigasi Risiko Proyek TIK',
        'Monitoring & Closing Proyek'
      ]
    },
    {
      'title': 'Pemprogram Basis Data',
      'status': 'Pendaftaran Ditutup',
      'isOpen': false,
      'tags': ['Sertifikasi'],
      'units': '14 Unit Kompetensi',
      'price': 'Rp. 1.500.000',
      'colors': [Color(0xFFFFEBEE), Color(0xFFE57373)],
      'icon': Icons.storage_rounded,
      'description': 'Fokus pada pemodelan data, query SQL, optimasi database, keamanan, dan administrasi RDBMS.',
      'unitList': [
        'Merancang Entity Relationship Diagram',
        'Menulis Query SQL Kompleks',
        'Optimasi Indeks & Kueri'
      ]
    },
    {
      'title': 'Desain Multimedia Muda',
      'status': 'Pendaftaran Dibuka',
      'isOpen': true,
      'tags': ['Populer'],
      'units': '6 Unit Kompetensi',
      'price': 'Rp. 1.100.000',
      'colors': [Color(0xFFE0F7FA), Color(0xFF4DD0E1)],
      'icon': Icons.palette_rounded,
      'description': 'Pengembangan aset visual 2D/3D, audio/video editing, dan pembuatan layout kreatif.',
      'unitList': [
        'Membuat Gambar Vektor',
        'Editing Foto Digital',
        'Penyuntingan Audio & Video'
      ]
    },
    {
      'title': 'Manajer Proyek TIK',
      'status': 'Pendaftaran Dibuka',
      'isOpen': true,
      'tags': ['E-Uji', 'Populer'],
      'units': '15 Unit Kompetensi',
      'price': 'Rp. 2.000.000',
      'colors': [Color(0xFFE8EAF6), Color(0xFF7986CB)],
      'icon': Icons.assignment_rounded,
      'description': 'Manajemen siklus hidup proyek IT menggunakan framework Agile & Waterfall, alokasi resource, dan risk mitigation.',
      'unitList': [
        'Penyusunan Project Charter',
        'Estimasi Biaya & Jadwal',
        'Alokasi SDM Proyek'
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredSchemes() {
    final query = _searchController.text.toLowerCase();
    return _schemes.where((scheme) {
      final matchesQuery = query.isEmpty ||
          scheme['title'].toString().toLowerCase().contains(query);

      if (_selectedFilter == 'Semua Skema') {
        return matchesQuery;
      } else if (_selectedFilter == 'Populer') {
        final tags = scheme['tags'] as List<String>;
        return matchesQuery && tags.contains('Populer');
      } else if (_selectedFilter == 'Digital') {
        return matchesQuery &&
            (scheme['title'].toString().toLowerCase().contains('digital') ||
                scheme['title'].toString().toLowerCase().contains('multimedia'));
      }
      return matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final filteredSchemes = _getFilteredSchemes();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          // Header Widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.onBackToHome != null) {
                      widget.onBackToHome!();
                    } else {
                      Navigator.of(context).pop();
                    }
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
                const Text(
                  'Skema Sertifikasi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ),

          // Search Bar Widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari skema',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),

          // Filter Row Widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterButton('Semua Skema'),
                const SizedBox(width: 8),
                _buildFilterButton('Populer'),
                const SizedBox(width: 8),
                _buildFilterButton('Digital'),
              ],
            ),
          ),

          // Grid View of Schemes
          Expanded(
            child: filteredSchemes.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.43,
                    ),
                    itemCount: filteredSchemes.length,
                    itemBuilder: (context, index) {
                      final scheme = filteredSchemes[index];
                      return _buildSchemeCard(scheme);
                    },
                  ),
          ),

          // Pagination Widget
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filterName) {
    final bool isSelected = _selectedFilter == filterName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5E80B0) : const Color(0xFFD6E6F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          filterName,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2C6C9C),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeCard(Map<String, dynamic> scheme) {
    final colors = scheme['colors'] as List<Color>;
    final isOpen = scheme['isOpen'] as bool;
    final tags = scheme['tags'] as List<String>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Graphic header
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    scheme['icon'] as IconData,
                    size: 56,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                Center(
                  child: Icon(
                    scheme['icon'] as IconData,
                    size: 28,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOpen ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      scheme['status'] as String,
                      style: TextStyle(
                        color: isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Expanded(
                    child: Text(
                      scheme['title'] as String,
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Tags Row
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: tags.map((tag) {
                        final isPopular = tag == 'Populer';
                        final isEUji = tag == 'E-Uji';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isPopular
                                ? const Color(0xFFFFEBEE)
                                : isEUji
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isPopular
                                  ? const Color(0xFFC62828)
                                  : isEUji
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF1565C0),
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const Divider(height: 12, color: Color(0xFFF1F5F9)),

                  // Details rows
                  Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, size: 10, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          scheme['units'] as String,
                          style: const TextStyle(fontSize: 8, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 10, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          scheme['price'] as String,
                          style: const TextStyle(fontSize: 8, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () => _showSchemeDetail(scheme),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A9EDF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Lihat Skema',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSchemeDetail(Map<String, dynamic> scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: scheme['colors'] as List<Color>,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(scheme['icon'] as IconData, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scheme['units'] as String,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Deskripsi Skema',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Text(
                scheme['description'] as String,
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 20),
              const Text(
                'Daftar Unit Kompetensi Utama',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: (scheme['unitList'] as List<String>).length,
                  itemBuilder: (context, idx) {
                    final unit = (scheme['unitList'] as List<String>)[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF4A9EDF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              unit,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Biaya Pendaftaran',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scheme['price'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C6C9C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: (scheme['isOpen'] as bool)
                        ? () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PengajuanSertifikatScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Daftar Skema', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF0284C7)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Skema Tidak Ditemukan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba ketik kata kunci pencarian yang lain.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            color: const Color(0xFF2C6C9C),
            disabledColor: Colors.grey[300],
          ),
          _buildPageNumber(1),
          _buildPageNumber(2),
          _buildPageNumber(3),
          IconButton(
            onPressed: _currentPage < 3
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            color: const Color(0xFF2C6C9C),
            disabledColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    final bool isSelected = _currentPage == page;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = page;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          page.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
