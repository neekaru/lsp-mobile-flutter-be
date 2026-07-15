import 'package:flutter/material.dart';
import '../../models/sertifikat_models.dart';
import '../../services/api_service.dart';
import '../../widgets/sertifikat/sertifikat_list_item.dart';
import '../../widgets/custom_app_bar.dart';
import 'detail_sertifikat_screen.dart';

class AsesiSertifikatScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const AsesiSertifikatScreen({super.key, this.onBackToHome});

  @override
  State<AsesiSertifikatScreen> createState() => _AsesiSertifikatScreenState();
}

class _AsesiSertifikatScreenState extends State<AsesiSertifikatScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<SertifikatItem> _allSertifikats = [];
  List<SertifikatItem> _displayedSertifikats = [];
  String? _errorMessage;

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
      nomorRegistrasi: 'REG-55431-2026',
      nomorBlanko: 'BLANKO-778811',
      nomorSeri: 'SERI-001A',
      tempatUji: 'TUK LSP Digital',
      namaAsesor: 'Dr. Ir. Ahmad Yani, M.Kom',
    ),
    const SertifikatItem(
      id: 4,
      skema: 'Desainer Grafis Muda',
      pemegang: 'Muhammad Hanafi',
      nomorSertifikat: 'FR-APR-05',
      tanggalTerbit: '15 Mei 2025',
      tanggalBerlaku: '15 Juni 2026',
      status: 'akan_kadaluarsa',
      kategori: 'Desain',
      institusi: 'LSP Desain Kreatif',
      nomorRegistrasi: 'REG-77665-2025',
      nomorBlanko: 'BLANKO-889900',
      nomorSeri: 'SERI-004D',
      tempatUji: 'TUK Desain Indah',
      namaAsesor: 'Santi Wijaya, M.Sn.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await ApiService.searchSertifikat(query: '');
      
      // Filter only certificates belonging to Muhammad Hanafi
      final filteredResults = results.where((item) => item.pemegang.toLowerCase().contains('hanafi')).toList();
      
      setState(() {
        _allSertifikats = filteredResults.isNotEmpty ? filteredResults : _mockSertifikats;
        _displayedSertifikats = List.from(_allSertifikats);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading initial certificates: $e');
      setState(() {
        _allSertifikats = _mockSertifikats;
        _displayedSertifikats = List.from(_allSertifikats);
        _isLoading = false;
      });
    }
  }

  void _handleSearchInstant(String val) {
    final query = val.trim().toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _displayedSertifikats = List.from(_allSertifikats);
        _errorMessage = null;
      });
      return;
    }

    final results = _allSertifikats.where((item) {
      return item.skema.toLowerCase().contains(query) ||
          item.nomorRegistrasi.toLowerCase().contains(query) ||
          item.nomorSertifikat.toLowerCase().contains(query) ||
          item.nomorBlanko.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _displayedSertifikats = results;
      if (results.isEmpty) {
        _errorMessage = 'Sertifikat tidak ditemukan.';
      } else {
        _errorMessage = null;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          CustomAppBar(
            title: 'Sertifikat Saya',
            onBack: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),

          _buildSearchBar(),

          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: _buildLoadingWidget(),
                    ),

                  if (!_isLoading && _errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: _buildErrorWidget(),
                    ),

                  if (!_isLoading && _errorMessage == null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 12.0),
                      child: Text(
                        'Sertifikat Terdaftar (${_displayedSertifikats.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _displayedSertifikats.length,
                      itemBuilder: (context, index) {
                        final item = _displayedSertifikats[index];
                        return SertifikatListItem(
                          item: item,
                          onView: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailSertifikatScreen(
                                  item: item,
                                  isAsesiView: true,
                                ),
                              ),
                            );
                          },
                          onDownload: () => _handleDownloadCertificate(item),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearchInstant,
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan skema atau nomor registrasi...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
              onPressed: () {
                _searchController.clear();
                _handleSearchInstant('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF3B82F6)),
          SizedBox(height: 12),
          Text(
            'Mencari data sertifikat...',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5).withAlpha(127)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
