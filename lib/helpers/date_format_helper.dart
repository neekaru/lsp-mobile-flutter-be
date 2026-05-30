// ============================================================================
// Date Format Helper
// ============================================================================
// Helper untuk formatting tanggal ke format Indonesia

import 'package:intl/intl.dart';

class DateFormatHelper {
  /// Format tanggal ke format Indonesia (dd MMM yyyy)
  /// Input: "2026-05-30" atau "2026-05-30 10:30:00"
  /// Output: "30 Mei 2026"
  static String formatToIndonesian(String dateString) {
    try {
      // Parse string ke DateTime
      DateTime date = DateTime.parse(dateString);
      
      // Format ke Indonesia
      final formatter = DateFormat('dd MMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      // Jika gagal parse, return string asli
      return dateString;
    }
  }

  /// Format tanggal ke format pendek (dd/MM/yyyy)
  /// Input: "2026-05-30"
  /// Output: "30/05/2026"
  static String formatToShort(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format tanggal ke format lengkap Indonesia
  /// Input: "2026-05-30"
  /// Output: "Jumat, 30 Mei 2026"
  static String formatToLong(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Hitung selisih hari dari sekarang
  /// Input: "2026-06-15"
  /// Output: 16 (jika hari ini 30 Mei 2026)
  static int daysFromNow(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      return date.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Format relative time (berapa hari lagi / berapa hari yang lalu)
  /// Input: "2026-06-15"
  /// Output: "16 hari lagi" atau "5 hari yang lalu"
  static String formatRelative(String dateString) {
    try {
      int days = daysFromNow(dateString);
      
      if (days == 0) {
        return 'Hari ini';
      } else if (days == 1) {
        return 'Besok';
      } else if (days == -1) {
        return 'Kemarin';
      } else if (days > 0) {
        return '$days hari lagi';
      } else {
        return '${days.abs()} hari yang lalu';
      }
    } catch (e) {
      return dateString;
    }
  }

  /// Cek apakah tanggal sudah lewat
  static bool isPast(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Cek apakah tanggal adalah hari ini
  static bool isToday(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (e) {
      return false;
    }
  }
}
