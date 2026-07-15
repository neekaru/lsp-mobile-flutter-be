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

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim().toLowerCase();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) {
      setState(() {
        _displayedSertifikats = List.from(_allSertifikats);
        _isLoading = false;
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
      _isLoading = false;
      _displayedSertifikats = results;
      if (results.isEmpty) {
        _errorMessage = 'Sertifikat tidak ditemukan. Coba gunakan nomor registrasi atau kata kunci skema yang lain.';
      }
    });
  }

  void _handleReset() {
    setState(() {
      _searchController.clear();
      _displayedSertifikats = List.from(_allSertifikats);
      _errorMessage = null;
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

          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildSearchInputCard(),
                  ),

                  const SizedBox(height: 20),

                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildLoadingWidget(),
                    ),

                  if (!_isLoading && _errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildErrorWidget(),
                    ),

                  if (!_isLoading && _errorMessage == null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 12.0),
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

  Widget _buildSearchInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Validasi & Pencarian Sertifikat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Masukkan kata kunci skema, nomor registrasi, nomor blanko, atau nomor sertifikat Anda untuk melakukan pencarian.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _handleSearch(),
                      decoration: const InputDecoration(
                        hintText: 'Cari sertifikat...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: _handleReset,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: _handleReset,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: const Color(0xFF475569),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _handleSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cari',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
