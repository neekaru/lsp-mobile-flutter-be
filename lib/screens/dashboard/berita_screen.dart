import 'package:flutter/material.dart';
import '../../models/berita_model.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'berita_detail_screen.dart';

class BeritaScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const BeritaScreen({super.key, this.onBackToHome});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  final ScrollController _scrollController = ScrollController();
  List<BeritaItem> _beritaList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadBerita(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBerita();
    }
  }

  Future<void> _loadBerita({bool isRefresh = false}) async {
    if (isRefresh) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _currentPage = 1;
          _hasMore = true;
          _beritaList = [];
        });
      }
    }

    try {
      final results = await ApiService.getBerita(
        page: _currentPage,
        size: _pageSize,
      );

      if (mounted) {
        setState(() {
          _beritaList.addAll(results);
          _isLoading = false;
          _hasMore = results.length >= _pageSize;
        });
      }
    } catch (e) {
      debugPrint('Error loading berita: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreBerita() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final results = await ApiService.getBerita(
        page: _currentPage,
        size: _pageSize,
      );

      if (mounted) {
        setState(() {
          _beritaList.addAll(results);
          _isLoadingMore = false;
          _hasMore = results.length >= _pageSize;
        });
      }
    } catch (e) {
      debugPrint('Error loading more berita: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      // Input format: YYYY-MM-DD HH:mm:ss
      final parts = rawDate.split(' ');
      final datePart = parts[0];
      final dateParts = datePart.split('-');
      if (dateParts.length == 3) {
        final year = dateParts[0];
        final monthNum = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);

        const months = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];

        return '$day ${months[monthNum - 1]} $year';
      }
      return rawDate;
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _loadBerita(isRefresh: true),
                      child: _beritaList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _beritaList.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _beritaList.length) {
                                  if (_isLoadingMore) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else if (!_hasMore) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: Text(
                                          'Semua berita telah dimuat',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox(height: 80);
                                  }
                                }

                                final item = _beritaList[index];
                                return _buildBeritaCard(item);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      title: 'Berita LSP',
      onBack: () {
        if (widget.onBackToHome != null) {
          widget.onBackToHome!();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.newspaper_rounded,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Belum ada berita terbaru',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBeritaCard(BeritaItem item) {
    // Construct dynamic image URL if present
    final String? imageUrl = item.foto != null && item.foto!.isNotEmpty
        ? 'https://mobile.lspdigital.id/upload/foto_berita/${item.foto}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BeritaDetailScreen(beritaId: item.id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori & Tanggal Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.kategori,
                            style: const TextStyle(
                              color: Color(0xFF1E88E5),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(item.tanggalBuat),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Judul Berita (Di atas gambar sesuai request)
                    Text(
                      item.judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Headline singkat
                    Text(
                      item.headline,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Gambar di bawah judul & info, dengan full-width card bottom border radius
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(item.judul),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: const Color(0xFFECEFF1),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        )
                      : _buildImagePlaceholder(item.judul),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A9EDF), Color(0xFF1976D2)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.newspaper_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.newspaper_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
