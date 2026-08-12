import 'package:flutter/material.dart';
import '../../screens/dashboard/tentang_sistem_screen.dart';
import '../../screens/dashboard/panduan_sertifikasi_screen.dart';
import '../../screens/dashboard/faq_screen.dart';

class BantuanInformasiSection extends StatelessWidget {
  const BantuanInformasiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Bantuan & Informasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        _buildBantuanCard(
          icon: Icons.info_outline_rounded,
          title: 'Tentang Sistem Sertifikasi Digital LSP',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TentangSistemScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildBantuanCard(
          icon: Icons.menu_book_rounded,
          title: 'Panduan Mendaftar Sertifikasi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PanduanSertifikasiScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildBantuanCard(
          icon: Icons.help_outline_rounded,
          title: 'Tanya Jawab (FAQ)',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FaqScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBantuanCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
