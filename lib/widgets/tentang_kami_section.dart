import 'package:flutter/material.dart';
import '../screens/dashboard/tentang_kita_screen.dart';
import '../screens/dashboard/faq_screen.dart';
import '../screens/dashboard/panduan_sertifikasi_screen.dart';

class TentangKamiSection extends StatelessWidget {
  const TentangKamiSection({super.key});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang Kami',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildItem(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Tentang Sistem Sertifikasi Digital LSP',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TentangKitaScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildItem(
            context,
            icon: Icons.menu_book_rounded,
            title: 'Panduan Mendaftar Sertifikasi',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PanduanSertifikasiScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildItem(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Tanya Jawab (FAQ)',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FaqScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // very light background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0), // light border matching screenshot
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Left Icon Box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F0FD), // light blue bg
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1E6FDB), // blue color
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                // Right Chevron Icon
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF1E6FDB),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
