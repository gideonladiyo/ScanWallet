import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

/// Offline queue + read cache persisted in SharedPreferences
/// (PRD.md §6.2, PLANNING.md §6). Drift would be overkill for a flat queue.
class TransactionLocalDatasource {
  static const String _queueKey = 'scanwallet.pending_transactions';
  static const String _cacheKey = 'scanwallet.cached_transactions';

  Future<List<TransactionEntity>> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null) return const [];
    final rows = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return rows.map(TransactionModel.fromJson).toList();
  }

  Future<void> saveQueue(List<TransactionEntity> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _queueKey,
      jsonEncode(transactions.map(TransactionModel.toJson).toList()),
    );
  }

  Future<List<TransactionEntity>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return const [];
    final rows = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return rows.map(TransactionModel.fromJson).toList();
  }

  Future<void> saveCache(List<TransactionEntity> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(transactions.map(TransactionModel.toJson).toList()),
    );
  }
}
