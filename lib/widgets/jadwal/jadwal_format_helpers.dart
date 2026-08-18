// ============================================================================
// Helper format & status jadwal.
//
// Diekstrak dari jadwal_role_cards.dart agar tiap kartu per role mudah
// dipelihara.
// ============================================================================

import 'package:material_ui/material_ui.dart';

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
