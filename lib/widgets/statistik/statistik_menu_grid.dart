import 'package:material_ui/material_ui.dart';
import '../../screens/statistik/statistik_detail_screen.dart';

class _MenuItem {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MenuItem(this.value, this.label, this.icon, this.color);
}

class StatistikMenuGrid extends StatelessWidget {
  const StatistikMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuGroup(
          context,
          title: 'Asesor Kompetensi',
          items: const [
            _MenuItem('domisili_asesor', 'Domisili Asesor', Icons.location_on_outlined, Color(0xFF0284C7)),
            _MenuItem('kompetensi_teknis', 'Kompetensi Teknis', Icons.build_outlined, Color(0xFF7C3AED)),
            _MenuItem('masa_berlaku', 'Masa Berlaku', Icons.event_outlined, Color(0xFF059669)),
            _MenuItem('spt_2026', 'SPT 2026', Icons.assignment_ind_outlined, Color(0xFFD97706)),
            _MenuItem('asesi_2026', 'Asesi 2026', Icons.groups_outlined, Color(0xFF2563EB)),
          ],
        ),
        const SizedBox(height: 12),
        _buildMenuGroup(
          context,
          title: 'Skema Sertifikasi',
          items: const [
            _MenuItem('jenis_skema', 'Jenis Skema', Icons.schema_outlined, Color(0xFF2563EB)),
            _MenuItem('muk', 'MUK', Icons.folder_open_outlined, Color(0xFFDC2626)),
            _MenuItem('praktisi', 'Praktisi', Icons.people_outline, Color(0xFF0891B2)),
          ],
        ),
        const SizedBox(height: 12),
        _buildMenuGroup(
          context,
          title: 'Pemegang Sertifikat',
          items: const [
            _MenuItem('masa_tenggang_sertifikat', 'Masa Tenggang', Icons.warning_amber_outlined, Color(0xFFF59E0B)),
            _MenuItem('tahun_2026', 'Tahun 2026', Icons.calendar_today_outlined, Color(0xFF16A34A)),
            _MenuItem('3_tahun', '3 Tahun', Icons.history_outlined, Color(0xFF9333EA)),
            _MenuItem('kompetensi', 'Kompetensi', Icons.verified_outlined, Color(0xFFEA580C)),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildMenuButton(context, items[index]),
        ),
      ],
    );
  }

  static DateTime _lastGridNavTime = DateTime.fromMillisecondsSinceEpoch(0);

  Widget _buildMenuButton(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: () {
        final now = DateTime.now();
        if (now.difference(_lastGridNavTime).inMilliseconds < 600) return;
        _lastGridNavTime = now;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatistikDetailScreen(menuKey: item.value),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x03000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
