/// Indonesian date formatting without intl locale initialization.
class DateFormatter {
  const DateFormatter._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// `DateTime(2026, 1, 12)` → `"12 Jan 2026"`
  static String format(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// Grouping label for transaction lists (DESIGN.md §5.6).
  static String groupLabel(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final thatDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(thatDay).inDays;

    return switch (diff) {
      0 => 'Hari ini',
      1 => 'Kemarin',
      _ => format(date),
    };
  }
}
