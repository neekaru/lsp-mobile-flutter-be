// ============================================================================
// Helper format & status jadwal.
//
// Diekstrak dari jadwal_role_cards.dart agar tiap kartu per role mudah
// dipelihara.
// ============================================================================

import 'package:material_ui/material_ui.dart';

import 'package:intl/intl.dart';
import '../../utils/date_format_helper.dart';
import '../../models/jadwal_models.dart';

String jadwalFormatIndonesianDate(String yyyymmdd) {
  final dt = DateFormatHelper.parseDate(yyyymmdd);
  if (dt == null) return yyyymmdd;
  try {
    return DateFormat('d MMM yyyy', 'id_ID').format(dt);
  } catch (_) {
    return DateFormat('d MMM yyyy').format(dt);
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
  return DateFormatHelper.formatToLong(yyyymmdd);
}

/// Format rentang tanggal asesmen:
/// Jika tanggal mulai dan akhir sama atau akhir kosong: "12 Jan 2026"
/// Jika berbeda: "12 Jan 2026 sd 15 Jan 2026"
String jadwalFormatDateRange(String tanggalMulai, String tanggalSelesai) {
  final start = tanggalMulai.split(' ').first.trim();
  final end = tanggalSelesai.split(' ').first.trim();

  if (start.isEmpty && end.isEmpty) return '-';
  if (start.isEmpty) return jadwalFormatIndonesianDate(end);
  if (end.isEmpty || end == start) {
    return jadwalFormatIndonesianDate(start);
  }

  final formattedStart = jadwalFormatIndonesianDate(start);
  final formattedEnd = jadwalFormatIndonesianDate(end);
  if (formattedStart == formattedEnd) {
    return formattedStart;
  }
  return '$formattedStart sd $formattedEnd';
}

DateTime? _parseJadwalDate(String dateStr) {
  return DateFormatHelper.parseDate(dateStr);
}

/// Menghitung teks badge kartu jadwal secara dinamis:
/// - 'Sekarang'
/// - 'Besok'
/// - 'X Hari Lagi'
/// - 'Lewat X Hari' (dihitung dari tanggal asesmen terakhir)
String jadwalBadgeText(JadwalItem item) {
  if (item.isDraft) {
    return 'Draft';
  } else if (item.status == 'canceled') {
    return 'Batal';
  } else if (item.status == 'completed') {
    return 'Selesai';
  }

  // Jika running atau pelaporan, hitung dari tanggal asesmen
  if (item.isRunning || item.status == 'pelaporan' || item.status == 'running') {
    final startDt = _parseJadwalDate(item.tanggalMulai);
    final endDt = _parseJadwalDate(item.tanggalSelesai) ?? startDt;

    if (startDt != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime(startDt.year, startDt.month, startDt.day);
      final end = endDt != null ? DateTime(endDt.year, endDt.month, endDt.day) : start;

      if (today.isBefore(start)) {
        final diffDays = start.difference(today).inDays;
        if (diffDays == 1) {
          return 'Besok';
        }
        return '$diffDays Hari Lagi';
      } else if (today.isAfter(end)) {
        final daysLate = today.difference(end).inDays;
        if (daysLate >= 1) {
          return 'Lewat $daysLate Hari';
        }
        return 'Sekarang';
      } else {
        return 'Sekarang';
      }
    }

    // Fallback jika parsing tanggal gagal
    if (item.daysLate != null && item.daysLate! > 0) {
      return 'Lewat ${item.daysLate} Hari';
    }
    if (item.sisaHari == 0) {
      return 'Sekarang';
    }
    if (item.sisaHari == 1) {
      return 'Besok';
    }
    if (item.sisaHari > 1) {
      return '${item.sisaHari} Hari Lagi';
    }
    if (item.status == 'pelaporan') {
      return 'Pelaporan';
    }
    return 'Berjalan';
  }

  return item.displayStatusLabel;
}

Color jadwalBadgeBg(JadwalItem item) {
  if (item.isDraft) {
    return const Color(0xFFFEF3C7);
  } else if (item.status == 'canceled') {
    return const Color(0xFFFEE2E2);
  } else if (item.status == 'completed') {
    return const Color(0xFFD1FAE5);
  }

  final text = jadwalBadgeText(item);
  if (text.startsWith('Lewat')) {
    return const Color(0xFFFEE2E2); // Merah muda
  } else if (text == 'Sekarang') {
    return const Color(0xFFDBEAFE); // Biru muda
  } else if (text == 'Besok' || text.endsWith('Hari Lagi')) {
    return const Color(0xFFFEF3C7); // Kuning/amber muda
  }

  if (item.status == 'pelaporan') {
    return const Color(0xFFF3E8FF);
  }
  return const Color(0xFFDBEAFE);
}

Color jadwalBadgeTextColor(JadwalItem item) {
  if (item.isDraft) {
    return const Color(0xFFD97706);
  } else if (item.status == 'canceled') {
    return const Color(0xFFDC2626);
  } else if (item.status == 'completed') {
    return const Color(0xFF059669);
  }

  final text = jadwalBadgeText(item);
  if (text.startsWith('Lewat')) {
    return const Color(0xFFDC2626); // Merah
  } else if (text == 'Sekarang') {
    return const Color(0xFF2563EB); // Biru
  } else if (text == 'Besok' || text.endsWith('Hari Lagi')) {
    return const Color(0xFFD97706); // Amber
  }

  if (item.status == 'pelaporan') {
    return const Color(0xFF7C3AED);
  }
  return const Color(0xFF2563EB);
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
    case 'pelaporan':
      return jadwalBadgeText(item);
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
  // Tampilkan warning jika terlambat
  final text = jadwalBadgeText(item);
  if (text.startsWith('Lewat')) {
    return true;
  }
  if (item.status == 'running') {
    if (item.daysLate != null && item.daysLate! > 0) {
      return true; // Terlambat
    }
  }
  return false;
}
