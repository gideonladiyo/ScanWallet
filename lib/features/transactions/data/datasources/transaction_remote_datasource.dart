import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

/// Supabase CRUD for the `transactions` table.
class TransactionRemoteDatasource {
  TransactionRemoteDatasource(this._client);

  final SupabaseClient _client;

  /// Confirms that the active interface can actually reach Supabase. This is
  /// intentionally a tiny authenticated query and not another OS-level check.
  Future<void> verifyReachability() async {
    final userId = _requireUserId();
    await _client
        .from('transactions')
        .select('id')
        .eq('user_id', userId)
        .limit(1)
        .timeout(const Duration(seconds: 4));
  }

  /// ponytail: full fetch (capped) instead of keyset pagination; switch to
  /// range queries if lists grow past a few hundred entries.
  Future<List<TransactionEntity>> getTransactions() async {
    final rows = await _client
        .from('transactions')
        .select()
        .order('date', ascending: false)
        .order('created_at', ascending: false)
        .limit(500);
    return (rows as List).map((row) => TransactionModel.fromJson(row)).toList();
  }

  Future<TransactionEntity> insert(TransactionEntity transaction) async {
    final userId = _requireUserId();
    final row = await _client
        .from('transactions')
        .insert(TransactionModel.toInsertJson(transaction, userId))
        .select()
        .single();
    return TransactionModel.fromJson(row);
  }

  Future<TransactionEntity> update(TransactionEntity transaction) async {
    final row = await _client
        .from('transactions')
        .update(TransactionModel.toUpdateJson(transaction))
        .eq('id', transaction.id)
        .select()
        .single();
    return TransactionModel.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthSessionException(
        'Sesi login berakhir. Silakan masuk kembali.',
      );
    }
    return userId;
  }
}

final transactionRemoteDatasourceProvider =
    Provider<TransactionRemoteDatasource>((ref) {
      return TransactionRemoteDatasource(ref.watch(supabaseClientProvider));
    });
