import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import our modular custom widgets
import 'widgets/rangkuman_utama.dart';
import 'widgets/tren_asesmen_chart.dart';
import 'widgets/jadwal_asesmen.dart';
import 'widgets/bottom_menu_bar.dart';
import 'widgets/statistik_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  // We can switch screens here. Index 0 is our beautiful Beranda dashboard.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Soft grey background matching screenshots
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardScreen(),
          const StatistikScreen(),
          // Placeholder screens for other tabs to keep it clean and fully functional
          const PlaceholderScreen(title: 'Halaman Jadwal'),
          const PlaceholderScreen(title: 'Halaman Sertivikat'),
          const PlaceholderScreen(title: 'Halaman Profil'),
        ],
      ),
      bottomNavigationBar: BottomMenuBar(
        selectedIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Top Section: Header & Rangkuman Utama Card Overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Sky Blue Header Background
              Container(
                width: double.infinity,
                height: 260 + statusBarHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFF4FA8E8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, statusBarHeight + 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Custom Logo Placeholder
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x66FFFFFF), // white with 0.4 opacity
                              width: 2,
                            ),
                            color: const Color(0x1AFFFFFF), // white with 0.1 opacity
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.hub_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Title Texts
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'LSP Monitoring sertifikasi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              SizedBox(height: 2),
                              Text(
                                'Monitoring Sertifikasi Nasional',
                                style: TextStyle(
                                  color: Color(0xE6FFFFFF), // white with 0.9 opacity
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification Bell Icon
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rangkuman Utama Card Container (Imported widget)
              Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight + 90,
                  left: 16,
                  right: 16,
                  bottom: 24,
                ),
                child: const RangkumanUtama(),
              ),
            ],
          ),

          // 2. Tren Asesmen Bulanan Section (Imported chart card widget)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TrenAsesmenChart(),
          ),

          // 3. Jadwal Asesmen Mendekati Akhir Section (Imported list widget)
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 32.0),
            child: JadwalAsesmen(),
          ),
        ],
      ),
    );
  }
}

// Simple elegant fallback screen for other navigation tabs
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE5F1FC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.construction_rounded,
                color: Color(0xFF2C6C9C),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$title Sedang Dikembangkan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Layout Beranda siap ditampilkan!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
