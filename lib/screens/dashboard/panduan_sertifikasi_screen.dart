import 'package:flutter/material.dart';

class PanduanSertifikasiScreen extends StatelessWidget {
  const PanduanSertifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Panduan Sertifikasi',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                color: const Color(0xFFF8FAFC), // White/very light grey matching card background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
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
                  ),
                  _buildDivider(),
                  _buildStepItem(
                    icon: Icons.badge_rounded,
                    iconColor: const Color(0xFF1E6FDB),
                    title: '2. Lengkapi Profil',
                    subtitle: 'Isi data diri dan unggah dokumen yang diminta.',
                  ),
                  _buildDivider(),
                  _buildStepItem(
                    icon: Icons.folder_copy_rounded,
                    iconColor: const Color(0xFFD97706), // Amber
                    title: '3. Upload Portofolio',
                    subtitle: 'Unggah bukti pengalaman.',
                  ),
                  _buildDivider(),
                  _buildStepItem(
                    icon: Icons.assignment_rounded,
                    iconColor: const Color(0xFF0D9488), // Teal
                    title: '4. Pra-Asesmen',
                    subtitle: 'Verifikasi dokumen oleh Asesor.',
                  ),
                  _buildDivider(),
                  _buildStepItem(
                    icon: Icons.rate_review_rounded,
                    iconColor: const Color(0xFF4F46E5), // Indigo
                    title: '5. Tes Tertulis/Asesmen',
                    subtitle: 'Uji Kompetensi oleh asesor.',
                  ),
                  _buildDivider(),
                  _buildStepItem(
                    icon: Icons.workspace_premium_rounded,
                    iconColor: const Color(0xFF16A34A), // Green
                    title: '6. Keluar Sertifikat',
                    subtitle: 'Sertifikat akan keluar jika uji kompetensi kompeten.',
                  ),
                ],
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
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Container with check/plus badge styling
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE2F0FD), // light blue background
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        // Texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: const Divider(
        color: Color(0xFFCBD5E1),
        height: 1,
        thickness: 1,
      ),
    );
  }
}
