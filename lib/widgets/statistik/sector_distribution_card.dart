import 'package:flutter/material.dart';

class SectorDistributionCard extends StatelessWidget {
  const SectorDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Berdasarkan Bidang Sektor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kategori industri dengan asesi terbanyak',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectorBar('Teknologi Informasi & Komunikasi', '9.060', 0.35, const Color(0xFF2C6C9C)),
            _buildSectorBar('Manufaktur & Teknik Industri', '5.695', 0.22, const Color(0xFF3E82B3)),
            _buildSectorBar('Pariwisata & Perhotelan', '4.660', 0.18, const Color(0xFF4FA8E8)),
            _buildSectorBar('Bisnis & Keuangan Administrasi', '3.880', 0.15, const Color(0xFF7CB8E6)),
            _buildSectorBar('Kesehatan & Farmasi', '2.595', 0.10, const Color(0xFFA1D0F5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorBar(String sectorName, String countText, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sectorName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$countText Asesi (${(pct * 100).toInt()}%)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F3F5),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
