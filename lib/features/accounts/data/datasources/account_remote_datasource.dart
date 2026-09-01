import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/account_entity.dart';
import '../models/account_model.dart';

/// Supabase CRUD for the `accounts` table.
class AccountRemoteDatasource {
  AccountRemoteDatasource(this._client);

  final SupabaseClient _client;

  Future<List<AccountEntity>> getAccounts() async {
    final rows = await _client
        .from('accounts')
        .select()
        .order('created_at', ascending: true);
    return (rows as List).map((row) => AccountModel.fromJson(row)).toList();
  }

  Future<AccountEntity> createAccount(
    String name,
    AccountType accountType, {
    String? color,
  }) async {
    final row = await _client
        .from('accounts')
        .insert(
          AccountModel.toInsertJson(
            userId: _client.auth.currentUser!.id,
            name: name,
            accountType: accountType,
            color: color,
          ),
        )
        .select()
        .single();
    return AccountModel.fromJson(row);
  }

  Future<AccountEntity> updateAccount(AccountEntity account) async {
    final row = await _client
        .from('accounts')
        .update(AccountModel.toUpdateJson(account))
        .eq('id', account.id)
        .select()
        .single();
    return AccountModel.fromJson(row);
  }

  Future<void> deleteAccount(String id) async {
    await _client.from('accounts').delete().eq('id', id);
  }
}

final accountRemoteDatasourceProvider = Provider<AccountRemoteDatasource>((
  ref,
) {
  return AccountRemoteDatasource(ref.watch(supabaseClientProvider));
});
