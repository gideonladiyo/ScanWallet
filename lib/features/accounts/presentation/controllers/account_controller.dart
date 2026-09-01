import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/utils/result.dart';
import '../../accounts_providers.dart';
import '../../domain/entities/account_entity.dart';

/// Account list + CRUD state (TASKS.md 3C.1).
class AccountController extends AsyncNotifier<List<AccountEntity>> {
  @override
  FutureOr<List<AccountEntity>> build() async {
    // Rebuild on auth changes so a different user never sees stale data.
    ref.watch(authStateChangesProvider);
    final result = await ref.watch(getAccountsUsecaseProvider).call();
    return result.fold((failure) => throw failure, (accounts) => accounts);
  }

  Future<Result<AccountEntity>> create(
    String name,
    AccountType accountType, {
    String? color,
  }) async {
    final result = await ref
        .read(createAccountUsecaseProvider)
        .call(name, accountType, color: color);
    return result.fold((failure) => Failure(failure), (account) {
      ref.invalidateSelf();
      return Success(account);
    });
  }

  Future<Result<AccountEntity>> updateAccount(AccountEntity account) async {
    final result = await ref.read(updateAccountUsecaseProvider).call(account);
    return result.fold((failure) => Failure(failure), (account) {
      ref.invalidateSelf();
      return Success(account);
    });
  }

  Future<Result<void>> delete(String id) async {
    final result = await ref.read(deleteAccountUsecaseProvider).call(id);
    return result.fold((failure) => Failure(failure), (_) {
      ref.invalidateSelf();
      return const Success(null);
    });
  }
}

final accountControllerProvider =
    AsyncNotifierProvider<AccountController, List<AccountEntity>>(
      AccountController.new,
    );
