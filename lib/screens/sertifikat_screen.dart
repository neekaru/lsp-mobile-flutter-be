import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/sertifikat_models.dart';

class SertifikatScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  
  const SertifikatScreen({super.key, this.onBackToHome});

  @override
  State<SertifikatScreen> createState() => _SertifikatScreenState();
}

class _SertifikatScreenState extends State<SertifikatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSkema = 'Semua Skema';
  bool _isSearching = false;
  List<SertifikatItem> _searchResults = [];

  // Daftar skema untuk filter
  final List<String> _skemaList = [
    'Semua Skema',
    'Digital Marketing',
    'Digital Engineer',
    'Data Analyst',
    'Mobile Developer',
    'UI/UX Designer',
    'Network Administrator',
  ];

  // Mock data - dalam implementasi nyata, ambil dari API
  final SertifikatRingkasan ringkasan = SertifikatRingkasan.fallback();

  // Mock data untuk hasil pencarian
  final List<SertifikatItem> _allSertifikat = const [
    SertifikatItem(
      id: 1,
      skema: 'Digital Marketing',
      pemegang: 'Ahmad Rizki',
      nomorSertifikat: 'CERT-2025-001',
      tanggalTerbit: '2025-01-15',
      tanggalBerlaku: '2028-01-15',
      status: 'aktif',
      kategori: 'Digital Marketing',
      institusi: 'LSP Digital Indonesia',
    ),
    SertifikatItem(
      id: 2,
      skema: 'Digital Engineer',
      pemegang: 'Budi Santoso',
      nomorSertifikat: 'CERT-2025-002',
      tanggalTerbit: '2025-02-10',
      tanggalBerlaku: '2028-02-10',
      status: 'aktif',
      kategori: 'Digital Engineer',
      institusi: 'LSP Teknologi Maju',
    ),
    SertifikatItem(
      id: 3,
      skema: 'Data Analyst',
      pemegang: 'Siti Aminah',
      nomorSertifikat: 'CERT-2025-003',
      tanggalTerbit: '2025-03-05',
      tanggalBerlaku: '2028-03-05',
      status: 'aktif',
      kategori: 'Data Analyst',
      institusi: 'LSP Data Science',
    ),
    SertifikatItem(
      id: 4,
      skema: 'Mobile Developer',
      pemegang: 'Dewi Lestari',
      nomorSertifikat: 'CERT-2025-004',
      tanggalTerbit: '2025-04-20',
      tanggalBerlaku: '2028-04-20',
      status: 'aktif',
      kategori: 'Mobile Developer',
      institusi: 'LSP Mobile Tech',
    ),
    SertifikatItem(
      id: 5,
      skema: 'UI/UX Designer',
      pemegang: 'Eko Prasetyo',
      nomorSertifikat: 'CERT-2025-005',
      tanggalTerbit: '2025-05-12',
      tanggalBerlaku: '2028-05-12',
      status: 'aktif',
      kategori: 'UI/UX Designer',
      institusi: 'LSP Creative Design',
    ),
  ];

  final List<SertifikatDistribusi> distribusiData = const [
    SertifikatDistribusi(
      kategori: 'Digital Marketing',
      jumlah: 1080,
      persentase: 27.1,
      color: '5B47D8', // Purple
    ),
    SertifikatDistribusi(
      kategori: 'Digital Engineer',
      jumlah: 800,
      persentase: 20.1,
      color: '4CAF50', // Green
    ),
    SertifikatDistribusi(
      kategori: 'Data Analyst',
      jumlah: 750,
      persentase: 18.8,
      color: 'FF9800', // Orange
    ),
    SertifikatDistribusi(
      kategori: 'Mobile Developer',
      jumlah: 700,
      persentase: 17.6,
      color: '2196F3', // Blue
    ),
    SertifikatDistribusi(
      kategori: 'UI/UX Designer',
      jumlah: 650,
      persentase: 16.3,
      color: 'E91E63', // Pink
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk melakukan pencarian berdasarkan nama pemegang sertifikat
  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _searchResults = [];
      } else {
        _isSearching = true;
        _searchResults = _allSertifikat.where((sertifikat) {
          final nameLower = sertifikat.pemegang.toLowerCase();
          final queryLower = query.toLowerCase();
          
          return nameLower.contains(queryLower);
        }).toList();
      }
    });
  }

  // Fungsi untuk menampilkan dialog filter skema
  void _showSkemaFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pilih Skema',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(height: 1),
              // List of skema
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _skemaList.length,
                  itemBuilder: (context, index) {
                    final skema = _skemaList[index];
                    final isSelected = skema == _selectedSkema;
                    
                    return ListTile(
                      title: Text(
                        skema,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? const Color(0xFF5B9FD8) : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF5B9FD8),
                              size: 24,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedSkema = skema;
                        });
                        Navigator.pop(context);
                        
                        // Tampilkan snackbar untuk feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              skema == 'Semua Skema'
                                  ? 'Menampilkan semua skema'
                                  : 'Filter: $skema',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: widget.onBackToHome == null,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && widget.onBackToHome != null) {
          widget.onBackToHome!();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          // Header with consistent style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circular Black Back Arrow Button
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
                
                // Bold screen title
                const Text(
                  'Skema Pemegang Sertifikat',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                
                // More options horizontal ellipsis
                const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // Ringkasan Section
                  const Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary Cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Conditional: Show search results or chart section
                  _isSearching
                      ? _buildSearchResults()
                      : _buildPemegangSertifikatSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Cari pemegang sertifikat',
                hintStyle: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9E9E9E),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Color(0xFF9E9E9E),
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _showSkemaFilterDialog,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _selectedSkema,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.people,
            iconColor: const Color(0xFF5B47D8),
            iconBgColor: const Color(0xFFE8E5FB),
            title: 'Total Pemegang Sertifikat',
            value: '3.980',
            percentage: '+15,7%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.school,
            iconColor: const Color(0xFF4CAF50),
            iconBgColor: const Color(0xFFE8F5E9),
            title: 'Total Skema',
            value: '2.000',
            percentage: '+16,8%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.workspace_premium,
            iconColor: const Color(0xFFFF9800),
            iconBgColor: const Color(0xFFFFF3E0),
            title: 'Total Sertifikat Terbit',
            value: '8.000',
            percentage: '+18,7%',
            isPositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String percentage,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              percentage,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba kata kunci lain',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hasil Pencarian (${_searchResults.length})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _searchResults[index];
            return _buildSertifikatCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildSertifikatCard(SertifikatItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E5FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFF5B47D8),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.pemegang,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.skema,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No. Sertifikat',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.nomorSertifikat,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Berlaku Hingga',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.tanggalBerlaku,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.institusi != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.business,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.institusi!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPemegangSertifikatSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pemegang Sertifikat Perskema (Top 5 Skema)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Berdasarkan Jumlah Pemegang Sertifikat',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Mei 2025',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Donut Chart and Legend
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donut Chart
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(140, 140),
                      painter: DonutChartPainter(distribusiData),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '3.980',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: distribusiData.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(int.parse('FF${item.color}', radix: 16)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.kategori,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.persentase.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 12),

          // Footer note
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Data diperbarui per Mei 2025',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk Donut Chart
class DonutChartPainter extends CustomPainter {
  final List<SertifikatDistribusi> data;

  DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6;

    double startAngle = -math.pi / 2; // Start from top

    for (var item in data) {
      final sweepAngle = (item.persentase / 100) * 2 * math.pi;
      
      final paint = Paint()
        ..color = Color(int.parse('FF${item.color}', radix: 16))
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
