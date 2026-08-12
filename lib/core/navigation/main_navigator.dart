import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/berita_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/dashboard/statistik_screen.dart';
import '../../screens/jadwal/jadwal_screen.dart';
import '../../screens/penugasan/laporan_tugas_screen.dart';
import '../../screens/penugasan/penugasan_screen.dart';
import '../../screens/profile/profile_admin_screen.dart';
import '../../screens/profile/profile_asesor_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/sertifikat/asesi_sertifikat_screen.dart';
import '../../screens/sertifikat/sertifikat_screen.dart';
import '../../screens/sertifikat/skema_sertifikasi_screen.dart';
import '../../screens/sertifikat/validasi_sertifikat_screen.dart';
import '../../services/auth_repository.dart';
import '../../widgets/bottom_menu_bar.dart';

// Global keys for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<MainNavigatorState> mainNavigatorKey = GlobalKey<MainNavigatorState>();

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  bool _isDisposed = false;

  // Lazily-built: only the current tab on login; others built on visit.
  // Prevents ALL screens' initState (and their API calls) from firing at once.
  final Set<int> _visitedTabs = {0};

  // Screens created ONCE and kept alive — never re-instantiated on rebuild.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    AuthRepository.registerTokenExpiredCallback(_handleTokenExpired);

    final isGuest = AuthRepository.currentUserInstance == null;
    if (isGuest) {
      _screens = [
        DashboardScreen(onNavigateToJadwal: () {}),
        BeritaScreen(onBackToHome: () => setTab(0)),
        ValidasiSertifikatScreen(onBackToHome: () => setTab(0)),
        ProfileScreen(onBackToHome: () => setTab(0)),
      ];
    } else {
      final isAsesi =
          !isGuest && AuthRepository.currentUserInstance?.role == 'asesi';
      final isAsesor =
          !isGuest && AuthRepository.currentUserInstance?.role == 'asesor';

      if (isAsesor) {
        _screens = [
          DashboardScreen(onNavigateToJadwal: () => setTab(1)),
          JadwalScreen(onBackToHome: () => setTab(0)),
          PenugasanScreen(onBackToHome: () => setTab(0)),
          LaporanTugasScreen(onBackToHome: () => setTab(0)),
          ProfileAsesorScreen(onBackToHome: () => setTab(0)),
        ];
      } else if (isAsesi) {
        _screens = [
          DashboardScreen(onNavigateToJadwal: () => setTab(2)),
          SkemaSertifikasiScreen(onBackToHome: () => setTab(0)),
          JadwalScreen(onBackToHome: () => setTab(0)),
          AsesiSertifikatScreen(onBackToHome: () => setTab(0)),
          ProfileScreen(onBackToHome: () => setTab(0)),
        ];
      } else {
        _screens = [
          DashboardScreen(onNavigateToJadwal: () => setTab(2)),
          StatistikScreen(onBackToHome: () => setTab(0)),
          JadwalScreen(onBackToHome: () => setTab(0)),
          SertifikatScreen(onBackToHome: () => setTab(0)),
          ProfileAdminScreen(onBackToHome: () => setTab(0)),
        ];
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    AuthRepository.unregisterTokenExpiredCallback(_handleTokenExpired);
    super.dispose();
  }

  void _handleTokenExpired() {
    if (!mounted) return;
    if (AuthRepository.currentUserInstance == null) return;

    AuthRepository.currentUserInstance = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: const Text(
          'Sesi login Anda telah berakhir. Silakan login kembali untuk melanjutkan.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Login Kembali'),
          ),
        ],
      ),
    );
  }

  void setTab(int index) {
    if (_isDisposed || !mounted) return;
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _visitedTabs.add(index); // Lazily mount the new tab's screen
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
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
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
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setTab(0);
        } else {
          final shouldExit = await _showExitDialog();
          if (shouldExit) {
            await SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        // Lazy IndexedStack: only visited tabs have their screen mounted.
        // Non-visited tabs render a SizedBox.shrink() — their State is
        // created on first visit, then kept alive for subsequent visits.
        body: IndexedStack(
          index: _currentIndex,
          children: [
            for (int i = 0; i < _screens.length; i++)
              _visitedTabs.contains(i) ? _screens[i] : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: BottomMenuBar(
          selectedIndex: _currentIndex,
          onTap: setTab,
        ),
      ),
    );
  }
}
