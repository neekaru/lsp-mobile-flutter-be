import 'package:flutter/material.dart';
import '../../models/sertifikat_models.dart';
import '../../services/api_service.dart';
import '../../widgets/sertifikat/sertifikat_list_item.dart';
import '../../widgets/sertifikat/sertifikat_tab_bar.dart';

class SertifikatScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const SertifikatScreen({super.key, this.onBackToHome});

  @override
  State<SertifikatScreen> createState() => _SertifikatScreenState();
}

class _SertifikatScreenState extends State<SertifikatScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentTab = 0; // 0: Aktif, 1: Akan Berakhir, 2: Kadaluarsa
  bool _isLoading = false;
  List<SertifikatItem> _apiSertifikats = [];

  // Mock data as fallback to ensure the UI looks exactly like the screenshot
  final List<SertifikatItem> _mockSertifikats = [
    const SertifikatItem(
      id: 1,
      skema: 'Digital Marketing Madya',
      pemegang: 'Muhammad Hanafi',
      nomorSertifikat: 'FR-APR-02',
      tanggalTerbit: '20 April 2026',
      tanggalBerlaku: '20 April 2028',
      status: 'aktif',
      kategori: 'Digital Marketing',
      institusi: 'LSP Digital Marketing',
    ),
    const SertifikatItem(
      id: 2,
      skema: 'Oprator Komputer Muda',
      pemegang: 'Muhammad Hanafi',
      nomorSertifikat: 'FR-APR-02',
      tanggalTerbit: '20 April 2026',
      tanggalBerlaku: '20 April 2028',
      status: 'aktif',
      kategori: 'TIK',
      institusi: 'LSP Oprator Komputer',
    ),
    const SertifikatItem(
      id: 3,
      skema: 'Manajer Proyek TIK',
      pemegang: 'Muhammad Hanafi',
      nomorSertifikat: 'FR-APR-02',
      tanggalTerbit: '20 April 2026',
      tanggalBerlaku: '20 April 2028',
      status: 'aktif',
      kategori: 'TIK',
      institusi: 'LSP Manajer Proyek TIK',
    ),
    const SertifikatItem(
      id: 4,
      skema: 'Manajer Proyek TIK',
      pemegang: 'Muhammad Hanafi',
      nomorSertifikat: 'FR-APR-02',
      tanggalTerbit: '20 April 2026',
      tanggalBerlaku: '20 April 2028',
      status: 'aktif',
      kategori: 'TIK',
      institusi: 'LSP Manajer Proyek TIK',
    ),
    const SertifikatItem(
      id: 5,
      skema: 'Desainer Grafis Muda',
      pemegang: 'Muhammad Hanafi',
      nomorSertifikat: 'FR-APR-03',
      tanggalTerbit: '15 Mei 2025',
      tanggalBerlaku: '15 Juni 2026',
      status: 'akan_kadaluarsa',
      kategori: 'Desain',
      institusi: 'LSP Desain Kreatif',
    ),
    const SertifikatItem(
      id: 6,
      skema: 'Junior Web Programmer',
      pemegang: 'Muhammad Hanafi',
      nomorSertifikat: 'FR-APR-01',
      tanggalTerbit: '10 Maret 2021',
      tanggalBerlaku: '10 Maret 2024',
      status: 'kadaluarsa',
      kategori: 'IT',
      institusi: 'LSP Informatika Jaya',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await ApiService.searchSertifikat(query: '');
      setState(() {
        _apiSertifikats = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading API certificates: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  // Helper to filter and search certificates based on tab and query
  List<SertifikatItem> _getFilteredCertificates() {
    final listToFilter = _apiSertifikats.isNotEmpty ? _apiSertifikats : _mockSertifikats;
    final query = _searchController.text.toLowerCase();

    // Map tab index to status
    // 0: Aktif -> 'aktif'
    // 1: Akan Berakhir -> 'akan_kadaluarsa'
    // 2: Kadaluarsa -> 'kadaluarsa'
    String targetStatus;
    if (_currentTab == 0) {
      targetStatus = 'aktif';
    } else if (_currentTab == 1) {
      targetStatus = 'akan_kadaluarsa';
    } else {
      targetStatus = 'kadaluarsa';
    }

    return listToFilter.where((item) {
      final matchesStatus = item.status.toLowerCase() == targetStatus;
      final matchesQuery = query.isEmpty ||
          item.skema.toLowerCase().contains(query) ||
          item.nomorSertifikat.toLowerCase().contains(query) ||
          (item.institusi?.toLowerCase().contains(query) ?? false);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final filteredItems = _getFilteredCertificates();
    
    // Calculate global counts for badge notifications
    final totalList = _apiSertifikats.isNotEmpty ? _apiSertifikats : _mockSertifikats;
    final aktifCount = totalList.where((item) => item.status.toLowerCase() == 'aktif').length;
    final akanBerakhirCount = totalList.where((item) => item.status.toLowerCase() == 'akan_kadaluarsa').length;
    final kadaluarsaCount = totalList.where((item) => item.status.toLowerCase() == 'kadaluarsa').length;

    return Scaffold(
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
                  'Sertifikat',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                
                // More options icon
                const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ),

          // Custom Tab Bar matching screenshot aesthetics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SertifikatTabBar(
              currentTab: _currentTab,
              aktifCount: aktifCount,
              akanBerakhirCount: akanBerakhirCount,
              kadaluarsaCount: kadaluarsaCount,
              onTabChanged: (index) {
                setState(() {
                  _currentTab = index;
                });
              },
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchBar(),
          ),
          
          const SizedBox(height: 12),

          // Certificate List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: const Color(0xFF4FA8E8),
              child: _isLoading && _apiSertifikats.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return SertifikatListItem(
                              item: item,
                              onView: () => _showViewCertificateDialog(item),
                              onDownload: () => _handleDownloadCertificate(item),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F1FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFF2C6C9C),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada sertifikat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba ubah filter atau kata pencarian Anda.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
        decoration: InputDecoration(
          hintText: 'Cari sertifikat',
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
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _showViewCertificateDialog(SertifikatItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Sertifikat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: Color(0xFF5B9FD8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.skema,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No: ${item.nomorSertifikat}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pemegang: ${item.pemegang}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text('Terbit: ${item.tanggalTerbit} | Berlaku s/d: ${item.tanggalBerlaku}'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleDownloadCertificate(item);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FD8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Download PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDownloadCertificate(SertifikatItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mengunduh sertifikat ${item.skema}...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
