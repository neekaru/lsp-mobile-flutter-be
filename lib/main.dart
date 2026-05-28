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
    print('✅ .env loaded successfully');
    print('📍 BASE_URL: ${dotenv.env['BASE_URL']}');
    
    // Check if BASE_URL is empty or null
    if (dotenv.env['BASE_URL'] == null || dotenv.env['BASE_URL']!.isEmpty) {
      print('⚠️ WARNING: BASE_URL is null or empty!');
    }
  } catch (e) {
    print('❌ ERROR loading .env: $e');
    print('⚠️ Using fallback configuration');
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
  final Set<int> _visitedScreens = {0}; // Track visited screens, start with Dashboard

  Widget _buildScreen(int index) {
    // Only build screen if it has been visited
    if (!_visitedScreens.contains(index)) {
      return const SizedBox.shrink(); // Return empty widget for unvisited screens
    }

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

  // We can switch screens here. Index 0 is our beautiful Beranda dashboard.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Soft grey background matching screenshots
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(5, (index) => _buildScreen(index)),
      ),
      bottomNavigationBar: BottomMenuBar(
        selectedIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _visitedScreens.add(index); // Mark screen as visited
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
