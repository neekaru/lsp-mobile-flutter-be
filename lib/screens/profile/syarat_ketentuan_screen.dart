import 'package:flutter/material.dart';

class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

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
                  'Syarat & Ketentuan',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                
                // Spacer to balance the layout so title is centered
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
                  // Top illustration image
                  Image.asset(
                    'assets/syarat_1.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // Main title
                  const Text(
                    'Syarat & ketentuan',
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
                      'Dengan menggunakan layanan LSP Teknologi Digital, Anda telah setuju dengan syarat dan ketentuan berikut.',
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
                    title: 'Akun Pengguna',
                    description: 'Anda wajib mendaftar dan memberikan informasi yang lengkap, benar, dan terbaru. Akun hanya boleh digunakan oleh pemilik yang terdaftar',
                  ),
                  _buildRuleCard(
                    icon: Icons.description_rounded,
                    title: 'Layanan sertifikat',
                    description: 'LSP Teknologi Digital menyediakan layanan sertifikat kompetensi sesuai skema yang tersedia. Informasi skema, biaya, jadwal yang sewaktu-waktu dapat berubah.',
                  ),
                  _buildRuleCard(
                    icon: Icons.folder_rounded,
                    title: 'Dokumen dan Data',
                    description: 'Anda bertanggung jawab atas keaslian dokumen yang diunggah. Dokumen yang tidak valid dapat mengakibatkan pembatalan proses sertifikat.',
                  ),
                  _buildRuleCard(
                    icon: Icons.description_rounded,
                    title: 'Pembayaran',
                    description: 'Semua biaya layanan harus dibayarkan sesuai ketentuan yang berlaku dan tidak dapat dikembalikan, kecuali ditentukan oleh LSP Teknologi Digital.',
                  ),
                  _buildRuleCard(
                    icon: Icons.credit_card_rounded,
                    title: 'Pembayaran',
                    description: 'Semua biaya layanan harus dibayarkan sesuai ketentuan yang berlaku dan tidak dapat dikembalikan, kecuali ditentukan oleh LSP Teknologi Digital.',
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
