import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/api_service.dart';
import '../../services/auth/token_storage.dart';
import '../../services/common/notification_service.dart';
import '../auth/login_screen.dart';
import 'keamanan_screen.dart';
import 'tentang_lsp_screen.dart';
import 'struktur_organisasi_screen.dart';
import 'tugas_tanggung_jawab_screen.dart';

class ProfileAdminScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ProfileAdminScreen({super.key, this.onBackToHome});

  @override
  State<ProfileAdminScreen> createState() => _ProfileAdminScreenState();
}

class _ProfileAdminScreenState extends State<ProfileAdminScreen> {
  bool _isLoggingOut = false;
  bool _isUploadingPhoto = false;
  int _carouselIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title1': 'Visi LSP Teknologi Digital',
      'desc1': 'Menjadi lembaga sertifikasi kompetensi terkemuka dan terpercaya.',
      'title2': 'Misi LSP Teknologi Digital',
      'desc2': '1. Menyelenggarakan uji kompetensi secara terbuka dan profesional.\n2. Meningkatkan SDM di Indonesia.',
      'imageUrl': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title1': 'Motto LSP Teknologi Digital',
      'desc1': 'Profesional, Akurat, Terpercaya dan Berintegritas Tinggi.',
      'title2': 'Sasaran Mutu',
      'desc2': '1. Menghasilkan tenaga kerja yang kompeten.\n2. Menjaga kualitas pelaksanaan sertifikasi profesi.',
      'imageUrl': 'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title1': 'Kebijakan Mutu LSP',
      'desc1': 'Mengutamakan kepuasan pelanggan dengan pelayanan yang cepat.',
      'title2': 'Komitmen LSP',
      'desc2': '1. Mengembangkan standar kompetensi kerja terkini.\n2. Mendorong pengakuan kompetensi nasional.',
      'imageUrl': 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?q=80&w=400&auto=format&fit=crop',
    },
  ];

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authRepo = AuthRepository(
        dio: ApiService.dio,
        tokenStorage: TokenStorage.instance,
      );

      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getToken();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Error fetching FCM token for logout: $e');
        }
      }

      await authRepo.logout(deviceToken: fcmToken);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error during logout: $e');
      }
      try {
        await TokenStorage.instance.clear();
        AuthRepository.currentUserInstance = null;
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0.0, 0.08),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              );
              final fadeAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              );
              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(opacity: fadeAnimation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
          (route) => false,
        );
      }
    }
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Konfirmasi Keluar',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apakah Anda yakin ingin keluar dari akun ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: const Color(0xFF64748B),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleLogout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Keluar',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
      },
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath == null) return;
        setState(() => _isUploadingPhoto = true);
        final uploaded = await ApiService.uploadProfilePhoto(filePath);
        if (!mounted) return;
        if (uploaded != null && uploaded['foto_profil_url'] != null) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Foto profil berhasil diperbarui!'),
                ],
              ),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengunggah foto profil'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking profile photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showPhotoPickerDemo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF378CE7),
                    ),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF378CE7),
                    ),
                  ),
                  title: const Text('Ambil Foto / Pilih Berkas'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCertificateIllustration() {
    return Container(
      width: 76,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5), // Dark blue certificate background
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The paper/inner part
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD), // Light blue paper color
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder line 1
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF90CAF9),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(height: 4),
                // Placeholder line 2
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF90CAF9),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
          // Red Ribbon 1
          Positioned(
            bottom: -4,
            right: 18,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 5,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
                ),
              ),
            ),
          ),
          // Red Ribbon 2
          Positioned(
            bottom: -4,
            right: 12,
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                width: 5,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
                ),
              ),
            ),
          ),
          // Gold Seal
          Positioned(
            bottom: 0,
            right: 11,
            child: Container(
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107), // Gold/Amber
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F1FC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final user = AuthRepository.currentUserInstance;

    final String adminName = user?.name ?? 'LSP Teeknologi Digital';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FA8E8), Color(0xFF5B9FD8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(
                top: statusBarHeight + 12,
                bottom: 40,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  // App Bar Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profil Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                            ),
                            onPressed: _isLoggingOut ? null : _showLogoutConfirmDialog,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const KeamananScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar & Admin info Row
                  Row(
                    children: [
                      Builder(
                        builder: (context) {
                          final user = AuthRepository.currentUserInstance;
                          final rawPhoto = user?.fotoProfilUrl;
                          String? photoUrl;
                          if (rawPhoto != null && rawPhoto.isNotEmpty) {
                            if (rawPhoto.startsWith('http://') || rawPhoto.startsWith('https://')) {
                              photoUrl = rawPhoto;
                            } else {
                              final normalized = rawPhoto.startsWith('/') ? rawPhoto : '/$rawPhoto';
                              photoUrl = '${ApiService.baseUrl}$normalized';
                            }
                          }
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: _showPhotoPickerDemo,
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _isUploadingPhoto
                                        ? const Center(
                                            child: SizedBox(
                                              width: 28,
                                              height: 28,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9FD8)),
                                              ),
                                            ),
                                          )
                                        : (photoUrl != null && photoUrl.isNotEmpty)
                                            ? Image.network(
                                                photoUrl,
                                                width: 76,
                                                height: 76,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Center(
                                                  child: Icon(
                                                    Icons.person_rounded,
                                                    size: 48,
                                                    color: Color(0xFFCBD5E1),
                                                  ),
                                                ),
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.person_rounded,
                                                  size: 48,
                                                  color: Color(0xFFCBD5E1),
                                                ),
                                              ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showPhotoPickerDemo,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Color(0xFF4FA8E8),
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Administrator',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Carousel Section (Overlapping the Blue Header slightly)
            Transform.translate(
              offset: const Offset(0, -20),
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int index) {
                        setState(() {
                          _carouselIndex = index;
                        });
                      },
                      itemCount: _carouselItems.length,
                      itemBuilder: (context, index) {
                        final item = _carouselItems[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                // Left details
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item['title1']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['desc1']!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF475569),
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          height: 1,
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item['title2']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['desc2']!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF475569),
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Right image
                                Expanded(
                                  flex: 4,
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: Image.network(
                                      item['imageUrl']!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(
                                            Icons.business_rounded,
                                            color: Color(0xFF94A3B8),
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Carousel dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _carouselItems.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _carouselIndex == index
                              ? const Color(0xFF4FA8E8)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informasi Organisasi Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Organisasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOrgCard(
                          icon: Icons.hub_outlined,
                          title: 'Struktur Organisasi',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StrukturOrganisasiScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOrgCard(
                          icon: Icons.assignment_outlined,
                          title: 'Tugas & Tanggung Jawab',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TugasTanggungJawabScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tentang LSP Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang LSP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCertificateIllustration(),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Membangun SDM Digital Unggul',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'LSP Teknologi Digital menjamin kompetensi tentang IT melalui sertifikasi berstandar BNSP.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TentangLspScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFE5F1FC),
                              foregroundColor: const Color(0xFF3B82F6),
                              side: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

