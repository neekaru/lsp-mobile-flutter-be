import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class TentangLspScreen extends StatelessWidget {
  const TentangLspScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          const CustomAppBar(
            title: 'Tentang LSP',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang LSP Teknologi Digital',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildCertificateIllustration(),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Membangun SDM Digital Unggul',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Membangun SDM Digital Unggul. LSP Teknologi Digital berkomitmen mempercepat transformasi digital Indonesia dengan mencetak talenta IT yang siap bersaing di kancah global melalui tiga pilar utama:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPillarBullet(
                          'Standar Nasional',
                          'Pengujian kompetensi resmi berbasis standar BNSP.',
                        ),
                        _buildPillarBullet(
                          'Kebutuhan Industri',
                          'Materi uji yang selalu diselaraskan dengan kebutuhan teknologi digital masa kini.',
                        ),
                        _buildPillarBullet(
                          'Pengakuan Resmi',
                          'Memberikan bukti nyata keahlian yang diakui oleh dunia kerja dan industri.',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Keunggulan Sertifikasi LSP TD',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildKeunggulanItem('Kurikulum & materi berstandar BNSP'),
                        _buildKeunggulanItem('Asessor kompetensi profesional & tersertifikasi'),
                        _buildKeunggulanItem('Jaringan kemitraan industri yang luas'),
                        _buildKeunggulanItem('Proses uji kompetensi yang transparan dan efisien'),
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

  Widget _buildCertificateIllustration() {
    return Container(
      width: 76,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5), // Dark blue certificate background
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The paper/inner part
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD), // Light blue paper color
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder line 1
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF90CAF9),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(height: 4),
                // Placeholder line 2
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF90CAF9),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
          // Red Ribbon 1
          Positioned(
            bottom: -4,
            right: 18,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 5,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
                ),
              ),
            ),
          ),
          // Red Ribbon 2
          Positioned(
            bottom: -4,
            right: 12,
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                width: 5,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
                ),
              ),
            ),
          ),
          // Gold Seal
          Positioned(
            bottom: 0,
            right: 11,
            child: Container(
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107), // Gold/Amber
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeunggulanItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF64748B),
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
