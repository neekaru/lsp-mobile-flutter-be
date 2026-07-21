import 'package:flutter/material.dart';

class RingkasanWidget extends StatelessWidget {
  final int sertifikatAktif;
  final int skemaKompetensi;
  final int sertifikatKadaluarsa;
  final int totalUjiKompetensi;

  const RingkasanWidget({
    super.key,
    this.sertifikatAktif = 0,
    this.skemaKompetensi = 0,
    this.sertifikatKadaluarsa = 0,
    this.totalUjiKompetensi = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _buildSummaryCard(
              title: 'Sertifikat Aktif',
              value: sertifikatAktif.toString(),
              icon: Icons.workspace_premium_rounded,
              iconColor: const Color(0xFFFFB300),
              bgColor: const Color(0xFFFFFBEB),
            ),
            _buildSummaryCard(
              title: 'Skema Kompetensi',
              value: skemaKompetensi.toString(),
              icon: Icons.assignment_turned_in_rounded,
              iconColor: const Color(0xFF10B981),
              bgColor: const Color(0xFFECFDF5),
            ),
            _buildSummaryCard(
              title: 'Sertifikat Kadaluarsa',
              value: sertifikatKadaluarsa.toString(),
              icon: Icons.history_toggle_off_rounded,
              iconColor: const Color(0xFFEF4444),
              bgColor: const Color(0xFFFEF2F2),
            ),
            _buildSummaryCard(
              title: 'Total Uji Kompetensi',
              value: totalUjiKompetensi.toString(),
              icon: Icons.fact_check_rounded,
              iconColor: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFF5F3FF),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
