import 'package:flutter/material.dart';

class TentangKitaScreen extends StatelessWidget {
  const TentangKitaScreen({super.key});

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Match Berita background
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar matching Berita style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Tentang Kita',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Icon(Icons.more_horiz_rounded, color: Colors.black, size: 24),
                ],
              ),
            ),
            
            // Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Main Info Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white, // Clean white card to pop on grey background
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo + Text Header Row
                          Row(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'LSP',
                                      style: TextStyle(
                                        color: Color(0xFF1E3A8A), // Dark blue
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Teknologi Sertifikasi Digital',
                                      style: TextStyle(
                                        color: Color(0xFF1E6FDB), // Primary blue
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Description
                          const Text(
                            'LSP adalah lembaga yang berafiliasi dengan BNSP untuk melakukan sertifikasi kompetensi kerja sesuai dengan standar profesi nasional.',
                            style: TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const Divider(color: Color(0xFFE2E8F0), height: 24, thickness: 1),
                          // Visi
                          const Text(
                            'Visi',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Menjadi lembaga sertifikasi kompetensi terkemuka dan terpercaya.',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Misi
                          const Text(
                            'Misi',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '1. Menyelenggarakan Uji Kompetensi secara terbuka dan profesional.\n2. Meningkatkan SDM di Indonesia.',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legalitas Card
                    _buildItem(
                      context,
                      title: 'Legalitas',
                      onTap: () {
                        _showDetailBottomSheet(
                          context,
                          'Legalitas',
                          'Lembaga Sertifikasi Profesi (LSP) Teknologi Digital memiliki lisensi resmi dari Badan Nasional Sertifikasi Profesi (BNSP) nomor BNSP-LSP-1565-ID.',
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Akreditasi Card
                    _buildItem(
                      context,
                      title: 'Akreditasi',
                      onTap: () {
                        _showDetailBottomSheet(
                          context,
                          'Akreditasi',
                          'Telah terakreditasi dan diakui oleh Kementerian Komunikasi dan Informatika serta BNSP untuk menyelenggarakan asesmen kompetensi kerja di berbagai skema bidang digital.',
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Kontak Kami Card
                    _buildItem(
                      context,
                      title: 'Kontak Kami',
                      onTap: () {
                        _showDetailBottomSheet(
                          context,
                          'Kontak Kami',
                          'Hubungi Kami:\n\nAlamat: Jl. Raya Jatinegara Barat No.123, Jakarta Timur\nEmail: info@lspdigital.id\nTelepon: (021) 85918888\nWebsite: www.lspdigital.id',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Pop white card
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF1E6FDB),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
