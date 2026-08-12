// ============================================================================
// Number Format Helper
// ============================================================================
// Helper untuk formatting angka dengan separator

class NumberFormatHelper {
  /// Format angka dengan titik sebagai thousands separator
  /// 
  /// Example: 1000 -> "1.000", 1000000 -> "1.000.000"
  static String formatWithDots(int number) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toString().replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  /// Format angka dengan koma sebagai thousands separator
  /// 
  /// Example: 1000 -> "1,000", 1000000 -> "1,000,000"
  static String formatWithCommas(int number) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
  }

  /// Format double dengan koma sebagai decimal separator
  /// 
  /// Example: 82.8 -> "82,8"
  static String formatDecimalWithComma(double number, {int decimals = 1}) {
    return number.toStringAsFixed(decimals).replaceAll('.', ',');
  }

  /// Format persentase dengan koma sebagai decimal separator
  /// 
  /// Example: 0.828 -> "82,8%"
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals).replaceAll('.', ',')}%';
  }
}
