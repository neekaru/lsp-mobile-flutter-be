import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/app_notification_storage.dart';
import 'services/token_storage.dart';

// Import screens
import 'screens/auth/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dashboard/statistik_screen.dart';
import 'screens/jadwal/jadwal_screen.dart';
import 'screens/sertifikat/sertifikat_screen.dart';
import 'screens/profile/profile_screen.dart';

// Import widgets
import 'widgets/bottom_menu_bar.dart';

// Global keys for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<MainNavigatorState> mainNavigatorKey = GlobalKey<MainNavigatorState>();

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  if (kDebugMode) {
    debugPrint('📨 Background message received!');
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
  }
  
  final data = message.data;
  final notifUserId = data['user_id']?.toString();

  if (notifUserId != null && notifUserId.isNotEmpty) {
    final cachedUser = await TokenStorage.instance.getUserProfile();
    final currentUserId = cachedUser?.id;
    if (currentUserId == null || notifUserId != currentUserId) {
      if (kDebugMode) {
        debugPrint('⚠️ Ignored background notification: user_id mismatch (notif: $notifUserId, current: $currentUserId)');
      }
      return;
    }
  }

  final type = data['type'] ?? '';
  
  String getTitle() {
    if (message.notification?.title != null) return message.notification!.title!;
    switch (type) {
      case 'status_kompeten':
        return 'Status Kelulusan';
      case 'rekomendasi_asesor':
        return 'Rekomendasi Asesor';
      case 'sertifikat_terbit':
        return 'Sertifikat Terbit';
      default:
        return 'Notifikasi Baru';
    }
  }

  String getBody() {
    if (message.notification?.body != null) return message.notification!.body!;
    final skema = data['skema'] ?? 'Skema';
    final asesor = data['asesor'] ?? 'Asesor';
    switch (type) {
      case 'status_kompeten':
        return 'Selamat! Anda dinyatakan kompeten pada skema $skema.';
      case 'rekomendasi_asesor':
        return 'Asesor $asesor telah memberikan rekomendasi.';
      case 'sertifikat_terbit':
        return 'Sertifikat untuk skema $skema telah diterbitkan.';
      default:
        return 'Ketuk untuk melihat detail selengkapnya.';
    }
  }

  final title = getTitle();
  final body = getBody();

  await AppNotificationStorage.instance.saveNotification(
    title,
    body,
    type,
    data,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized successfully');
    }
    
    // Initialize FCM Notification Service
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('❌ ERROR initializing Firebase/Notifications: $e');
  }
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Load environment variables securely from .env
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      debugPrint('✅ .env loaded successfully');
      debugPrint('📍 BASE_URL: ${dotenv.env['BASE_URL']}');
    }
    
    // Check if BASE_URL is empty or null
    if (dotenv.env['BASE_URL'] == null || dotenv.env['BASE_URL']!.isEmpty) {
      debugPrint('⚠️ WARNING: BASE_URL is null or empty!');
    }
  } catch (e) {
    debugPrint('❌ ERROR loading .env: $e');
    debugPrint('⚠️ Using fallback configuration');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'LSP Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A9EDF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  
  // Cache screens after first visit so they preserve state.
  // Unlike IndexedStack, screens are only created on first visit,
  // not all 5 at startup. This avoids ~10 API calls + heavy map loading.
  final Map<int, Widget> _screenCache = {};

  Widget _getScreen(int index) {
    return _screenCache.putIfAbsent(index, () => _createScreen(index));
  }

  Widget _createScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(
          onNavigateToJadwal: () {
            setState(() {
              _getScreen(2);
              _currentIndex = 2;
            });
          },
        );
      case 1:
        return StatistikScreen(
          onBackToHome: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 2:
        return JadwalScreen(
          onBackToHome: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 3:
        return SertifikatScreen(
          onBackToHome: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 4:
        return ProfileScreen(
          onBackToHome: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      default:
        return const DashboardScreen();
    }
  }

  void setTab(int index) {
    setState(() {
      _getScreen(index);
      _currentIndex = index;
    });
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Keluar Aplikasi?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi LSP Digital Mobile?',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
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
        ],
      ),
    ) ?? false;
  }

  // Lazy tab navigator: only the active screen is in the widget tree.
  // Previously visited screens are kept in _screenCache for state preservation.
  @override
  Widget build(BuildContext context) {
    // Build ONLY the cached screens (visited ones), not all 5.
    
    // Ensure current index is always visited
    if (!_screenCache.containsKey(_currentIndex)) {
      _getScreen(_currentIndex);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          final shouldExit = await _showExitDialog();
          if (shouldExit) {
            await SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(5, (index) {
            if (_screenCache.containsKey(index)) {
              return _screenCache[index]!;
            }
            // Unvisited screens get a zero-cost placeholder
            return const SizedBox.shrink();
          }),
        ),
        bottomNavigationBar: BottomMenuBar(
          selectedIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _getScreen(index); // Create & cache screen on first tap
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
