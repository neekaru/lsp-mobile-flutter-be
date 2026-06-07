import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/auth_repository.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ProfileScreen({super.key, this.onBackToHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _fcmToken;
  bool _isCopied = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await NotificationService.instance.getToken();
    if (mounted) {
      setState(() {
        _fcmToken = token;
      });
    }
  }

  void _copyToClipboard() {
    if (_fcmToken == null) return;
    Clipboard.setData(ClipboardData(text: _fcmToken!));
    setState(() {
      _isCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('FCM Token disalin ke clipboard!'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _simulateNotification(String type) {
    String title = '';
    String body = '';
    Map<String, String> data = {};

    switch (type) {
      case 'status_kompeten':
        title = 'Status Kelulusan Diperbarui';
        body = 'Selamat! Anda dinyatakan KOMPETEN pada skema Sertifikasi Pemrogram Mobile.';
        data = {
          'type': 'status_kompeten',
          'skema': 'Sertifikasi Pemrogram Mobile',
          'tuk': 'TUK Campus Digital Jakarta',
          'asesor': 'Drs. H. Mulyono, M.T.',
        };
        break;
      case 'rekomendasi_asesor':
        title = 'Rekomendasi Asesor Baru';
        body = 'Asesor Drs. H. Mulyono telah memberikan rekomendasi asesmen untuk jadwal Anda.';
        data = {
          'type': 'rekomendasi_asesor',
          'skema': 'Sertifikasi Pemrogram Mobile',
          'tuk': 'TUK Campus Digital Jakarta',
          'asesor': 'Drs. H. Mulyono, M.T.',
        };
        break;
      case 'sertifikat_terbit':
        title = 'Sertifikat Kompetensi Terbit';
        body = 'Sertifikat Anda untuk skema Sertifikasi Pemrogram Mobile telah terbit.';
        data = {
          'type': 'sertifikat_terbit',
          'skema': 'Sertifikasi Pemrogram Mobile',
          'tuk': 'TUK Campus Digital Jakarta',
          'asesor': 'Drs. H. Mulyono, M.T.',
        };
        break;
    }

    final message = RemoteMessage(
      data: data,
      notification: RemoteNotification(
        title: title,
        body: body,
      ),
    );

    NotificationService.instance.simulateIncomingNotification(message);
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authRepo = AuthRepository(
        dio: ApiService.dio,
        tokenStorage: TokenStorage.instance,
      );
      
      // Fetch FCM token to pass to logout
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
      // Guarantee local token storage cleanup in case authRepo.logout failed
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
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final user = AuthRepository.currentUserInstance;
    final userRole = user?.role ?? 'Guest';
    final userName = user?.name ?? 'Pengguna Demo';
    final userEmail = user?.email ?? 'user@lspdigital.id';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: statusBarHeight + 8),
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onBackToHome ?? () => Navigator.pop(context),
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
                  const Text(
                    'Profil Pengguna',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.black,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Card (Header Info)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF4FA8E8).withValues(alpha: 0.1),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C81),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: userRole == 'asesi'
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFE1F5FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            userRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: userRole == 'asesi'
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF0288D1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FCM Token Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.vpn_key_outlined, color: Color(0xFF4FA8E8), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Firebase FCM Device Token',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      _fcmToken ?? 'Memuat FCM Token...',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF475569),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _fcmToken != null ? _copyToClipboard : null,
                      icon: Icon(
                        _isCopied ? Icons.check : Icons.copy_rounded,
                        size: 16,
                      ),
                      label: Text(_isCopied ? 'Tersalin!' : 'Salin Token FCM'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F4C81),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notification Simulator Deck (Demo)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dashboard_customize_outlined, color: Color(0xFF4FA8E8), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Demo & Simulasi Push Notifikasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Simulasikan push notifikasi untuk mengetes tampilan in-app SnackBar dan sistem navigasi otomatis saat notifikasi ditekan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Simulator Button 1: status_kompeten
                  _buildSimulateTile(
                    title: 'Notifikasi Kelulusan (Kompeten)',
                    subtitle: 'Simulasikan asesi lulus uji kompetensi skema',
                    color: const Color(0xFF2E7D32),
                    icon: Icons.verified_user_rounded,
                    onTap: () => _simulateNotification('status_kompeten'),
                  ),
                  const SizedBox(height: 10),
                  
                  // Simulator Button 2: rekomendasi_asesor
                  _buildSimulateTile(
                    title: 'Notifikasi Rekomendasi Asesor',
                    subtitle: 'Simulasikan asesor mengirim rekomendasi',
                    color: const Color(0xFFFF9800),
                    icon: Icons.rate_review_rounded,
                    onTap: () => _simulateNotification('rekomendasi_asesor'),
                  ),
                  const SizedBox(height: 10),
                  
                  // Simulator Button 3: sertifikat_terbit
                  _buildSimulateTile(
                    title: 'Notifikasi Sertifikat Terbit',
                    subtitle: 'Simulasikan sertifikat siap diunduh',
                    color: const Color(0xFFE0A96D),
                    icon: Icons.workspace_premium_rounded,
                    onTap: () => _simulateNotification('sertifikat_terbit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoggingOut ? null : _handleLogout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Keluar dari Akun',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulateTile({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFF4FA8E8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
