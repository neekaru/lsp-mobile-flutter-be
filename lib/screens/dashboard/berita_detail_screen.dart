import 'package:material_ui/material_ui.dart';
import '../../models/berita_models.dart';
import '../../services/dashboard/berita_service.dart';
import '../../services/api_client.dart';
import '../../services/auth/auth_repository.dart';
import '../../widgets/berita/admin_berita_dialog.dart';
import '../../widgets/common/custom_app_bar.dart';

class BeritaDetailScreen extends StatefulWidget {
  final int beritaId;

  const BeritaDetailScreen({super.key, required this.beritaId});

  @override
  State<BeritaDetailScreen> createState() => _BeritaDetailScreenState();
}

class _BeritaDetailScreenState extends State<BeritaDetailScreen> {
  bool _isLoading = true;
  BeritaDetail? _detail;

  bool get _isAdmin {
    final role = AuthRepository.currentUserInstance?.role.toLowerCase();
    if (role == 'admin' || role == 'pengelola') return true;
    if (role != null && role != 'asesi' && role != 'asesor' && role.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BeritaService.getBeritaDetail(widget.beritaId);
      if (mounted) {
        setState(() {
          _detail = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading berita detail: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
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

  /// Clean basic HTML tags from API content
  String _parseHtmlContent(String htmlString) {
    if (htmlString.isEmpty) return 'Tidak ada deskripsi.';
    
    String text = htmlString;
    // Replace breaks with newlines
    text = text.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    // Replace paragraph tag closures with double newlines
    text = text.replaceAll(RegExp(r'</p>'), '\n\n');
    text = text.replaceAll(RegExp(r'</div>'), '\n');
    text = text.replaceAll(RegExp(r'</li>'), '\n');
    // Strip all other HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Clean up HTML entities
    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#39;', "'");
    
    // Trim extra spaces/newlines
    text = text.trim();
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = _detail?.foto != null && _detail!.foto!.isNotEmpty
        ? '${ApiClient.baseUrl}/upload/foto_berita/${_detail!.foto}'
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _detail == null
                      ? _buildErrorState()
                      : RefreshIndicator(
                          onRefresh: _loadDetail,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kategori badge & tanggal
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _detail!.kategori,
                                        style: const TextStyle(
                                          color: Color(0xFF1E88E5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _formatDate(_detail!.tanggalBuat),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Judul utama
                                Text(
                                  _detail!.judul,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Foto berita (Full width)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 10,
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                _buildImagePlaceholder(_detail!.judul),
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
                                        : _buildImagePlaceholder(_detail!.judul),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Isi berita
                                Text(
                                  _parseHtmlContent(_detail!.isi),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF334155),
                                    height: 1.6,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
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
      title: 'Detail Berita',
      rightWidget: (_detail == null || !_isAdmin)
          ? null
          : PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: Colors.black, size: 22),
              onSelected: (val) {
                if (val == 'edit' && _detail != null) {
                  showAdminBeritaFormDialog(
                    context: context,
                    beritaId: _detail!.id,
                    initialJudul: _detail!.judul,
                    initialHeadline: _detail!.headline,
                    initialIsi: _detail!.isi,
                    initialKategori: _detail!.idKategori ??
                        kategoriNameToId(_detail!.kategori),
                    initialFoto: _detail!.foto,
                    initialShowImage: _detail!.showImage,
                    onSuccess: () => _loadDetail(),
                  );
                } else if (val == 'delete' && _detail != null) {
                  confirmDeleteAdminBerita(
                    context: context,
                    beritaId: _detail!.id,
                    beritaTitle: _detail!.judul,
                    onSuccess: () => Navigator.pop(context, true),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 16, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text('Edit Berita', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 16, color: Color(0xFFDC2626)),
                      SizedBox(width: 8),
                      Text('Hapus Berita',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFDC2626))),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat detail berita.',
            style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A9EDF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          )
        ],
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
              size: 150,
              color: Colors.white.withValues(alpha: 0.12),
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
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
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
