import 'package:material_ui/material_ui.dart';
import '../../../services/marketing/lead_storage_service.dart';

class MarketingKpiHeader extends StatelessWidget {
  final LeadSummaryStats stats;
  final String activeTab;
  final Function(String statusKey) onSelectStatusTab;

  const MarketingKpiHeader({
    super.key,
    required this.stats,
    required this.activeTab,
    required this.onSelectStatusTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Total Potensi Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimasi Akumulasi Calon Asesi',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xCCFFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '±${stats.totalEstimasiSiswa} Siswa / Mahasiswa / Th',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stats.total} Mitra',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4 Grid KPI Cards
          Row(
            children: [
              _buildKpiCard(
                title: 'Lead',
                count: stats.countLead,
                statusKey: 'lead',
                color: const Color(0xFF475569),
                bgColor: const Color(0xFFF1F5F9),
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                title: 'Proposal',
                count: stats.countProspek,
                statusKey: 'prospek',
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                title: 'Follow Up',
                count: stats.countInterest,
                statusKey: 'interest',
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                title: 'Deal',
                count: stats.countSales,
                statusKey: 'sales',
                color: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required int count,
    required String statusKey,
    required Color color,
    required Color bgColor,
  }) {
    final isSelected = activeTab.toLowerCase() == statusKey.toLowerCase();

    return Expanded(
      child: InkWell(
        onTap: () => onSelectStatusTab(statusKey),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

