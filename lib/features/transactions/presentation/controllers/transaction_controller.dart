import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/utils/result.dart';
import '../../transactions_providers.dart';
import '../../domain/entities/transaction_entity.dart';

/// Transaction list + CRUD + offline sync state (TASKS.md 5C.1).
class TransactionController extends AsyncNotifier<List<TransactionEntity>> {
  static const Duration _retryInterval = Duration(seconds: 45);

  Timer? _retryTimer;
  bool _foreground = true;
  bool _syncInProgress = false;

  @override
  FutureOr<List<TransactionEntity>> build() async {
    ref.watch(authStateChangesProvider);
    _startRetryTimer();
    // Drain the offline queue whenever connectivity returns (PRD §6.2).
    ref.listen(connectivityStreamProvider, (_, next) {
      final results = next.value;
      if (results != null && !results.contains(ConnectivityResult.none)) {
        unawaited(syncPending());
      }
    });
    final result = await ref.watch(getTransactionsUsecaseProvider).call();
    return result.fold(
      (failure) => throw failure,
      (transactions) => transactions,
    );
  }

  Future<Result<TransactionEntity>> create(
    TransactionEntity transaction,
  ) async {
    final result = await ref
        .read(createTransactionUsecaseProvider)
        .call(transaction);
    return result.fold((failure) => Failure(failure), (created) {
      ref.invalidateSelf();
      if (created.syncStatus == SyncStatus.synced) {
        unawaited(syncPending());
      }
      return Success(created);
    });
  }

  Future<Result<TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    final result = await ref
        .read(updateTransactionUsecaseProvider)
        .call(transaction);
    return result.fold((failure) => Failure(failure), (updated) {
      ref.invalidateSelf();
      if (updated.syncStatus == SyncStatus.synced) {
        unawaited(syncPending());
      }
      return Success(updated);
    });
  }

  Future<Result<void>> delete(String id) async {
    final result = await ref.read(deleteTransactionUsecaseProvider).call(id);
    return result.fold((failure) => Failure(failure), (_) {
      ref.invalidateSelf();
      return const Success(null);
    });
  }

  Future<Result<int>> syncPending() async {
    if (_syncInProgress) return const Success(0);
    _syncInProgress = true;
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final result = await repository.syncPending();
      result.fold((_) => null, (count) {
        if (count > 0) ref.invalidateSelf();
      });
      return result;
    } finally {
      _syncInProgress = false;
    }
  }

  void setForeground(bool foreground) {
    _foreground = foreground;
    if (foreground) unawaited(syncPending());
  }

  void _startRetryTimer() {
    if (_retryTimer != null) return;
    final timer = Timer.periodic(_retryInterval, (_) {
      final hasPending = state.valueOrNull?.any(
        (transaction) => transaction.syncStatus == SyncStatus.pendingSync,
      );
      if (_foreground && (hasPending ?? false)) {
        unawaited(syncPending());
      }
    });
    _retryTimer = timer;
    ref.onDispose(() {
      timer.cancel();
      if (identical(_retryTimer, timer)) _retryTimer = null;
    });
  }
}

final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, List<TransactionEntity>>(
      TransactionController.new,
    );
