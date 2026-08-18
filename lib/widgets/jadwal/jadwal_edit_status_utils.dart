// ============================================================================
// Helper format tanggal & aturan transisi status jadwal (layar Edit Jadwal).
//
// Diekstrak dari jadwal_edit_screen.dart agar layar hanya berisi state +
// navigasi.
// ============================================================================

import 'package:material_ui/material_ui.dart';

String jadwalFormatIndonesianFullDate(String yyyymmdd) {
  try {
    final parts = yyyymmdd.split('-');
    if (parts.length != 3) return yyyymmdd;
    final year = parts[0];
    final monthIndex = int.parse(parts[1]);
    final day = int.parse(parts[2]).toString();

    final months = [
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
    final monthName = months[monthIndex - 1];
    return '$day $monthName $year';
  } catch (e) {
    return yyyymmdd;
  }
}

Color jadwalEditStatusColor(String status) {
  switch (status) {
    case 'draft':
    case 'waiting':
      return const Color(0xFFFBC02D);
    case 'completed':
      return const Color(0xFF4CAF50);
    case 'canceled':
      return const Color(0xFFE53935);
    case 'running':
      return const Color(0xFF2196F3);
    case 'pelaporan':
      return const Color(0xFFFF9800);
    default:
      return const Color(0xFF2C6C9C);
  }
}

String jadwalEditStatusLabel(String status) {
  switch (status) {
    case 'draft':
    case 'waiting':
      return 'Draft';
    case 'completed':
      return 'Completed';
    case 'canceled':
      return 'Canceled';
    case 'running':
      return 'Running';
    case 'pelaporan':
      return 'Pelaporan';
    default:
      return status;
  }
}

/// Menentukan rule transisi status untuk API update jadwal.
String jadwalEditStatusRule({
  required bool needsAcc,
  required String currentStatus,
  required String newStatus,
}) {
  String toCode(String s) {
    switch (s) {
      case 'draft':
      case 'waiting':
        return '0';
      case 'completed':
        return '1';
      case 'canceled':
        return '2';
      case 'running':
        return '3';
      case 'pelaporan':
        return '4';
      default:
        return '0';
    }
  }

  final from = toCode(currentStatus);
  final to = toCode(newStatus);

  if (from == '0' && to == '1') return 'draft_to_completed';
  if (from == '0' && to == '2') return 'draft_to_canceled';
  // ACC admin draft → running
  if (from == '0' && to == '3') {
    return needsAcc ? 'draft_acc_to_running' : 'draft_to_running';
  }
  if (from == '1' && to == '2') return 'completed_to_canceled';
  if (from == '1' && to == '3') return 'completed_to_running';
  if (from == '2' && to == '3') return 'canceled_to_running';
  if (from == '3' && to == '4') return 'running_to_pelaporan';
  if (from == '4' && to == '2') return 'pelaporan_to_canceled';
  if (from == '4' && to == '3') return 'pelaporan_to_running';
  if (from == '4' && to == '1') return 'pelaporan_to_completed';
  if (from == '4' && to == '0') return 'pelaporan_to_draft';
  if (from == '3' && to == '0') return 'running_to_draft';
  if (from == '1' && to == '0') return 'completed_to_draft';
  if (from == '2' && to == '0') return 'canceled_to_draft';
  if (from == '0' && to == '4') return 'draft_to_pelaporan';
  if (from == '1' && to == '4') return 'completed_to_pelaporan';
  if (from == '2' && to == '4') return 'canceled_to_pelaporan';

  // Rollbacks
  if (from == '2' && to == '1') return 'canceled_to_completed';
  if (from == '3' && to == '2') return 'running_to_canceled';
  if (from == '3' && to == '1') return 'running_to_completed';

  return '${currentStatus}_to_$newStatus';
}
