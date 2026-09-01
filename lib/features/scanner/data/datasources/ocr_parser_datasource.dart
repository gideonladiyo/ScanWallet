import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/scan_result_entity.dart';

/// Per-format regex strategy (PLANNING.md §4.1). Tried in order until an
/// identifier keyword matches the raw OCR text.
class ReceiptFormat {
  const ReceiptFormat({
    required this.source,
    required this.identifiers,
    this.totalLineKeywords = const [],
    this.merchantKeywords = const [],
    this.merchantIsFirstLine = false,
    this.incomeKeywords =
        r'diterima|terima|masuk|top.?up|isi.?saldo|credit|refund',
    this.expenseKeywords =
        r'berhasil|terkirim|transfer|kirim|bayar|pembayaran|debit|keluar',
    this.defaultType = TransactionType.expense,
  });

  final String source;
  final List<RegExp> identifiers;
  final List<String> totalLineKeywords;
  final List<String> merchantKeywords;
  final bool merchantIsFirstLine;
  final String incomeKeywords;
  final String expenseKeywords;
  final TransactionType defaultType;
}

/// Regex-based OCR text parser (PLANNING.md §4). Pure Dart — unit tested.
class OcrParserDatasource {
  static const List<String> _months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'mei',
    'jun',
    'jul',
    'agu',
    'aug',
    'sep',
    'okt',
    'oct',
    'nov',
    'des',
    'dec',
  ];

  static final List<ReceiptFormat> _formats = [
    ReceiptFormat(
      source: 'gopay',
      identifiers: [RegExp(r'gopay', caseSensitive: false)],
      merchantKeywords: ['ke', 'untuk'],
    ),
    ReceiptFormat(
      source: 'shopeepay',
      identifiers: [RegExp(r'shopee\s*pay', caseSensitive: false)],
      merchantKeywords: ['pembayaran ke', 'ke'],
    ),
    ReceiptFormat(
      source: 'dana',
      identifiers: [RegExp(r'\bdana\b', caseSensitive: false)],
      merchantKeywords: ['kepada', 'penerima'],
    ),
    ReceiptFormat(
      source: 'qris',
      identifiers: [RegExp(r'qris', caseSensitive: false)],
      merchantKeywords: ['merchant', 'nama merchant'],
    ),
    ReceiptFormat(
      source: 'mobile_banking',
      identifiers: [
        RegExp(
          r'm[- ]?banking|mobile banking|bca|mandiri|bni|bri',
          caseSensitive: false,
        ),
      ],
      merchantKeywords: ['keterangan', 'berita', 'kepada'],
      incomeKeywords: r'credit|masuk|transfer masuk|diterima',
      expenseKeywords: r'transfer|bayar|debit|keluar',
    ),
    ReceiptFormat(
      source: 'physical_receipt',
      identifiers: [
        RegExp(r'\bstruk\b|kasir|invoice', caseSensitive: false),
        RegExp(r'\btotal\b', caseSensitive: false),
      ],
      totalLineKeywords: ['grand total', 'total'],
      merchantIsFirstLine: true,
    ),
  ];

  final RegExp _amountPattern = RegExp(
    r'(?:rp|idr)\s*([\d.,]+)',
    caseSensitive: false,
  );

  /// Parses raw OCR text. Returns a result with null fields when nothing
  /// matched — the Quick Edit Form stays open for manual input (PRD §6.4).
  ScanResultEntity parse(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return const ScanResultEntity();

    for (final format in _formats) {
      if (format.identifiers.any((re) => re.hasMatch(text))) {
        return ScanResultEntity(
          amount: _extractAmount(text, format),
          date: _extractDate(text),
          merchant: _extractMerchant(text, format),
          type: _extractType(text, format),
          source: format.source,
          rawText: rawText,
        );
      }
    }
    return ScanResultEntity(rawText: rawText);
  }

  /// Normalizes "Rp 1.250.000" / "IDR 50.000,50" → 1250000.0 / 50000.5
  /// (PLANNING.md §4.3).
  double? normalizeAmount(String raw) {
    var cleaned = raw.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (cleaned.isEmpty) return null;
    if (cleaned.contains(',')) {
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else {
      cleaned = cleaned.replaceAll('.', '');
    }
    final value = double.tryParse(cleaned);
    return (value == null || value <= 0) ? null : value;
  }

  double? _extractAmount(String text, ReceiptFormat format) {
    // Prefer an explicit TOTAL line when the format has one.
    for (final keyword in format.totalLineKeywords) {
      for (final line in text.split('\n')) {
        final lower = line.toLowerCase();
        if (lower.contains(keyword) && !lower.contains('subtotal')) {
          final match = _amountPattern.firstMatch(line);
          if (match != null) {
            final amount = normalizeAmount(match.group(1)!);
            if (amount != null) return amount;
          }
        }
      }
    }
    // Fallback: the largest Rp figure on the receipt is the grand total.
    double? max;
    for (final match in _amountPattern.allMatches(text)) {
      final value = normalizeAmount(match.group(1)!);
      if (value != null && (max == null || value > max)) max = value;
    }
    return max;
  }

  /// Indonesian date normalization (PLANNING.md §4.4).
  DateTime? _extractDate(String text) {
    // "12 Jan 2026" / "12 Januari 2026" / "12/Jan/2026"
    final named = RegExp(
      r'(\d{1,2})[\s/\-]([A-Za-z]{3,9})[\s/\-](\d{4})',
    ).firstMatch(text);
    if (named != null) {
      final month = _monthFromName(named.group(2)!);
      if (month != null) {
        return _validDate(
          int.parse(named.group(1)!),
          month,
          int.parse(named.group(3)!),
        );
      }
    }
    // "12/01/2026" or "12-01-2026"
    final numeric = RegExp(r'(\d{2})[/\-](\d{2})[/\-](\d{4})').firstMatch(text);
    if (numeric != null) {
      return _validDate(
        int.parse(numeric.group(1)!),
        int.parse(numeric.group(2)!),
        int.parse(numeric.group(3)!),
      );
    }
    // "2026-01-12" (also matches ISO timestamps)
    final iso = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
    if (iso != null) {
      return _validDate(
        int.parse(iso.group(3)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(1)!),
      );
    }
    return null;
  }

  int? _monthFromName(String name) {
    final prefix = name.substring(0, 3).toLowerCase();
    return _months.contains(prefix) ? _monthIndex(prefix) : null;
  }

  int _monthIndex(String prefix) {
    const order = [
      'jan',
      'feb',
      'mar',
      'apr',
      'mei',
      'jun',
      'jul',
      'agu',
      'aug',
      'sep',
      'okt',
      'oct',
      'nov',
      'des',
      'dec',
    ];
    final index = order.indexOf(prefix);
    if (index < 0) return 1;
    // Map the 15-entry alias list onto 1..12.
    return switch (prefix) {
      'jan' => 1,
      'feb' => 2,
      'mar' => 3,
      'apr' => 4,
      'mei' => 5,
      'jun' => 6,
      'jul' => 7,
      'agu' || 'aug' => 8,
      'sep' => 9,
      'okt' || 'oct' => 10,
      'nov' => 11,
      'des' || 'dec' => 12,
      _ => index + 1,
    };
  }

  DateTime? _validDate(int day, int month, int year) {
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 2000) {
      return null;
    }
    try {
      return DateTime(year, month, day);
    } on ArgumentError {
      return null;
    }
  }

  String? _extractMerchant(String text, ReceiptFormat format) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;

    if (format.merchantIsFirstLine) {
      return _cleanMerchant(lines.first);
    }
    for (final keyword in format.merchantKeywords) {
      for (var i = 0; i < lines.length; i++) {
        final lower = lines[i].toLowerCase();
        if (lower.startsWith(keyword)) {
          var candidate = lines[i].substring(keyword.length).trim();
          candidate = candidate.replaceFirst(RegExp(r'^[:.\-]\s*'), '');
          if (candidate.length < 2 && i + 1 < lines.length) {
            candidate = lines[i + 1];
          }
          if (candidate.length >= 2) return _cleanMerchant(candidate);
        }
      }
    }
    return null;
  }

  String _cleanMerchant(String value) {
    final cleaned = value.replaceAll(RegExp(r'[0-9.,]{4,}'), '').trim();
    final result = cleaned.isEmpty ? value.trim() : cleaned;
    return result.length > 40 ? result.substring(0, 40) : result;
  }

  TransactionType? _extractType(String text, ReceiptFormat format) {
    final income = RegExp(format.incomeKeywords, caseSensitive: false);
    final expense = RegExp(format.expenseKeywords, caseSensitive: false);
    if (income.hasMatch(text)) return TransactionType.income;
    if (expense.hasMatch(text)) return TransactionType.expense;
    return format.defaultType;
  }
}

final ocrParserDatasourceProvider = Provider<OcrParserDatasource>((ref) {
  return OcrParserDatasource();
});
