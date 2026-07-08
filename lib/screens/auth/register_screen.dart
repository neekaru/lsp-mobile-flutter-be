import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'pilih_peran_screen.dart';
import '../profile/syarat_ketentuan_screen.dart';
import '../profile/ketentuan_privasi_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
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
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Nama lengkap wajib diisi.';
      });
      return;
    }
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Email wajib diisi.';
      });
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Masukkan email yang valid.';
      });
      return;
    }
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Nomor hp wajib diisi.';
      });
      return;
    }
    if (!RegExp(r'^[0-9+]{8,15}$').hasMatch(phone)) {
      setState(() {
        _errorMessage = 'Masukkan nomor hp yang valid.';
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
        _errorMessage = 'Kata sandi minimal 8 karakter.';
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header: Title + Subtitle and Illustration next to it
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Daftar Akun Anda',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Daftar untuk membuat akun di LSP Teknologi Digital',
                          style: const TextStyle(
                            color: Color(0xCC000000),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/login.png',
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Register Form Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error Message inside the Card
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
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
                              size: 18,
                            ),
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

                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        hintText: 'Masukan nama lengkap anda',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF378CE7), width: 1.5),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Masukan email aktif',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF378CE7), width: 1.5),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Nomor Hp',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Masukan nomor hp aktif',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF378CE7), width: 1.5),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Kata Sandi',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Masukan kata sandi',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF378CE7), width: 1.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey.shade500,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Minimal 8 karakter kombinasi huruf dan angka',
                      style: TextStyle(
                        color: Color(0xFF1E88E5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Konfirmasi Kata Sandi',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Konfirmasi kata sandi',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF378CE7), width: 1.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey.shade500,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Checkbox and Terms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (bool? val) {
                              setState(() {
                                _agreeToTerms = val ?? false;
                              });
                            },
                            activeColor: const Color(0xFF54A0E6),
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'Saya setuju dengan '),
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: const TextStyle(
                                    color: Color(0xFF1E88E5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SyaratKetentuanScreen(),
                                        ),
                                      );
                                    },
                                ),
                                const TextSpan(text: ' dan '),
                                TextSpan(
                                  text: 'Kebijakan Privasi',
                                  style: const TextStyle(
                                    color: Color(0xFF1E88E5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const KetentuanPrivasiScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF54A0E6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

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
                              color: Color(0xFF1E88E5),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
