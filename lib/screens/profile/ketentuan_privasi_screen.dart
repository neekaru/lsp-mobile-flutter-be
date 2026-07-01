import 'package:flutter/material.dart';

class KetentuanPrivasiScreen extends StatelessWidget {
  const KetentuanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          // Custom App Bar (Header kayak Statistik)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circular Black Back Arrow Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
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
                
                // Centered screen title
                const Text(
                  'Ketentuan Privasi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                
                // Spacer to balance layout so title is centered
                const SizedBox(width: 32),
              ],
            ),
          ),
          
          // Divider below appbar
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top illustration image (syarat_2.png is the security shield illustration)
                  Image.asset(
                    'assets/syarat_2.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // Main title
                  const Text(
                    'Ketentuan Privasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle notice
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'LSP Teknologi Digital berkomitmen untuk melindungi privasi dan data pribadi Anda sesuai peraturan perundang-undangan yang berlaku.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Cards List
                  _buildRuleCard(
                    icon: Icons.person_rounded,
                    title: 'Informasi Yang Kami Kumpulkan',
                    description: 'Kami menyimpan data pribadi anda yang anda berikan berupa email, nomor hp, nama lengkap dan data pendukung sertifikasi lainnya.',
                  ),
                  _buildRuleCard(
                    icon: Icons.storage_rounded,
                    title: 'Penggunaan Informasi',
                    description: 'Informasi digunakan untuk proses pendaftaran, verifikasi, pelaksanaan sertifikat, komunikasi dan peningkatan pelayanan.',
                  ),
                  _buildRuleCard(
                    icon: Icons.verified_user_rounded,
                    title: 'Perlindungan Data',
                    description: 'kami menerapkan langkah keamanan teknis dan organisasi untuk melindungi data pribadi Anda dari akses, perubahan, atau penyalahgunaan.',
                  ),
                  _buildRuleCard(
                    icon: Icons.share_rounded,
                    title: 'Pembagian Informasi',
                    description: 'Kami tidak menjual atau menyewakan data pribadi Anda. Informasi hanya dapat dibagikan kepada pihak terkait untuk keperluan sertifikasi sesuai ketentuan.',
                  ),
                  _buildRuleCard(
                    icon: Icons.credit_card_rounded,
                    title: 'Hak Anda',
                    description: 'Anda memiliki hak untuk mengakses, memperbarui, atau menghapus data pribadi Anda dengan menghubungi kami melalui kontak resmi.',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light off-white grey background
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD2E6F7), // Soft blue circle background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFF378CE7), // App theme primary blue icon color
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
