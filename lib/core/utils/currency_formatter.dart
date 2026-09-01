/// Formats numeric amounts as Indonesian Rupiah, e.g. `Rp 125.000`.
/// Implemented without intl to avoid locale initialization side effects.
class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(double amount) {
    final negative = amount < 0;
    final abs = amount.abs();
    final whole = abs.truncate();
    final fraction = abs - whole;

    final grouped = _groupWithDots(whole.toString());
    var value = grouped;
    if (fraction > 0) {
      final cents = (fraction * 100).round().toString().padLeft(2, '0');
      value = '$grouped,$cents';
    }
    return '${negative ? '-' : ''}Rp $value';
  }

  /// Parses user/OCR input like "Rp 1.250.000" or "5000" into a double.
  /// Returns 0 when nothing numeric is found.
  static double parse(String raw) {
    var cleaned = raw.replaceAll(RegExp(r'[^0-9,.-]'), '');
    // Indonesian format: '.' thousands, ',' decimals.
    if (cleaned.contains(',')) {
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else {
      cleaned = cleaned.replaceAll('.', '');
    }
    return double.tryParse(cleaned) ?? 0;
  }

  static String _groupWithDots(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}
