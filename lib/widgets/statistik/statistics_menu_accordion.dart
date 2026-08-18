import 'package:material_ui/material_ui.dart';

class StatisticsMenuAccordion extends StatefulWidget {
  final ValueChanged<String> onSelected;

  const StatisticsMenuAccordion({super.key, required this.onSelected});

  @override
  State<StatisticsMenuAccordion> createState() =>
      _StatisticsMenuAccordionState();
}

class _StatisticsMenuAccordionState extends State<StatisticsMenuAccordion> {
  int? _expandedGroup;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGroup(
          group: 1,
          title: 'Asesor Kompetensi',
          children: [
            _buildMenuItem(
              value: 'domisili_asesor',
              label: 'Domisili Asesor',
              icon: Icons.location_on_outlined,
            ),
            _buildMenuItem(
              value: 'kompetensi_teknis',
              label: 'Kompetensi Teknis',
              icon: Icons.build_outlined,
            ),
            _buildMenuItem(
              value: 'masa_berlaku',
              label: 'Masa Berlaku',
              icon: Icons.event_outlined,
            ),
            _buildMenuItem(
              value: 'spt_2026',
              label: 'SPT 2026',
              icon: Icons.assignment_ind_outlined,
            ),
            _buildMenuItem(
              value: 'asesi_2026',
              label: 'Asesi 2026',
              icon: Icons.groups_outlined,
            ),
          ],

        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        _buildGroup(
          group: 2,
          title: 'Skema Sertifikasi',
          children: [
            _buildMenuItem(
              value: 'jenis_skema',
              label: 'Jenis Skema',
              icon: Icons.schema_outlined,
            ),
            _buildMenuItem(
              value: 'muk',
              label: 'MUK',
              icon: Icons.folder_open_outlined,
            ),
            _buildMenuItem(
              value: 'praktisi',
              label: 'Praktisi',
              icon: Icons.people_outline,
            ),
          ],
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        _buildGroup(
          group: 3,
          title: 'Pemegang Sertifikat',
          children: [
            _buildMenuItem(
              value: 'masa_tenggang_sertifikat',
              label: 'Masa Tenggang',
              icon: Icons.warning_amber_outlined,
            ),
            _buildMenuItem(
              value: 'tahun_2026',
              label: 'Tahun 2026',
              icon: Icons.calendar_today_outlined,
            ),
            _buildMenuItem(
              value: '3_tahun',
              label: '3 Tahun',
              icon: Icons.history_outlined,
            ),
            _buildMenuItem(
              value: 'kompetensi',
              label: 'Kompetensi',
              icon: Icons.verified_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroup({
    required int group,
    required String title,
    required List<Widget> children,
  }) {
    final isExpanded = _expandedGroup == group;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() {
            _expandedGroup = isExpanded ? null : group;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: isExpanded
              ? Column(mainAxisSize: MainAxisSize.min, children: children)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String value,
    required String label,
    IconData? icon,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        widget.onSelected(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon ?? Icons.chevron_right_rounded,
              size: 18,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
