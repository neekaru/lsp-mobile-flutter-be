import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/auth/token_storage.dart';

class LupaPasswordScreen extends StatefulWidget {
  const LupaPasswordScreen({super.key});

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  final TextEditingController _identityController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;
  Map<String, dynamic>? _verifiedData;

  @override
  void dispose() {
    _identityController.dispose();
    super.dispose();
  }

  Future<void> _handleResetAndOpenWhatsApp() async {
    final identity = _identityController.text.trim();
    if (identity.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan Email, No. Registrasi Asesor (MET), NIK, atau Username';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = AuthRepository(
        dio: ApiService.dio,
        tokenStorage: TokenStorage.instance,
      );

      final result = await authRepo.forgotPassword(identity: identity);
      final data = result['data'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _verifiedData = data;
      });

      // Launch WhatsApp with prefilled template
      await _openWhatsAppWithData(data, identity);
    } catch (e) {
      debugPrint('Forgot password verification failed: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (e is DioException) {
          final serverMessage = e.response?.data is Map
              ? (e.response?.data['message']?.toString() ??
                  e.response?.data['errors']?.toString())
              : null;

          if (serverMessage != null && serverMessage.isNotEmpty) {
            _errorMessage = serverMessage;
          } else if (e.response?.statusCode == 404) {
            _errorMessage =
                'Akun dengan identitas "$identity" tidak ditemukan di sistem LSP.';
          } else if (e.response?.statusCode == 403) {
            _errorMessage =
                'Akun Anda saat ini tidak aktif. Silakan hubungi admin LSP.';
          } else {
            _errorMessage = 'Gagal memverifikasi akun. Periksa koneksi internet Anda.';
          }
        } else {
          _errorMessage = 'Terjadi kesalahan sistem. Coba lagi nanti.';
        }
      });
    }
  }

  Future<void> _openWhatsAppWithData(Map<String, dynamic>? data, String identity) async {
    final name = data?['name']?.toString() ?? '';
    final account = data?['account']?.toString() ?? identity;
    final role = data?['role']?.toString() ?? 'Pengguna';
    final adminWA = data?['whatsapp_admin']?.toString() ?? '6285329489247';

    final roleCapital = role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : 'Pengguna';

    final StringBuffer sb = StringBuffer();
    sb.writeln('Halo Admin Helpdesk LSP Teknologi Digital,');
    sb.writeln('Saya ingin meminta bantuan verifikasi & reset password akun LSP saya:');
    if (name.isNotEmpty) sb.writeln('• Nama: $name');
    sb.writeln('• Identitas / Akun: $account');
    sb.writeln('• Role: $roleCapital');
    sb.writeln('\nMohon bantuannya untuk verifikasi akun. Terima kasih.');

    final uri = Uri.parse(
      'https://wa.me/$adminWA?text=${Uri.encodeComponent(sb.toString())}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka WhatsApp. Hubungi nomor +$adminWA.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lupa Password',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Illustration & Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF16A34A),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bantuan Reset Akun LSP',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Masukkan Email terdaftar, No. Registrasi Asesor (MET), NIK, atau Username akun Anda untuk verifikasi dan pengajuan reset password langsung ke Admin LSP.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              if (_isSuccess) ...[
                // Success State Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF16A34A),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Akun Terverifikasi!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data akun untuk identitas "${_identityController.text.trim()}" telah ditemukan. Permintaan bantuan telah diteruskan ke WhatsApp Admin Helpdesk LSP.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF166534),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => _openWhatsAppWithData(_verifiedData, _identityController.text.trim()),
                          icon: const Icon(Icons.chat_rounded, size: 18, color: Colors.white),
                          label: const Text(
                            'Buka WhatsApp Admin Lagi',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 0,
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
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Halaman Masuk',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ),
                ),
              ] else ...[
                // Error Banner
                if (_errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF5350), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Input Field
                const Text(
                  'Email / No. Registrasi Asesor / NIK / Username',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _identityController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: asesor@lsp.id atau MET.000.000000',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
                ),

                const SizedBox(height: 20),

                // Submit WhatsApp Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleResetAndOpenWhatsApp,
                    icon: _isLoading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.chat_rounded, size: 18, color: Colors.white),
                    label: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Hubungi Admin via WhatsApp',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 24),

              // Bantuan Admin LSP Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF0284C7), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Prosedur Keamanan Akun LSP',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Untuk melindungi data sertifikasi dan keamanan akun Anda, reset password dilakukan melalui verifikasi resmi Helpdesk Admin LSP. Password akan dipulihkan ke sandi standar setelah konfirmasi identitas.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
