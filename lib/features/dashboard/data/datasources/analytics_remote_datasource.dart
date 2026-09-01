import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/analytics_summary_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// Dashboard aggregate queries (PLANNING.md §5.1). All reads are plain
/// Postgrest selects — writes to balances happen only via DB triggers.
class AnalyticsRemoteDatasource {
  AnalyticsRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<AnalyticsSummaryEntity> getSummary(
    DateTime start,
    DateTime end,
  ) async {
    final userId = _client.auth.currentUser!.id;
    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);

    final accountRows = await _client.from('accounts').select('balance');
    final totalBalance = (accountRows as List).fold<double>(
      0,
      (sum, row) => sum + ((row['balance'] as num?) ?? 0).toDouble(),
    );

    final txRows = await _client
        .from('transactions')
        .select('type, amount, category_id, categories(name, color)')
        .gte('date', startStr)
        .lte('date', endStr)
        .eq('user_id', userId);

    var totalIncome = 0.0;
    var totalExpense = 0.0;
    final breakdown =
        <String, ({String name, String? color, double total, int count})>{};

    for (final row in txRows as List) {
      final amount = ((row['amount'] as num?) ?? 0).toDouble();
      final type = TransactionType.fromWire(row['type'] as String);
      if (type == TransactionType.income) {
        totalIncome += amount;
        continue;
      }
      totalExpense += amount;
      final category = row['categories'] as Map<String, dynamic>?;
      final key = row['category_id'] as String;
      final name = category?['name'] as String? ?? 'Lainnya';
      final color = category?['color'] as String?;
      final existing = breakdown[key];
      breakdown[key] = (
        name: name,
        color: color,
        total: (existing?.total ?? 0) + amount,
        count: (existing?.count ?? 0) + 1,
      );
    }

    final slices =
        breakdown.entries
            .map(
              (e) => CategoryBreakdownEntity(
                categoryId: e.key,
                name: e.value.name,
                color: e.value.color,
                totalAmount: e.value.total,
                transactionCount: e.value.count,
              ),
            )
            .toList()
          ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return AnalyticsSummaryEntity(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      periodStart: start,
      periodEnd: end,
      breakdown: slices,
    );
  }
}

final analyticsRemoteDatasourceProvider = Provider<AnalyticsRemoteDatasource>(
  (ref) => AnalyticsRemoteDatasource(ref.watch(supabaseClientProvider)),
);
