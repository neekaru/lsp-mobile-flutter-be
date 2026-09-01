import 'package:material_ui/material_ui.dart';

import '../../models/dashboard_models.dart';
import '../../screens/statistik/spt_asesor_jadwal_screen.dart';
import '../../utils/date_format_helper.dart';

const List<String> statistikMonthLabels = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Kartu asesor dengan rincian SPT per bulan.
class SptAsesorCard extends StatelessWidget {
  final SptAsesorItem item;

  const SptAsesorCard({super.key, required this.item});

  void _openDetail(BuildContext context, {int initialBulan = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SptAsesorJadwalScreen(
          asesorId: item.asesorId,
          namaAsesor: item.namaAsesor,
          tglExpired: item.tglExpired,
          statusMasaBerlaku: item.statusMasaBerlaku,
          initialBulan: initialBulan,
          initialTahun: 2026,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (item.statusMasaBerlaku == 'Aktif') {
      statusColor = const Color(0xFF16A34A);
    } else if (item.statusMasaBerlaku == 'Tenggang') {
      statusColor = const Color(0xFFD97706);
    } else {
      statusColor = const Color(0xFFDC2626);
    }

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openDetail(context),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaAsesor,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (item.tglExpired.isNotEmpty)
                              Text(
                                'Expired: ${DateFormatHelper.formatToIndonesian(item.tglExpired)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.statusMasaBerlaku,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.total} SPT',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Penugasan per Bulan (2026):',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Klik untuk detail',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(statistikMonthLabels.length, (index) {
                      final m = statistikMonthLabels[index];
                      final count = item.bulanan[m] ?? 0;
                      final isAssigned = count > 0;
                      return InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _openDetail(context, initialBulan: index + 1),
                        child: Container(
                          width: 48,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isAssigned
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text(
                                m,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isAssigned
                                      ? Colors.white70
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isAssigned ? Colors.white : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu asesi 2026 dengan rincian per bulan.
class Asesi2026Card extends StatelessWidget {
  final Asesi2026Item item;

  const Asesi2026Card({super.key, required this.item});

  void _openDetail(BuildContext context, {int initialBulan = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SptAsesorJadwalScreen(
          asesorId: item.asesorId,
          namaAsesor: item.namaAsesor,
          tglExpired: item.tglExpired,
          statusMasaBerlaku: item.statusMasaBerlaku,
          initialBulan: initialBulan,
          initialTahun: 2026,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    Color statusTextColor;
    if (item.statusMasaBerlaku == 'Aktif') {
      statusBgColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF16A34A);
    } else if (item.statusMasaBerlaku == 'Tenggang') {
      statusBgColor = const Color(0xFFFFF8E1);
      statusTextColor = const Color(0xFFD97706);
    } else {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFDC2626);
    }

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openDetail(context),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaAsesor,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (item.tglExpired.isNotEmpty)
                              Text(
                                'Expired: ${DateFormatHelper.formatToIndonesian(item.tglExpired)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.statusMasaBerlaku,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.totalAsesi} Asesi',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.totalJadwal} Jadwal',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jumlah Asesi per Bulan (2026):',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Klik untuk detail',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(statistikMonthLabels.length, (index) {
                      final m = statistikMonthLabels[index];
                      final count = item.bulanan[m] ?? 0;
                      final isAssigned = count > 0;
                      return InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _openDetail(context, initialBulan: index + 1),
                        child: Container(
                          width: 48,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isAssigned
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text(
                                m,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isAssigned
                                      ? Colors.white70
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isAssigned ? Colors.white : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
