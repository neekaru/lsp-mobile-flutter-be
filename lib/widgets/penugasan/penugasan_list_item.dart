import 'package:flutter/material.dart';
import '../../models/jadwal_models.dart';

class PenugasanListItem extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onTap;

  const PenugasanListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  String _formatIndonesianDayAndDate(String yyyymmdd) {
    try {
      final dt = DateTime.tryParse(yyyymmdd);
      if (dt == null) return yyyymmdd;
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return '$dayName, ${dt.day} $monthName ${dt.year}';
    } catch (e) {
      return yyyymmdd;
    }
  }

  String _getDisplayAsesor() {
    if (item.asesor.isEmpty) {
      return 'Belum ditentukan';
    }
    return item.asesor.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    String badgeText;
    Color badgeBg;
    Color badgeTextColor;

    if (item.status == 'waiting') {
      badgeText = 'Menunggu';
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
    } else if (item.status == 'running') {
      badgeText = 'Berjalan';
      badgeBg = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF2563EB);
    } else if (item.status == 'pelaporan') {
      badgeText = 'Pelaporan';
      badgeBg = const Color(0xFFF3E8FF);
      badgeTextColor = const Color(0xFF7C3AED);
    } else if (item.status == 'canceled') {
      badgeText = 'Batal';
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFDC2626);
    } else if (item.status == 'completed') {
      badgeText = 'Selesai';
      badgeBg = const Color(0xFFD1FAE5);
      badgeTextColor = const Color(0xFF059669);
    } else {
      badgeText = item.status;
      badgeBg = const Color(0xFFE2E8F0);
      badgeTextColor = const Color(0xFF475569);
    }

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
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF2C6C9C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.skema,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Yogyakarta',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

              // Columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Jadwal Asesmen',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatIndonesianDayAndDate(item.tanggalMulai)}\n08:00 - 11:00 WIB',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 44, color: const Color(0xFFECEFF1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Asesor',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDisplayAsesor(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 44, color: const Color(0xFFECEFF1), margin: const EdgeInsets.symmetric(horizontal: 4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Jadwal Selesai',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatIndonesianDayAndDate(item.tanggalSelesai)}\n08:00 - 11:00 WIB',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD2E3F4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF6C8BB4), width: 1),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Lihat Detail',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C6C9C),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
