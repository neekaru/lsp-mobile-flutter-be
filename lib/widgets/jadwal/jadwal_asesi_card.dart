// ============================================================================
// Kartu jadwal untuk role Asesi.
//
// Diekstrak dari jadwal_role_cards.dart agar tiap kartu per role mudah
// dipelihara.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import '../../models/jadwal_models.dart';
import 'jadwal_card_common.dart';
import 'jadwal_format_helpers.dart';

/// Kartu jadwal untuk role Asesi.
class JadwalAsesiCard extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onTap;

  const JadwalAsesiCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final badgeText = jadwalBadgeText(item);
    final badgeBg = jadwalBadgeBg(item);
    final badgeTextColor = jadwalBadgeTextColor(item);

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
              // Row 1: Icon, Title & TUK, Tanggal Asesmen, Status Badge
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
                            if (item.isSjj) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  'AJJ',
                                  style: TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Tanggal dibawah TUK (Mulai sd Akhir)
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                jadwalFormatDateRange(
                                  item.tanggalMulai,
                                  item.tanggalSelesai,
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4B5563),
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
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
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

              // Columns: Asesor (paling kiri dengan space luas) & Peserta
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JadwalInfoColumn(
                    icon: Icons.person_outline_rounded,
                    label: 'Asesor',
                    value: jadwalDisplayAsesor(item),
                    flex: 3,
                    maxLines: 4,
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: const Color(0xFFECEFF1),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  JadwalInfoColumn(
                    icon: Icons.people_outline_rounded,
                    label: 'Peserta',
                    value:
                        '${item.totalAsesi > 0 ? item.totalAsesi : (item.jumlahAsesi > 0 ? item.jumlahAsesi : 0)} Asesi',
                    flex: 1,
                    maxLines: 1,
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
