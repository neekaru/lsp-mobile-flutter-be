import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'pilih_peran_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void _handleRegister() {
    final name = _fullNameController.text.trim();
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Nama lengkap wajib diisi.';
      });
      return;
    }
    if (emailOrPhone.isEmpty) {
      setState(() {
        _errorMessage = 'Email atau No. Handphone wajib diisi.';
      });
      return;
    }
    
    // Simple validation for email or phone
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailOrPhone);
    final isPhone = RegExp(r'^[0-9+]{8,15}$').hasMatch(emailOrPhone);
    if (!isEmail && !isPhone) {
      setState(() {
        _errorMessage = 'Masukkan email atau nomor handphone yang valid.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Kata sandi wajib diisi.';
      });
      return;
    }
    if (password.length < 8) {
      setState(() {
        _errorMessage = 'Kata sandi minimal 8 digit.';
      });
      return;
    }
    if (confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Konfirmasi kata sandi wajib diisi.';
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Konfirmasi kata sandi tidak cocok.';
      });
      return;
    }
    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Anda harus menyetujui Syarat & Ketentuan dan Kebijakan Privasi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate registration loader
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    // Dismiss keyboard before showing dialog to prevent flickering
    FocusScope.of(context).unfocus();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: [
                // Top-Left Back Arrow Icon
                Positioned(
                  top: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF0F4C81),
                      size: 24,
                    ),
                  ),
                ),
                
                // Content Column
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bubble checkmark badge
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(top: 25, left: 18, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFB3E5FC), shape: BoxShape.circle))),
                            Positioned(top: 45, left: 10, child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFB3E5FC), shape: BoxShape.circle))),
                            Positioned(top: 80, left: 5, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFB3E5FC), shape: BoxShape.circle))),
                            Positioned(bottom: 25, left: 22, child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFB3E5FC), shape: BoxShape.circle))),
                            
                            Positioned(top: 15, right: 28, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFB3E5FC), shape: BoxShape.circle))),
                            Positioned(top: 55, right: 12, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFB3E5FC), shape: BoxShape.circle))),
                            Positioned(top: 70, right: 2, child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFB3E5FC), shape: BoxShape.circle))),
                            Positioned(bottom: 22, right: 24, child: Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFB3E5FC), shape: BoxShape.circle))),

                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2D9CDB),
                                  size: 56,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Title
                      const Text(
                        'Pendaftaran Berhasil',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        'Akun Anda telah berhasil dan sudah siap digunakan',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Welcome text
                      const Text(
                        'Selamat datang di',
                        style: TextStyle(
                          color: Color(0xFF0F4C81),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'LSP Teknologi Digital.',
                        style: TextStyle(
                          color: Color(0xFF0F4C81),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Ensure keyboard is dismissed before navigation
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop(); // Dismiss success dialog
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const PilihPeranScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF378CE7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Masuk ke Akun',
                            style: TextStyle(
                              fontSize: 15,
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
        );
      },
    );
  }

  void _showTermsSheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F4C81),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button Row
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF0F4C81), // Dark blue back arrow matching mock
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title and Subtitle
              const Text(
                'Daftar Akun',
                style: TextStyle(
                  color: Color(0xFF0F4C81), // Dark primary blue
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Buat akun baru untuk memulai monitoring',
                style: TextStyle(
                  color: Color(0xFF0F4C81), // matching layout subtitle style
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              // Error Message Section
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF5350),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFD32F2F),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFC62828),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Field 1: Nama Lengkap Label
              const Text(
                'Nama Lengkap',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Field 1: Nama Lengkap Input Box
              TextField(
                controller: _fullNameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'Masukan nama lengkap',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14.5,
                ),
              ),

              const SizedBox(height: 20),

              // Field 2: Email atau No.Handphone Label
              const Text(
                'Email atau No.Handphone',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Field 2: Email atau No.Handphone Input Box
              TextField(
                controller: _emailOrPhoneController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukan email atau nomor',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14.5,
                ),
              ),

              const SizedBox(height: 20),

              // Field 3: Kata Sandi Label
              const Text(
                'Kata Sandi',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Field 3: Kata Sandi Input Box
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Minimal 8 digit',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF0F4C81),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14.5,
                ),
              ),

              const SizedBox(height: 20),

              // Field 4: Konfirmasi Kata Sandi Label
              const Text(
                'Konfirmasi Kata Sandi',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Field 4: Konfirmasi Kata Sandi Input Box
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Ulangi kata sandi',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF0F4C81),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14.5,
                ),
              ),

              const SizedBox(height: 18),

              // Checkbox and Terms
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? val) {
                        setState(() {
                          _agreeToTerms = val ?? false;
                        });
                      },
                      activeColor: const Color(0xFF0F4C81),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Saya menyetujui '),
                          TextSpan(
                            text: 'Syarat & Ketentuan',
                            style: const TextStyle(
                              color: Color(0xFF0F4C81),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _showTermsSheet(
                                  'Syarat & Ketentuan',
                                  'Selamat datang di LSP Teknologi Digital.\n\nDengan mendaftar dan menggunakan aplikasi monitoring sertifikat nasional ini, Anda setuju untuk terikat oleh ketentuan penggunaan berikut:\n\n1. Pendaftaran Akun\nAnda diwajibkan memberikan data yang akurat, lengkap, dan terbaru. Penyalahgunaan akun milik orang lain dilarang keras.\n\n2. Keamanan Akun\nAnda bertanggung jawab menjaga kerahasiaan kata sandi Anda dan aktivitas apa pun yang terjadi menggunakan akun Anda.\n\n3. Penggunaan Aplikasi\nAplikasi ini ditujukan untuk memantau status kompetensi dan sertifikasi Anda. Anda dilarang melakukan modifikasi, manipulasi data, atau tindakan peretasan.\n\n4. Hak Cipta\nSeluruh konten, logo, merek, dan teknologi yang terdapat dalam aplikasi ini adalah hak kekayaan intelektual LSP Teknologi Digital.\n\nKami berhak menangguhkan akun Anda apabila ditemukan pelanggaran terhadap syarat dan ketentuan ini.',
                                );
                              },
                          ),
                          const TextSpan(text: ' dan '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: const TextStyle(
                              color: Color(0xFF0F4C81),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _showTermsSheet(
                                  'Kebijakan Privasi',
                                  'LSP Teknologi Digital berkomitmen melindungi privasi data pribadi Anda.\n\nKebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda:\n\n1. Informasi yang Kami Kumpulkan\nKami mengumpulkan nama lengkap, alamat email, nomor telepon, dan data sertifikasi yang diperlukan untuk proses monitoring.\n\n2. Penggunaan Informasi\nData yang Anda berikan digunakan semata-mata untuk mengelola akun Anda, mengirimkan notifikasi status kelulusan, penugasan asesor, dan penerbitan sertifikat.\n\n3. Perlindungan Informasi\nKami menerapkan langkah-langkah keamanan teknologi enkripsi dan pembatasan akses untuk mencegah kebocoran data.\n\n4. Pembagian Data Pihak Ketiga\nKami tidak pernah menjual atau membagikan data pribadi Anda kepada pihak ketiga tanpa persetujuan Anda, kecuali diwajibkan oleh hukum atau otoritas sertifikasi nasional (BNSP).\n\nDengan menggunakan aplikasi ini, Anda menyatakan setuju atas pengelolaan data pribadi Anda sesuai dengan Kebijakan Privasi ini.',
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF378CE7), // Matches login action button
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Daftar Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 36),

              // Footer: Sudah punya akun? Masuk Akun
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Masuk Akun',
                      style: TextStyle(
                        color: Color(0xFF0F4C81),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
