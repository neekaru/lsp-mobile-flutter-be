// ============================================================================
// Kartu jadwal untuk role Asesor.
//
// Diekstrak dari jadwal_role_cards.dart agar tiap kartu per role mudah
// dipelihara.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../models/jadwal_models.dart';
import 'jadwal_card_common.dart';
import 'jadwal_format_helpers.dart';

/// Kartu jadwal untuk role Asesor.
class JadwalAsesorCard extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onTap;

  const JadwalAsesorCard({super.key, required this.item, required this.onTap});

  String get _badgeText {
    if (item.isDraft) {
      return 'Draft';
    } else if (item.isRunning) {
      return 'Berjalan';
    } else if (item.status == 'pelaporan') {
      return 'Pelaporan';
    } else if (item.status == 'canceled') {
      return 'Batal';
    } else if (item.status == 'completed') {
      return 'Selesai';
    }
    return item.status;
  }

  Color get _badgeBg {
    if (item.isDraft) {
      return const Color(0xFFFEF3C7);
    } else if (item.isRunning) {
      return const Color(0xFFDBEAFE);
    } else if (item.status == 'pelaporan') {
      return const Color(0xFFF3E8FF);
    } else if (item.status == 'canceled') {
      return const Color(0xFFFEE2E2);
    } else if (item.status == 'completed') {
      return const Color(0xFFD1FAE5);
    }
    return const Color(0xFFE2E8F0);
  }

  Color get _badgeTextColor {
    if (item.isDraft) {
      return const Color(0xFFD97706);
    } else if (item.isRunning) {
      return const Color(0xFF2563EB);
    } else if (item.status == 'pelaporan') {
      return const Color(0xFF7C3AED);
    } else if (item.status == 'canceled') {
      return const Color(0xFFDC2626);
    } else if (item.status == 'completed') {
      return const Color(0xFF059669);
    }
    return const Color(0xFF475569);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Icon, Title & TUK, Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.isSjj
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFE5F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: item.isSjj
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF2C6C9C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.skema,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937), // Dark gray
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.tuk,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280), // Gray 500
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
                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _badgeText,
                      style: TextStyle(
                        color: _badgeTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFECEFF1)),
              const SizedBox(height: 12),

              // Columns: Waktu Asesmen, Asesor, Jumlah Peserta
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JadwalInfoColumn(
                    icon: Icons.access_time_rounded,
                    label: 'Waktu Asesmen',
                    value:
                        '${jadwalFormatIndonesianDayAndDate(item.tanggalMulai)}\n08:00 - 11:00 WIB',
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: const Color(0xFFECEFF1),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  JadwalInfoColumn(
                    icon: Icons.person_outline_rounded,
                    label: 'Asesor',
                    value: jadwalDisplayAsesor(item),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: const Color(0xFFECEFF1),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  JadwalInfoColumn(
                    icon: Icons.people_outline_rounded,
                    label: 'Peserta',
                    value:
                        '${item.totalAsesi > 0 ? item.totalAsesi : (item.jumlahAsesi > 0 ? item.jumlahAsesi : 0)} Asesi',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              JadwalDetailButton(onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}
