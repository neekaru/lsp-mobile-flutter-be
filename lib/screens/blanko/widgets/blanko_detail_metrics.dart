import 'package:material_ui/material_ui.dart';

class BlankoDetailMetrics extends StatelessWidget {
  final int jumlahKompeten;
  final int blankoTerkirim;
  final String blankoDiterimaStatus;
  final String rangeText;

  const BlankoDetailMetrics({
    super.key,
    required this.jumlahKompeten,
    required this.blankoTerkirim,
    required this.blankoDiterimaStatus,
    required this.rangeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                label: 'Jumlah K (Kompeten)',
                value: '$jumlahKompeten Orang',
                icon: Icons.people_outline_rounded,
                color: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                label: 'Blanko Terkirim',
                value: '$blankoTerkirim',
                icon: Icons.send_outlined,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                label: 'Blanko Diterima',
                value: blankoDiterimaStatus,
                icon: Icons.mark_email_read_outlined,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF5F3FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                label: 'Rentang Blanko',
                value: rangeText,
                icon: Icons.format_list_numbered_rounded,
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
