import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../main.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';
import '../../services/auth_repository.dart';
import '../../services/notification_service.dart';
import '../../models/auth_models.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    final emailVal = _emailController.text.trim();
    final passwordVal = _passwordController.text;

    if (emailVal.isEmpty || passwordVal.isEmpty) {
      setState(() {
        _errorMessage = 'Akun dan kata sandi wajib diisi.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Jalur alternatif (Bypass) untuk testing / demo
    if ((emailVal == 'user' && passwordVal == 'password123') ||
        (emailVal == 'asesi' && passwordVal == 'deng123') ||
        (emailVal == 'asesor' && passwordVal == 'deng123')) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      final isAsesi = emailVal == 'asesi';
      final isAsesor = emailVal == 'asesor';
      final fakeUser = AuthUser(
        id: isAsesi ? 'fake-asesi-id' : (isAsesor ? 'fake-asesor-id' : 'fake-user-id'),
        account: emailVal,
        name: isAsesi ? 'Asesi Demo' : (isAsesor ? 'Muhammad Hanafi' : 'User Demo'),
        role: isAsesi ? 'asesi' : (isAsesor ? 'asesor' : 'admin'),
        roles: [isAsesi ? 'asesi' : (isAsesor ? 'asesor' : 'admin')],
      );

      final tokenStorage = TokenStorage.instance;
      await tokenStorage.saveTokens(
        accessToken: isAsesi
            ? 'fake-asesi-token'
            : (isAsesor ? 'fake-asesor-token' : 'fake-user-token'),
        refreshToken: 'fake-refresh-token',
      );
      await tokenStorage.saveUserProfile(fakeUser);
      AuthRepository.currentUserInstance = fakeUser;

      if (!mounted) return;

      mainNavigatorKey = GlobalKey<MainNavigatorState>();
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainNavigator(key: mainNavigatorKey),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
        (route) => false,
      );
      return;
    }

    try {
      final authRepo = AuthRepository(
        dio: ApiService.dio,
        tokenStorage: TokenStorage.instance,
      );
      
      await authRepo.login(
        account: emailVal,
        password: passwordVal,
      );

      // Trigger token registration for all roles
      NotificationService.instance.registerCurrentToken();

      if (!mounted) return;

      // Successful login - transition smoothly to main dashboard
      mainNavigatorKey = GlobalKey<MainNavigatorState>();
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainNavigator(key: mainNavigatorKey),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Real API login failed: $e');

      setState(() {
        _isLoading = false;
        if (e is DioException) {
          final statusCode = e.response?.statusCode;
          if (statusCode == 400) {
            _errorMessage = 'Akun dan password wajib diisi.';
          } else if (statusCode == 401) {
            _errorMessage = 'Akun atau password salah.';
          } else {
            _errorMessage = 'Login gagal. Coba lagi nanti.';
          }
        } else {
          _errorMessage = 'Terjadi kesalahan sistem. Coba lagi nanti.';
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header: Title + Subtitle and Illustration next to it
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Masuk akun untuk mendapatkan akses ke layanan LSP Teknologi Digital',
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
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Login Form Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error Message inside the Card
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                      decoration: InputDecoration(
                        hintText: 'Masukan email aktif',
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
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Password',
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
                        hintText: 'Masukan Password',
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

                    const SizedBox(height: 4),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 20),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Color(0xFFE5E7EB),
                            thickness: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'Masuk Dengan',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Color(0xFFE5E7EB),
                            thickness: 1.0,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: 140,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9FAFB),
                            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GoogleIcon(),
                              SizedBox(width: 8),
                              Text(
                                'Google',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Vector-drawn crisp Google Icon widget with high aesthetic standard
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _GoogleIconPainter(),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w / 2;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Top Arc (Red)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      -2.7,
      1.9,
      true,
      paint,
    );

    // Left Arc (Yellow)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      -4.4,
      1.7,
      true,
      paint,
    );

    // Bottom Arc (Green)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      -0.8,
      1.9,
      true,
      paint,
    );

    // Right Arc (Blue)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      -0.8,
      -1.9,
      true,
      paint,
    );

    // Inner ring (Clean White background cutout)
    paint.color = Colors.white; // Matches Google button background
    canvas.drawCircle(Offset(r, r), r * 0.55, paint);

    // Right horizontal bar (Blue)
    paint.color = const Color(0xFF4285F4);
    final double barW = r * 0.85;
    final double barH = r * 0.35;
    canvas.drawRect(
      Rect.fromLTWH(r, r - barH / 2, barW, barH),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
