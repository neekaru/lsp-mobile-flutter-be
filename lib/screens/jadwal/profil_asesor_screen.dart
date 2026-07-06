import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/jadwal_models.dart';

class ProfilAsesorScreen extends StatelessWidget {
  final String name;
  final String skema;
  final String lokasi;
  final AsesorDetailItem? asesorDetail;

  const ProfilAsesorScreen({
    super.key,
    required this.name,
    required this.skema,
    required this.lokasi,
    this.asesorDetail,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // Use dynamic data if available
    final String displayName =
        asesorDetail?.namaAsesor ??
        ((name.isEmpty || name == 'Belum ditentukan') ? 'Eko Setiabudi' : name);
    final String displayLocation =
        asesorDetail != null && asesorDetail!.kabupatenKota.isNotEmpty
        ? asesorDetail!.kabupatenKota
        : (lokasi.isNotEmpty ? lokasi : 'Yogyakarta');

    final String kompetensi = skema.isNotEmpty
        ? skema
        : 'Junior Web Programmer / Developer';
    final String pengalaman = asesorDetail != null
        ? 'Verifikator / Asesor LSP'
        : 'Belum tersedia';
    final String totalAsesmen = asesorDetail != null
        ? asesorDetail!.totalAsesmen.toString()
        : '0';
    final String tentangAsesor = asesorDetail != null
        ? 'Asesor aktif yang terdaftar dengan No Reg ${asesorDetail!.noReg}. Saat ini bertugas di wilayah ${asesorDetail!.kabupatenKota} untuk mendukung kelancaran proses asesmen kompetensi yang akurat dan kredibel.'
        : 'Berpengalaman lebih dari 10 tahun di bidang terkait dan telah melakukan berbagai asesmen kompetensi di LSP Kompetensi Digital.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Header with black circle back button (consistent with design)
          const CustomAppBar(
            title: 'Profil Asesor',
            rightWidget: SizedBox(width: 32),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card 1: Avatar + Name + Location
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar Circle
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 36,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Text Column (Name + Location)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      displayLocation,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Card 2: Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Kompetensi', kompetensi),
                        const SizedBox(height: 16),
                        _buildDetailRow('Pengalaman', pengalaman),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Asessmen Dilakukan',
                          '',
                          customValue: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$totalAsesmen ',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Asessmen',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Lokasi', displayLocation),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Card 3: Tentang Asesor Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tentang Asesor',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tentangAsesor,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
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
    );
  }

  Widget _buildDetailRow(String label, String value, {Widget? customValue}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Expanded(
          child:
              customValue ??
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
        ),
      ],
    );
  }
}
