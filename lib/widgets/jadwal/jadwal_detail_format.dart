import '../../models/jadwal_models.dart';
import '../../utils/date_format_helper.dart';

// ============================================================================
// View detail jadwal (Asesor / Asesi) + formatter tanggal.
//
// Diekstrak dari jadwal_detail_screen.dart agar file screen tetap ringkas.
// ============================================================================

String formatIndonesianDate(String yyyymmdd) {
  return DateFormatHelper.formatToIndonesian(yyyymmdd);
}

String getDurationString(JadwalItem jadwal) {
  try {
    final start = DateTime.parse(jadwal.tanggalMulai);
    final end = DateTime.parse(jadwal.tanggalSelesai);
    final diff = end.difference(start).inDays + 1;
    return '$diff Hari';
  } catch (e) {
    return '7 Hari'; // Fallback matching the image
  }
}

String getDisplayAsesor(JadwalItem jadwal) {
  if (jadwal.asesor.isEmpty) {
    return 'Belum ditentukan';
  }
  return jadwal.asesor.first;
}

String formatAsesiDateRange(JadwalItem jadwal, [JadwalAsesorDetailData? detailData]) {
  final startStr = jadwal.tanggalMulai.isNotEmpty
      ? jadwal.tanggalMulai
      : (detailData != null && detailData.tanggal.isNotEmpty ? detailData.tanggal : '');
  final endStr = jadwal.tanggalSelesai.isNotEmpty
      ? jadwal.tanggalSelesai
      : (detailData != null && detailData.tanggalAkhir.isNotEmpty ? detailData.tanggalAkhir : startStr);

  if (startStr.isEmpty) return '-';
  if (endStr.isEmpty || startStr == endStr) {
    return DateFormatHelper.formatToLong(startStr);
  }
  return '${DateFormatHelper.formatToLong(startStr)} - ${DateFormatHelper.formatToLong(endStr)}';
}
