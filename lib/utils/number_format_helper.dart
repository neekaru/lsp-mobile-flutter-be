import 'package:intl/intl.dart';

/// Helper pemformatan angka menggunakan standard intl.
class NumberFormatHelper {
  static final NumberFormat _dotFormat = NumberFormat('#,###', 'id_ID');

  /// Format angka integer dengan titik pemisah ribuan (misal: 1000 -> "1.000")
  static String formatWithDots(int number) => _dotFormat.format(number);

  /// Format desimal dengan koma pemisah (misal: 82.8 -> "82,8")
  static String formatDecimalWithComma(double number, {int decimals = 1}) {
    return NumberFormat.decimalPatternDigits(
      locale: 'id_ID',
      decimalDigits: decimals,
    ).format(number);
  }

  /// Format persentase (misal: 0.828 -> "82,8%")
  static String formatPercentage(double value, {int decimals = 1}) {
    final fmt = NumberFormat.percentPattern('id_ID')
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return fmt.format(value);
  }
}
