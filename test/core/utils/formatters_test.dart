import 'package:flutter_test/flutter_test.dart';
import 'package:scan_wallet/core/utils/currency_formatter.dart';
import 'package:scan_wallet/core/utils/date_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats whole amounts with dot grouping', () {
      expect(CurrencyFormatter.format(125000), 'Rp 125.000');
      expect(CurrencyFormatter.format(0), 'Rp 0');
    });

    test('formats decimals with comma', () {
      expect(CurrencyFormatter.format(50000.5), 'Rp 50.000,50');
    });

    test('formats negatives with leading minus', () {
      expect(CurrencyFormatter.format(-42000), '-Rp 42.000');
    });

    test('parses formatted strings back to double', () {
      expect(CurrencyFormatter.parse('Rp 1.250.000'), 1250000);
      expect(CurrencyFormatter.parse('5000'), 5000);
      expect(CurrencyFormatter.parse('Rp 50.000,50'), 50000.5);
    });
  });

  group('DateFormatter', () {
    test('formats Indonesian dates', () {
      expect(DateFormatter.format(DateTime(2026, 1, 12)), '12 Jan 2026');
      expect(DateFormatter.format(DateTime(2026, 12, 31)), '31 Des 2026');
    });

    test('groups today and yesterday', () {
      final now = DateTime(2026, 5, 12);
      expect(
        DateFormatter.groupLabel(DateTime(2026, 5, 12), now: now),
        'Hari ini',
      );
      expect(
        DateFormatter.groupLabel(DateTime(2026, 5, 11), now: now),
        'Kemarin',
      );
      expect(
        DateFormatter.groupLabel(DateTime(2026, 5, 1), now: now),
        '1 Mei 2026',
      );
    });
  });
}
