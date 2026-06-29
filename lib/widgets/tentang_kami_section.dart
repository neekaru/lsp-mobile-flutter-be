import 'package:flutter/material.dart';
import '../screens/dashboard/tentang_kita_screen.dart';
import '../screens/dashboard/faq_screen.dart';

class TentangKamiSection extends StatelessWidget {
  const TentangKamiSection({super.key});

  void _showDetailBottomSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

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
              _showDetailBottomSheet(
                context,
                'Panduan Mendaftar Sertifikasi',
                'Langkah pendaftaran sertifikasi:\n1. Pilih skema sertifikasi yang sesuai dengan kompetensi Anda.\n2. Isi formulir pendaftaran dan unggah dokumen portofolio.\n3. Lakukan pembayaran dan konfirmasi jadwal asesmen.\n4. Ikuti proses asesmen di Tempat Uji Kompetensi (TUK) yang ditentukan.',
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
