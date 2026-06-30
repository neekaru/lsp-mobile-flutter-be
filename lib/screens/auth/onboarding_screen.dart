import 'package:flutter/material.dart';
import '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainNavigator(key: mainNavigatorKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PageView containing illustration, title, and subtitle
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // Illustration Image
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            page.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Spacer(),
                        // Title
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          page.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8,
                  width: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF4FA8E8) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFF4FA8E8),
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 36),

            // Bottom Buttons Section
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
              child: Row(
                children: [
                  if (_currentPage < 2) ...[
                    // Left Button: Lewati
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _skipOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF475569),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Lewati',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Button: Selanjutnya
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FA8E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Selanjutnya',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Single Button: Lanjutkan (transisi ke dashboard publik)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _skipOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FA8E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Lanjutkan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageModel {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingPageModel({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

const List<OnboardingPageModel> _pages = [
  OnboardingPageModel(
    imagePath: 'assets/splash_1.png',
    title: 'Mudah Mengikuti Sertifikat Kompetensi',
    subtitle: 'Daftar sertifikat kapan saja dan dimana saja',
  ),
  OnboardingPageModel(
    imagePath: 'assets/splash_2.png',
    title: 'Pantau Semua Proses Sertifikasi',
    subtitle: 'Pantau proses sertifikasi mulai dari pendaftaran hingga sertifikat Keluar',
  ),
  OnboardingPageModel(
    imagePath: 'assets/splash_3.png',
    title: 'Sertifikat Digital Lebih Mudah Didapat',
    subtitle: 'Melihat hasil Asessmen dan sertifikat lebih mudah',
  ),
];
