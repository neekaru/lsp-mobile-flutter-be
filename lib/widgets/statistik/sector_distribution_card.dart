import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_models.dart';
import '../../helpers/number_format_helper.dart';

class SectorDistributionCard extends StatefulWidget {
  const SectorDistributionCard({super.key});

  @override
  State<SectorDistributionCard> createState() => _SectorDistributionCardState();
}

class _SectorDistributionCardState extends State<SectorDistributionCard> {
  late Future<List<SectorDistribution>> _sectorFuture;

  @override
  void initState() {
    super.initState();
    _sectorFuture = ApiService.getSectorDistribution();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SectorDistribution>>(
      future: _sectorFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final sectors = snapshot.data ?? [];

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

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF2C6C9C),
                      ),
                    ),
                  )
                else
                  ...sectors.asMap().entries.map((entry) {
                    final index = entry.key;
                    final sector = entry.value;
                    final colors = [
                      const Color(0xFF2C6C9C),
                      const Color(0xFF3E82B3),
                      const Color(0xFF4FA8E8),
                      const Color(0xFF7CB8E6),
                      const Color(0xFFA1D0F5),
                    ];
                    final color = colors[index % colors.length];

                    return _buildSectorBar(
                      sector.sectorName,
                      NumberFormatHelper.formatWithDots(sector.count),
                      sector.percentage,
                      color,
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
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
