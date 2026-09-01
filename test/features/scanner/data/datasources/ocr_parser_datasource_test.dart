import 'package:flutter_test/flutter_test.dart';
import 'package:scan_wallet/features/scanner/data/datasources/ocr_parser_datasource.dart';
import 'package:scan_wallet/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  final parser = OcrParserDatasource();

  group('OcrParserDatasource.parse', () {
    test('GoPay expense receipt', () {
      const text = '''
GoPay
Transfer berhasil
Rp 125.000
12 Jan 2026
Ke Kopi Kenangan
''';
      final result = parser.parse(text);

      expect(result.source, 'gopay');
      expect(result.amount, 125000);
      expect(result.type, TransactionType.expense);
      expect(result.date, DateTime(2026, 1, 12));
      expect(result.merchant, 'Kopi Kenangan');
    });

    test('DANA top-up (income)', () {
      const text = '''
DANA
Top up saldo diterima
Rp 50.000
12/01/2026
''';
      final result = parser.parse(text);

      expect(result.source, 'dana');
      expect(result.amount, 50000);
      expect(result.type, TransactionType.income);
      expect(result.date, DateTime(2026, 1, 12));
    });

    test('physical receipt uses TOTAL line and first line as merchant', () {
      const text = '''
Toko Maju Jaya
Jl. Merdeka No. 1
STRUK PEMBAYARAN
Ayam Geprek Rp 18.000
Es Teh Rp 7.000
Total Rp 25.500
12-01-2026
''';
      final result = parser.parse(text);

      expect(result.source, 'physical_receipt');
      expect(result.amount, 25500);
      expect(result.merchant, 'Toko Maju Jaya');
      expect(result.type, TransactionType.expense);
      expect(result.date, DateTime(2026, 1, 12));
    });

    test('QRIS payment defaults to expense', () {
      const text = '''
QRIS
Pembayaran QRIS
Rp 75.000
Merchant Kopi Sejuk
12 Jan 2026
''';
      final result = parser.parse(text);

      expect(result.source, 'qris');
      expect(result.amount, 75000);
      expect(result.type, TransactionType.expense);
    });

    test('unknown text returns all-null fields for manual input', () {
      const text = 'hello world nothing recognizable here';
      final result = parser.parse(text);

      expect(result.amount, isNull);
      expect(result.date, isNull);
      expect(result.merchant, isNull);
      expect(result.type, isNull);
      expect(result.source, isNull);
    });

    test('ISO date strings are recognized', () {
      const text = 'GoPay\nberhasil\nRp 10.000\n2026-01-12T14:30:00';
      final result = parser.parse(text);
      expect(result.date, DateTime(2026, 1, 12));
    });
  });

  group('OcrParserDatasource.normalizeAmount (PLANNING.md §4.3)', () {
    test('removes thousands dots', () {
      expect(parser.normalizeAmount('1.250.000'), 1250000);
    });

    test('converts comma decimals', () {
      expect(parser.normalizeAmount('50.000,50'), 50000.5);
    });

    test('plain digits pass through', () {
      expect(parser.normalizeAmount('7500'), 7500);
    });

    test('garbage returns null', () {
      expect(parser.normalizeAmount('Rp'), isNull);
      expect(parser.normalizeAmount('0'), isNull);
    });
  });
}
