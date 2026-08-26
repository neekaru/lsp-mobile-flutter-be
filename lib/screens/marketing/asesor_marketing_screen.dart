import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';

class AsesorMarketingScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const AsesorMarketingScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Marketing & Promosi',
            onBack: onBackToHome,
            rightWidget: const SizedBox(width: 32),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.campaign_rounded,
                          color: Color(0xFF2563EB),
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Menu Marketing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fitur Lead Generator & Peta Potensi Mitra saat ini sedang dalam tahap pengembangan (In Progress).',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.construction_rounded, size: 16, color: Color(0xFF475569)),
                          SizedBox(width: 6),
                          Text(
                            'Fitur Segera Hadir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}