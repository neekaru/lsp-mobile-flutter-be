import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';
import '../../services/auth_repository.dart';
import '../../services/notification_service.dart';
import '../../models/auth_models.dart';
import '../../main.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  String _loadingStatus = "Menyiapkan aplikasi...";
  double _loadingProgress = 0.1;

  @override
  void initState() {
    super.initState();
    
    // Set system status bar to light transparent for maximum screen elegance
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    // Initialize animation controller for a smooth fade & scale wow factor
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // Stage 1: Load configurations
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _loadingStatus = "Membaca konfigurasi .env...";
        _loadingProgress = 0.3;
      });
    }

    try {
      // In case dotenv hasn't loaded yet or we want to double check it
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: ".env");
      }
    } catch (e) {
      debugPrint('Splash dotenv read status: $e');
    }

    // Stage 1.5: Health check server (NEW: backend added /api/health endpoint)
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _loadingStatus = "Memeriksa koneksi server...";
        _loadingProgress = 0.45;
      });
    }

    bool serverHealthy = await ApiService.healthCheck();
    if (!serverHealthy) {
      debugPrint('⚠️ Server health check failed, will use cached data');
    }

    // Stage 1.6: Readiness check (verify DB connection)
    if (serverHealthy) {
      bool serverReady = await ApiService.readyCheck();
      if (!serverReady) {
        debugPrint('⚠️ Server not ready (DB issue), will use cached data');
      }
    }

    // Stage 2: Initialize assets / session check
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _loadingStatus = "Memvalidasi sesi login...";
        _loadingProgress = 0.6;
      });
    }

    AuthUser? loggedInUser;
    try {
      final token = await TokenStorage.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final authRepo = AuthRepository(
          dio: ApiService.dio,
          tokenStorage: TokenStorage.instance,
        );
        loggedInUser = await authRepo.currentUser();
        
        // Register token for all roles
        NotificationService.instance.registerCurrentToken();
      }
    } catch (e) {
      debugPrint('Session loading failed: $e');
      
      bool shouldForceLogout = false;
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          shouldForceLogout = true;
        }
      }

      if (shouldForceLogout) {
        try {
          final authRepo = AuthRepository(
            dio: ApiService.dio,
            tokenStorage: TokenStorage.instance,
          );
          await authRepo.logout();
        } catch (ex) {
          debugPrint('Logout during failed session loading failed: $ex');
        }
      } else {
        // If it's a server/network error (like 502), try to load cached user from TokenStorage
        try {
          final cachedUser = await TokenStorage.instance.getUserProfile();
          if (cachedUser != null) {
            loggedInUser = cachedUser;
            AuthRepository.currentUserInstance = cachedUser;
            debugPrint('Loaded cached user session: ${cachedUser.name}');
          }
        } catch (cacheEx) {
          debugPrint('Failed to load cached user profile: $cacheEx');
        }
      }
    }

    // Stage 3: Smooth progress completion
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _loadingStatus = loggedInUser != null
            ? "Selamat datang kembali, ${loggedInUser.name}..."
            : "Menghubungkan ke server LSP...";
        _loadingProgress = 1.0;
      });
    }

    // Smooth transition
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      final Widget nextScreen = loggedInUser != null
          ? MainNavigator(key: mainNavigatorKey)
          : const OnboardingScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 850),
          reverseTransitionDuration: const Duration(milliseconds: 850),
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            );
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            );
            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF559AD4), // Sky blue premium
              Color(0xFF1E4B70), // Elegant deep navy blue
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top accent bubble for deep aesthetics
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    
                    // Logo with glow & shadow container
                    Hero(
                      tag: 'app_logo',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: const Color(0xFF4FA8E8).withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // App Main Title
                    const Text(
                      'LSP TEKNOLOGI DIGITAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // App Subtitle
                    Text(
                      'Monitoring Sertifikasi Nasional',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Progress Loading Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Column(
                        children: [
                          // Elegant thin progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 4,
                              child: LinearProgressIndicator(
                                value: _loadingProgress,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Dynamic loading status text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _loadingStatus,
                              key: ValueKey<String>(_loadingStatus),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Footer branding
                    Text(
                      'Powered By LSP Teknologi Digital 2026',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
