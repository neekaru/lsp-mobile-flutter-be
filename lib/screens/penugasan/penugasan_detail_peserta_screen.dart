import 'package:flutter/material.dart';
import '../../models/jadwal_models.dart';
import '../../widgets/custom_app_bar.dart';

class PenugasanDetailPesertaScreen extends StatelessWidget {
  final AsesiItem asesi;
  final String jadwalTitle;

  const PenugasanDetailPesertaScreen({
    super.key,
    required this.asesi,
    required this.jadwalTitle,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // Mock data based on candidate ID for realism and consistency
    final int seed = asesi.id;
    final String nik = '625374${(seed * 7382 + 1000000).toString().padRight(7, '0').substring(0, 7)}';
    
    final cities = ['Yogyakarta', 'Semarang', 'Surabaya', 'Jakarta', 'Bandung'];
    final city = cities[seed % cities.length];
    final String tempatTanggalLahir = '$city, 10 Mei 1998';
    
    final String institusi = seed % 2 == 0 ? 'LPP Jigja' : 'LPP Cahaya Borneo';
    final String cleanName = asesi.namaLengkap.toLowerCase().replaceAll(' ', '');
    final String email = '$cleanName@gmail.com';
    
    final String noTelepon = '08567873${(seed * 31 + 1000).toString().padRight(4, '0').substring(0, 4)}';
    final String noPeserta = 'PES-2026-0724-${seed.toString().padLeft(3, '0')}';

    // Status mapping for Asessment
    final String? rec = asesi.hasilRekomendasi;
    
    // Green badge colors (Lengkap, Hadir, Kompeten)
    const Color greenBg = Color(0xFFA5D6A7);
    const Color greenText = Color(0xFF2E7D32);

    // Orange/Beige badge colors (Belum Dinilai, Belum Dibuat, Belum Diunggah)
    const Color orangeBg = Color(0xFFFFCC80);
    const Color orangeText = Color(0xFFE65100);

    // Red badge colors (Belum Kompeten)
    const Color redBg = Color(0xFFFFCDD2);
    const Color redText = Color(0xFFC62828);

    String tugasStatus = 'Belum Dinilai';
    Color tugasBg = orangeBg;
    Color tugasTextColor = orangeText;

    if (rec == 'K') {
      tugasStatus = 'Kompeten';
      tugasBg = greenBg;
      tugasTextColor = greenText;
    } else if (rec == 'BK') {
      tugasStatus = 'Belum Kompeten';
      tugasBg = redBg;
      tugasTextColor = redText;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          
          CustomAppBar(
            title: 'Detail Peserta',
            rightWidget: const SizedBox(width: 32),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Circle Avatar
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF94A3B8),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Name and No Peserta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asesi.namaLengkap,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No Peserta :$noPeserta',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Profile Details list
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildProfileRow('NIK', nik),
                        _buildProfileRow('Tempat, Tanggal Lahir', tempatTanggalLahir),
                        _buildProfileRow('Skema Sertifikat', jadwalTitle),
                        _buildProfileRow('Institusi', institusi),
                        _buildProfileRow('Email', email),
                        _buildProfileRow('No.Telepon', noTelepon),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Status Kelengkapan Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F1FC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFB3D7F4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Kelengkapan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Portofolio',
                          statusText: 'Lengkap',
                          badgeBg: greenBg,
                          badgeTextColor: greenText,
                        ),
                        _buildStatusRow(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Dokumen Pendukung',
                          statusText: 'Lengkap',
                          badgeBg: greenBg,
                          badgeTextColor: greenText,
                        ),
                        _buildStatusRow(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Persyaratan',
                          statusText: 'Lengkap',
                          badgeBg: greenBg,
                          badgeTextColor: greenText,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Status Assessment Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F1FC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFB3D7F4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Asessment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Kehadiran',
                          statusText: 'Hadir',
                          badgeBg: greenBg,
                          badgeTextColor: greenText,
                        ),
                        _buildStatusRow(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Tugas Asessmen',
                          statusText: tugasStatus,
                          badgeBg: tugasBg,
                          badgeTextColor: tugasTextColor,
                        ),
                        _buildStatusRow(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Laporan',
                          statusText: 'Belum Dibuat',
                          badgeBg: orangeBg,
                          badgeTextColor: orangeText,
                        ),
                        _buildStatusRow(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Rekaman',
                          statusText: 'Belum Diunggah',
                          badgeBg: orangeBg,
                          badgeTextColor: orangeText,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String statusText,
    required Color badgeBg,
    required Color badgeTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
