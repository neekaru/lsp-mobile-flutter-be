import 'package:flutter/material.dart';
import '../../models/sertifikat_models.dart';
import '../../services/api_service.dart';
import '../../widgets/sertifikat/sertifikat_list_item.dart';
import '../../widgets/custom_app_bar.dart';
import 'detail_sertifikat_screen.dart';

class SertifikatScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const SertifikatScreen({super.key, this.onBackToHome});

  @override
  State<SertifikatScreen> createState() => _SertifikatScreenState();
}

class _SertifikatScreenState extends State<SertifikatScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasSearched = false;
  List<SertifikatItem> _searchResults = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Kata kunci pencarian tidak boleh kosong.';
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final results = await ApiService.searchSertifikat(query: query);
      setState(() {
        _isLoading = false;
        _searchResults = results;
        if (results.isEmpty) {
          _errorMessage = 'Sertifikat tidak ditemukan dalam sistem. Pastikan keyword yang diinputkan benar.';
        }
      });
    } catch (e) {
      debugPrint('Error searching certificates: $e');
      setState(() {
        _isLoading = false;
        _searchResults = [];
        _errorMessage = 'Terjadi kesalahan saat mencari sertifikat.';
      });
    }
  }

  void _handleReset() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
      _hasSearched = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          // Header with consistent style
          CustomAppBar(
            title: 'Sertifikat (Admin)',
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
                  // 1. Validation Style Input Card (Mirroring Public ValidasiSertifikatScreen)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildSearchInputCard(),
                  ),

                  const SizedBox(height: 20),

                  // 2. Loading State
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildLoadingWidget(),
                    ),

                  // 3. Search Results List
                  if (!_isLoading && _hasSearched && _searchResults.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 12.0),
                      child: Text(
                        'Hasil Pencarian (${_searchResults.length} ditemukan)',
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
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return SertifikatListItem(
                          item: item,
                          onView: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailSertifikatScreen(item: item),
                              ),
                            );
                          },
                          onDownload: () => _handleDownloadCertificate(item),
                        );
                      },
                    ),
                  ],

                  // 4. Error / Not Found State (Mirroring Public ValidasiSertifikatScreen error card style)
                  if (!_isLoading && _hasSearched && _errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildErrorWidget(),
                    ),

                  // 5. Welcome/Initial Guidelines when not searched yet
                  if (!_isLoading && !_hasSearched)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildInitialGuidelines(),
                    ),

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Certificate Shield Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFDBEAFE),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF2C6C9C),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pencarian Sertifikat (Admin)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Masukkan data sertifikat pemegang untuk konfirmasi keabsahan dokumen dalam database.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Input TextField
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _handleSearch(),
                decoration: InputDecoration(
                  hintText: 'Nama / No. Regis / No. Sertifikat / No. Blanko',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          ),
                          onPressed: _handleReset,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (text) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 16),

            // Search/Cari Button
            Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C6C9C), Color(0xFF4FA8E8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x222C6C9C),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cari Sertifikat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Color(0xFF2C6C9C)),
            SizedBox(height: 16),
            Text(
              'Menghubungi database LSP...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE11D48),
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Sertifikat Tidak Ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9F1239),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'Data tidak ditemukan dalam sistem.',
            style: const TextStyle(fontSize: 13, color: Color(0xFFBE123C)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialGuidelines() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mulai Pencarian Sertifikat',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gunakan kolom pencarian di atas untuk memvalidasi nomor seri, nomor sertifikat, nomor registrasi, atau nama pemegang.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
