import 'package:flutter/material.dart';

class PanduanSertifikasiScreen extends StatelessWidget {
  const PanduanSertifikasiScreen({super.key});

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
                    'Panduan Sertifikasi',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
                      child: Text(
                        'Alur Sertifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    
                    // Workflow Container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA), // Light background card matching the design image
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        children: [
                          _buildStepItem(
                            icon: Icons.calendar_today_rounded,
                            iconColor: const Color(0xFF1E6FDB),
                            title: '1. Daftar',
                            subtitle: 'Pilih Skema yang di inginkan dan daftar.',
                            badge: 'plus',
                          ),
                          _buildStepItem(
                            icon: Icons.badge_rounded,
                            iconColor: const Color(0xFF1E6FDB),
                            title: '2. Lengkapi Profil',
                            subtitle: 'Isi data diri dan unggah dokumen yang diminta.',
                            badge: 'check',
                          ),
                          _buildStepItem(
                            icon: Icons.folder_rounded,
                            iconColor: const Color(0xFFD97706),
                            title: '3. Upload Portofolio',
                            subtitle: 'Unggah bukti pengalaman.',
                            badge: 'plus',
                          ),
                          _buildStepItem(
                            icon: Icons.description_rounded,
                            iconColor: const Color(0xFF0D9488),
                            title: '4. Pra-Asessmen',
                            subtitle: 'Verifikasi dokumen oleh Asessor.',
                            badge: 'check',
                          ),
                          _buildStepItem(
                            icon: Icons.assignment_turned_in_rounded,
                            iconColor: const Color(0xFF1E6FDB),
                            title: '5. Tes Tertulis/Asessmen',
                            subtitle: 'Uji Kompetensi oleh assessor.',
                          ),
                          _buildStepItem(
                            icon: Icons.workspace_premium_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: '6. Dinyatakan Kompeten',
                            subtitle: 'Dinyatakan Kompeten oleh Asessor penguji.',
                          ),
                          _buildStepItem(
                            icon: Icons.assignment_rounded,
                            iconColor: const Color(0xFF1E6FDB),
                            title: '7. Sertifikat Terbit',
                            subtitle: 'Sertifikat akan keluar jika uji kompetensi kompeten.',
                            isLast: true,
                          ),
                        ],
                      ),
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

  Widget _buildStepItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isLast = false,
    String? badge,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left column: Icon and Vertical Timeline Line
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F0FD), // Light blue icon container background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E), // Vibrant green badge matching design
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badge == 'plus' ? Icons.add : Icons.check,
                          color: Colors.white,
                          size: 8,
                        ),
                      ),
                    ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFCBD5E1), // Vertical timeline line
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Right column: Title and Subtitle content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 2), // Align slightly with icon center
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
