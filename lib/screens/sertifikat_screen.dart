import 'package:flutter/material.dart';
import '../models/sertifikat_models.dart';
import '../widgets/sertifikat/skema_chart_card.dart';
import '../widgets/sertifikat/sertifikat_summary_card.dart';
import '../widgets/sertifikat/sertifikat_item_card.dart';

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
      kategori: 'SMK Media Infomatika - Digital Enginer',
      jumlah: 1251,
      persentase: 31.6,
      color: '0D47A1', // Dark Blue
    ),
    SertifikatDistribusi(
      kategori: 'SMK Media Infomatika - Digital Marketing',
      jumlah: 978,
      persentase: 24.7,
      color: '1976D2', // Bright Blue
    ),
    SertifikatDistribusi(
      kategori: 'SMK Media Infomatika - Data Analyst',
      jumlah: 748,
      persentase: 18.9,
      color: '42A5F5', // Mid Blue
    ),
    SertifikatDistribusi(
      kategori: 'SMK Media Infomatika - Mobile Developer',
      jumlah: 558,
      persentase: 14.1,
      color: '90CAF9', // Light Blue
    ),
    SertifikatDistribusi(
      kategori: 'SMK Media Infomatika - UI/UX Designer',
      jumlah: 425,
      persentase: 10.6,
      color: 'BBDEFB', // Very Light Blue
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
                    
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
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
                      ),
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
    return const SertifikatSummaryCard(
      totalPemegang: '22.600',
      totalSkema: '2.000',
      topSkemaName: 'Digital\nMarketing',
      topSkemaPemegang: '1.300 Pemegang',
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
            return SertifikatItemCard(item: item);
          },
        ),
      ],
    );
  }



  Widget _buildPemegangSertifikatSection() {
    return SkemaChartCard(distribusiData: distribusiData);
  }
}
