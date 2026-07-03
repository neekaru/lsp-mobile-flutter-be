import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class TentangKitaScreen extends StatefulWidget {
  const TentangKitaScreen({super.key});

  @override
  State<TentangKitaScreen> createState() => _TentangKitaScreenState();
}

class _TentangKitaScreenState extends State<TentangKitaScreen> {
  int? _expandedIndex; // Collapsed by default, can be toggled by the user

  final List<Map<String, String>> _items = [
    {
      'title': 'Legalitas',
      'content': 'Lembaga Sertifikasi Profesi (LSP) Teknologi Digital memiliki lisensi resmi dari Badan Nasional Sertifikasi Profesi (BNSP) nomor BNSP-LSP-1565-ID.',
    },
    {
      'title': 'Akreditasi',
      'content': 'Telah terakreditasi dan diakui oleh Kementerian Komunikasi dan Informatika serta BNSP untuk menyelenggarakan asesmen kompetensi kerja di berbagai skema bidang digital.',
    },
    {
      'title': 'Kontak Kami',
      'content': 'Hubungi Kami:\n\nAlamat: Jl. Raya Jatinegara Barat No.123, Jakarta Timur\nEmail: info@lspdigital.id\nTelepon: (021) 85918888\nWebsite: www.lspdigital.id',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Match Berita background
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar matching Berita style
            const CustomAppBar(title: 'Tentang Kita'),
            
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

                    // Accordion List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final isExpanded = _expandedIndex == index;
                        
                        return _buildAccordionItem(
                          index: index,
                          title: item['title']!,
                          content: item['content']!,
                          isExpanded: isExpanded,
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

  Widget _buildAccordionItem({
    required int index,
    required String title,
    required String content,
    required bool isExpanded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Box
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), // Light background card
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
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
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
                  color: const Color(0xFF1E6FDB),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Content Box (shown if expanded)
        if (isExpanded) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), // Matching light background card
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
