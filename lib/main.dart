import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import screens
import 'screens/dashboard_screen.dart';
import 'screens/statistik_screen.dart';
import 'screens/jadwal_screen.dart';
import 'screens/sertifikat_screen.dart';
import 'screens/placeholder_screen.dart';

// Import widgets
import 'widgets/bottom_menu_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
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
        return const DashboardScreen();
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
        return PlaceholderScreen(
          title: 'Halaman Profil',
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

  // Lazy tab navigator: only the active screen is in the widget tree.
  // Previously visited screens are kept in _screenCache for state preservation.
  @override
  Widget build(BuildContext context) {
    // Build ONLY the cached screens (visited ones), not all 5.
    
    // Ensure current index is always visited
    if (!_screenCache.containsKey(_currentIndex)) {
      _getScreen(_currentIndex);
    }

    return Scaffold(
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
    );
  }
}
