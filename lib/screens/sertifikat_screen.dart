import 'package:flutter/material.dart';
import '../models/sertifikat_models.dart';
import '../services/api_service.dart';
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
  bool _isLoading = true;
  List<SertifikatDistribusi> _distribusiData = [];
  SertifikatSummary? _summary;
  String _periode = '';

  // Daftar skema untuk filter
  List<String> _skemaList = ['Semua Skema'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch data dari API
      final summaryFuture = ApiService.getSertifikatSummary();
      final distribusiFuture = ApiService.getSertifikatPerSkema(limit: 50);
      
      final results = await Future.wait([summaryFuture, distribusiFuture]);
      final summary = results[0] as SertifikatSummary;
      final response = results[1] as SertifikatApiResponse;
      
      setState(() {
        _summary = summary;
        _distribusiData = response.data;
        _periode = response.meta.periode ?? summary.periode;
        
        // Build skema list untuk filter
        _skemaList = ['Semua Skema'];
        final uniqueKategori = <String>{};
        for (var item in response.data) {
          uniqueKategori.add(item.kategori);
        }
        _skemaList.addAll(uniqueKategori.toList()..sort());
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading sertifikat data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mock data - dalam implementasi nyata, ambil dari API
  final SertifikatRingkasan ringkasan = SertifikatRingkasan.fallback();

  // Mock data untuk hasil pencarian
  final List<SertifikatItem> _allSertifikat = const [];

  // Fungsi untuk filter distribusi data berdasarkan kategori yang dipilih
  List<SertifikatDistribusi> _getFilteredDistribusi() {
    List<SertifikatDistribusi> filtered;
    
    if (_selectedSkema == 'Semua Skema') {
      filtered = _distribusiData.take(10).toList(); // Ambil top 10
    } else {
      filtered = _distribusiData
          .where((item) => item.kategori == _selectedSkema)
          .take(10)
          .toList();
    }
    
    // Recalculate percentages based on filtered data
    if (filtered.isEmpty) return filtered;
    
    final totalFiltered = filtered.fold<int>(
      0, 
      (sum, item) => sum + item.totalPemegang
    );
    
    final colors = [
      '0D47A1', '1976D2', '42A5F5', '64B5F6', 
      '90CAF9', 'BBDEFB', '5B9FD8',
    ];
    
    return filtered.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final newPersentase = totalFiltered > 0 
          ? (item.totalPemegang / totalFiltered * 100) 
          : 0.0;
      
      return SertifikatDistribusi(
        idSkema: item.idSkema,
        kodeSkema: item.kodeSkema,
        skema: item.skema,
        kategori: item.kategori,
        totalPemegang: item.totalPemegang,
        persentase: newPersentase,
        color: colors[index % colors.length],
      );
    }).toList();
  }

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
    if (_isLoading || _summary == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Format angka dengan pemisah ribuan
    String formatNumber(int number) {
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }

    // Format nama skema untuk display (max 2 baris)
    String topSkemaName = _summary!.topSkema.skema;
    if (topSkemaName.length > 30) {
      // Cari spasi terdekat untuk break line
      int breakPoint = topSkemaName.indexOf(' ', 15);
      if (breakPoint > 0 && breakPoint < 30) {
        topSkemaName = '${topSkemaName.substring(0, breakPoint)}\n${topSkemaName.substring(breakPoint + 1)}';
      }
    }

    return SertifikatSummaryCard(
      totalPemegang: formatNumber(_summary!.totalPemegangSertifikat),
      totalSkema: formatNumber(_summary!.totalSkema),
      topSkemaName: topSkemaName,
      topSkemaPemegang: '${formatNumber(_summary!.topSkema.totalPemegang)} Pemegang',
      trendPemegang: _summary!.trends.pemegangSertifikat.formatted,
      trendSkema: _summary!.trends.skema.formatted,
      trendPemegangDirection: _summary!.trends.pemegangSertifikat.direction,
      trendSkemaDirection: _summary!.trends.skema.direction,
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
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filteredData = _getFilteredDistribusi();
    
    if (filteredData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return SkemaChartCard(
      distribusiData: filteredData,
      periode: _periode,
    );
  }
}
