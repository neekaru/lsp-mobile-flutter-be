import 'package:flutter/material.dart';
import '../screens/dashboard/tentang_sistem_screen.dart';
import '../screens/dashboard/panduan_sertifikasi_screen.dart';
import '../screens/dashboard/faq_screen.dart';
import '../screens/dashboard/pengumuman_list_screen.dart';
import '../services/pengumuman_service.dart';
import '../helpers/date_format_helper.dart';

class AdminBantuanPengumuman extends StatefulWidget {
  final bool showBantuan;

  const AdminBantuanPengumuman({
    super.key,
    this.showBantuan = true,
  });

  @override
  State<AdminBantuanPengumuman> createState() => _AdminBantuanPengumumanState();
}

class _AdminBantuanPengumumanState extends State<AdminBantuanPengumuman> {
  List<Map<String, dynamic>> _pengumuman = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPengumuman();
  }

  Future<void> _fetchPengumuman() async {
    final data = await PengumumanService.getPengumuman();
    if (mounted) {
      setState(() {
        _pengumuman = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showBantuan) ...[
          // Section 1: Bantuan & Informasi
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
          const SizedBox(height: 24),
        ],

        // Section 2: Pengumuman
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pengumuman Baru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PengumumanListScreen(pengumuman: _pengumuman),
                  ),
                );
              },
              child: const Row(
                children: [
                  Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Announcement content
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(
                color: Color(0xFF3B82F6),
                strokeWidth: 2,
              ),
            ),
          )
        else if (_pengumuman.isEmpty)
          _buildEmptyPengumuman()
        else
          ..._pengumuman.take(3).map((item) => _buildPengumumanCard(item)),
      ],
    );
  }

  Widget _buildPengumumanCard(Map<String, dynamic> item) {
    final String tanggal = item['tanggal'] ?? '';
    final String formattedDate = tanggal.isNotEmpty
        ? DateFormatHelper.formatToIndonesian(tanggal)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Megaphone icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1FC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item['judul'] ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['isi'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPengumuman() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 36,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada pengumuman aktif',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
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
