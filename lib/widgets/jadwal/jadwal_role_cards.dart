// ============================================================================
// Jadwal Role Cards (Asesi / Asesor / Admin)
//
// Diekstrak dari jadwal_list_item.dart agar tiap kartu per role mudah
// dipelihara.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../models/jadwal_models.dart';

String jadwalFormatIndonesianDate(String yyyymmdd) {
  try {
    final parts = yyyymmdd.split('-');
    if (parts.length != 3) return yyyymmdd;
    final year = parts[0];
    final monthIndex = int.parse(parts[1]);
    final day = int.parse(parts[2]).toString();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final monthName = months[monthIndex - 1];
    return '$day $monthName $year';
  } catch (e) {
    return yyyymmdd;
  }
}

/// Format tanggal dibuat (created_when) untuk baris "Tanggal dibuat:".
/// Ambil bagian tanggal saja (buang jam bila ada).
String jadwalFormatIndonesianDateOnly(String value) {
  final datePart = value.split(' ').first;
  if (datePart.isEmpty) return '';
  return jadwalFormatIndonesianDate(datePart);
}

String jadwalFormatIndonesianDayAndDate(String yyyymmdd) {
  try {
    final dt = DateTime.tryParse(yyyymmdd);
    if (dt == null) return yyyymmdd;
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  } catch (e) {
    return yyyymmdd;
  }
}

Color jadwalStatusColor(JadwalItem item) {
  switch (item.status) {
    case 'draft':
    case 'waiting':
      return const Color(0xFFFBC02D); // Yellow
    case 'completed':
      return const Color(0xFF4CAF50); // Green
    case 'canceled':
      return const Color(0xFFE53935); // Red
    case 'running':
      return const Color(0xFF2196F3); // Blue
    case 'pelaporan':
      return const Color(0xFFFF9800); // Orange
    default:
      return const Color(0xFF2C6C9C);
  }
}

String jadwalStatusText(JadwalItem item) {
  switch (item.status) {
    case 'draft':
    case 'waiting':
      return ''; // Hidden - label sudah tampil di status badge (atas)
    case 'completed':
      return ''; // Hidden - no bottom status text for completed
    case 'canceled':
      return item.displayStatusLabel;
    case 'running':
      if (item.daysLate != null && item.daysLate! > 0) {
        return 'Lewat ${item.daysLate} Hari';
      }
      if (item.sisaHari == 0) {
        return 'Hari Ini';
      }
      if (item.sisaHari == 1) {
        return 'Besok';
      }
      return '${item.sisaHari} Hari Lagi';
    case 'pelaporan':
      if (item.daysLate != null && item.daysLate! > 0) {
        return 'Lewat ${item.daysLate} Hari';
      }
      return item.displayStatusLabel;
    default:
      return item.displayStatusLabel;
  }
}

String jadwalDisplayAsesor(JadwalItem item) {
  if (item.asesor.isEmpty) {
    return 'Belum ditentukan';
  }
  return item.asesor.join(', ');
}

bool jadwalShouldShowWarning(JadwalItem item) {
  // Tampilkan warning jika status running dan ada days_late (terlambat)
  if (item.status == 'running') {
    if (item.daysLate != null && item.daysLate! > 0) {
      return true; // Terlambat
    }
  }
  return false;
}

/// Kolom kecil (Waktu / Asesor / Peserta) di kartu asesi & asesor.
class _JadwalInfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _JadwalInfoColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
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
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937), // Dark gray
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Tombol "Lihat Detail" di bawah kartu.
class _JadwalDetailButton extends StatelessWidget {
  final VoidCallback onTap;

  const _JadwalDetailButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

/// Kartu jadwal untuk role Asesi.
class JadwalAsesiCard extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onTap;

  const JadwalAsesiCard({super.key, required this.item, required this.onTap});

  String get _badgeText {
    if (item.isRunning || item.isDraft) {
      return 'Terjadwal';
    } else if (item.status == 'pelaporan') {
      return 'Berjalan';
    }
    return 'Selesai';
  }

  Color get _badgeBg {
    if (item.isRunning || item.isDraft) {
      return const Color(0xFFD2E3F4);
    } else if (item.status == 'pelaporan') {
      return const Color(0xFFE8F5E9);
    }
    return const Color(0xFFFFEBEE);
  }

  Color get _badgeTextColor {
    if (item.isRunning || item.isDraft) {
      return const Color(0xFF2C6C9C);
    } else if (item.status == 'pelaporan') {
      return const Color(0xFF4CAF50);
    }
    return const Color(0xFFEF5350);
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
                  _JadwalInfoColumn(
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
                  _JadwalInfoColumn(
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
                  _JadwalInfoColumn(
                    icon: Icons.people_outline_rounded,
                    label: 'Peserta',
                    value:
                        '${item.totalAsesi > 0 ? item.totalAsesi : (item.jumlahAsesi > 0 ? item.jumlahAsesi : 0)} Asesi',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _JadwalDetailButton(onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

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
                  _JadwalInfoColumn(
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
                  _JadwalInfoColumn(
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
                  _JadwalInfoColumn(
                    icon: Icons.people_outline_rounded,
                    label: 'Peserta',
                    value:
                        '${item.totalAsesi > 0 ? item.totalAsesi : (item.jumlahAsesi > 0 ? item.jumlahAsesi : 0)} Asesi',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _JadwalDetailButton(onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu jadwal untuk role Admin.
class JadwalAdminCard extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onTap;
  final bool showCreatedDate;

  const JadwalAdminCard({
    super.key,
    required this.item,
    required this.onTap,
    this.showCreatedDate = false,
  });

  String get _displayAsesi {
    final kuota = item.kuota ?? 0;
    return 'Kuota: $kuota';
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.isSjj
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFE5F1FC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.file_text,
                      color: item.isSjj
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF2C6C9C),
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
                            Icon(
                              LucideIcons.map_pin,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
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
                            if (item.isSjj) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
                                ),
                                child: const Text(
                                  'SJJ',
                                  style: TextStyle(
                                    color: Color(0xFF16A34A),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${jadwalFormatIndonesianDate(item.tanggalMulai)} - ${jadwalFormatIndonesianDate(item.tanggalSelesai)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        // Tanggal dibuat (created_when) - hanya tampil di tab Draft admin
                        if (showCreatedDate) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tanggal dibuat: ${jadwalFormatIndonesianDateOnly(item.createdWhen)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Jumlah Asesi
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.users,
                                    size: 12,
                                    color: Color(0xFF666666),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _displayAsesi,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Asesor dikosongkan (admin) — Jumlah Asesi tetap
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (jadwalShouldShowWarning(item))
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.circle_alert,
                                size: 12,
                                color: const Color(0xFFFF6B6B),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Terlambat',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: jadwalStatusColor(item).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.displayStatusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: jadwalStatusColor(item),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (jadwalShouldShowWarning(item))
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                LucideIcons.clock,
                                size: 12,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          Text(
                            jadwalStatusText(item),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: jadwalShouldShowWarning(item)
                                  ? const Color(0xFFFF6B6B)
                                  : jadwalStatusColor(item),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom action — hide for completed / canceled / pelaporan
            if (item.status != 'completed' &&
                item.status != 'canceled' &&
                item.status != 'pelaporan')
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.eye,
                            size: 16,
                            color: const Color(0xFF5B9FD8),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B9FD8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
