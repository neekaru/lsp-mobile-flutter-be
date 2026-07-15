import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class DetailHonorScreen extends StatelessWidget {
  final Map<String, dynamic> detail;
  final String status;
  final String metodePembayaran;
  final String tanggalPembayaran;
  final String noTransfer;
  final int jumlahAsesmen;

  const DetailHonorScreen({
    super.key,
    required this.detail,
    required this.status,
    required this.metodePembayaran,
    required this.tanggalPembayaran,
    required this.noTransfer,
    required this.jumlahAsesmen,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final String title = detail['judul_asesmen'] ?? '';
    final String honorAmount = detail['honor'] ?? 'Rp. 0';
    final String tanggalAsesmen = detail['tanggal'] ?? '20 Juli 2026';
    final String tuk = detail['tuk'] ?? '-';
    
    // Parse/fallback fields based on user design:
    final String jumlahAsessi = detail['jumlah_asesi'] != null 
        ? '${detail['jumlah_asesi']} Orang' 
        : '15 Orang';
    final String jenisAsesmen = detail['jenis_asesmen'] ?? 'Asessmen Online';

    // Format successful payment description
    String datePart = '18 Juli';
    try {
      final parts = tanggalPembayaran.split(' ');
      if (parts.length >= 2) {
        datePart = '${parts[0]} ${parts[1]}';
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(title: 'Detail Honor'),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Card: Scheme Header
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF), // Soft blue
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pembayaran telah berhasil dilakukan pada $datePart',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Heading: Rincian Pembayaran
                    const Text(
                      'Rincian Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. Card 2: Rincian Pembayaran Grid
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jumlah',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  honorAmount,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Tanggal Pembayaran',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tanggalPembayaran,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.museum_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Metode Pembayaran',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            metodePembayaran,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Nomor Resi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  noTransfer,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Heading: Informasi Asessmen
                    const Text(
                      'Informasi Asessmen',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 5. Four Info Rows
                    _buildInfoRow(Icons.calendar_today_outlined, 'Tanggal Asessmen', tanggalAsesmen),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.location_on_outlined, 'Tempat Uji Kompetensi', tuk),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.people_alt_outlined, 'Jumlah Asessi', jumlahAsessi),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.assignment_turned_in_outlined, 'Jenis Asessmen', jenisAsesmen),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}


