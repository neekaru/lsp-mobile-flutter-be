import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/asesor_asesi_models.dart';
import '../../utils/date_format_helper.dart';

class AsesorAsesiErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AsesorAsesiErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class AsesorAsesiEmptyWidget extends StatelessWidget {
  const AsesorAsesiEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 44,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada asesi ditemukan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Belum ada data asesi yang terhubung dengan jadwal penugasan Anda.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AsesorAsesiCard extends StatelessWidget {
  final AsesorAsesiItem item;
  final bool isSudahTab;
  final VoidCallback onTap;

  const AsesorAsesiCard({
    super.key,
    required this.item,
    required this.isSudahTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeBg = const Color(0xFFEFF6FF);
    Color badgeText = const Color(0xFF2563EB);

    final statusStr = item.rekomendasiAsesor.toLowerCase();
    if (statusStr.contains('kompeten') && !statusStr.contains('belum')) {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF059669);
    } else if (statusStr.contains('belum kompeten')) {
      badgeBg = const Color(0xFFFEF2F2);
      badgeText = const Color(0xFFDC2626);
    }

    final bool isSudahRekomendasi = isSudahTab ||
        (statusStr.contains('kompeten') && !statusStr.contains('belum'));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Name & Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaLengkap,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.jadwalNama.isNotEmpty
                              ? item.jadwalNama
                              : (item.skema.isNotEmpty ? item.skema : '-'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      item.rekomendasiAsesor,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeText,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // TUK Row
              Row(
                children: [
                  const Icon(
                    LucideIcons.building,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'TUK: ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.tukNama.isNotEmpty ? item.tukNama : '-',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Jadwal Row
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Jadwal: ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      formatAsesorAsesiJadwalStatus(
                        item.jadwalTanggal,
                        isSudahRekomendasi: isSudahRekomendasi,
                      ),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSudahRekomendasi
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: getAsesorAsesiJadwalStatusColor(
                          item.jadwalTanggal,
                          isSudahRekomendasi: isSudahRekomendasi,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatAsesorAsesiJadwalStatus(String dateStr,
    {bool isSudahRekomendasi = false}) {
  if (dateStr.trim().isEmpty || dateStr == '-') {
    return '-';
  }
  // Jika asesi sudah selesai / sudah rekomendasi, tampilkan tanggal asesmen saja
  if (isSudahRekomendasi) {
    return DateFormatHelper.formatToIndonesian(dateStr);
  }
  final parsed = DateFormatHelper.parseDate(dateStr);
  if (parsed == null) {
    return dateStr;
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final scheduledDate = DateTime(parsed.year, parsed.month, parsed.day);
  final diff = today.difference(scheduledDate).inDays;

  if (diff > 0) {
    return 'Lewat $diff Hari';
  } else if (diff == 0) {
    return 'Hari Ini';
  } else {
    final daysLeft = -diff;
    if (daysLeft == 1) {
      return 'Besok';
    }
    return '$daysLeft Hari Lagi';
  }
}

Color getAsesorAsesiJadwalStatusColor(String dateStr,
    {bool isSudahRekomendasi = false}) {
  if (isSudahRekomendasi) {
    return const Color(0xFF334155);
  }
  if (dateStr.trim().isEmpty || dateStr == '-') {
    return const Color(0xFF64748B);
  }
  final parsed = DateFormatHelper.parseDate(dateStr);
  if (parsed == null) {
    return const Color(0xFF334155);
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final scheduledDate = DateTime(parsed.year, parsed.month, parsed.day);
  final diff = today.difference(scheduledDate).inDays;

  if (diff > 0) {
    return const Color(0xFFDC2626);
  } else if (diff == 0) {
    return const Color(0xFF059669);
  } else {
    return const Color(0xFF2563EB);
  }
}
