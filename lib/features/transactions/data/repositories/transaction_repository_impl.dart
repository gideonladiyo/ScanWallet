import 'dart:developer';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';

/// Offline-first implementation (PLANNING.md §6):
/// - writes go to Supabase when online, otherwise into a local queue;
/// - reads hit Supabase and cache the result, falling back to cache offline;
/// - queued items drain automatically once connectivity returns.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._remote, this._local, this._networkInfo);

  final TransactionRemoteDatasource _remote;
  final TransactionLocalDatasource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<TransactionEntity>>> getTransactions() async {
    final queued = await _local.loadQueue();
    try {
      final remote = await _remote.getTransactions();
      await _local.saveCache(remote);
      return Success(_merge(queued, remote));
    } catch (e) {
      final failure = mapExceptionToFailure(e);
      if (failure is NetworkFailure) {
        final cached = await _local.loadCache();
        return Success(_merge(queued, cached));
      }
      return Failure(failure);
    }
  }

  @override
  Future<Result<TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  ) async {
    if (!await _networkInfo.isConnected) {
      return _queueTransaction(
        transaction,
        reason: 'Tidak ada interface jaringan aktif.',
      );
    }
    try {
      await _remote.verifyReachability();
      return Success(await _remote.insert(transaction));
    } catch (e, stackTrace) {
      final failure = mapExceptionToFailure(e);
      if (failure is NetworkFailure) {
        return _queueTransaction(
          transaction,
          reason: 'Supabase tidak dapat dijangkau.',
          error: e,
          stackTrace: stackTrace,
        );
      }
      return Failure(failure);
    }
  }

  @override
  Future<Result<TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    // Locally queued item: edit in place, keep waiting for sync.
    if (transaction.id.startsWith('local-')) {
      final queue = await _local.loadQueue();
      final updated = List<TransactionEntity>.from(queue);
      final index = updated.indexWhere((t) => t.id == transaction.id);
      if (index >= 0) {
        updated[index] = transaction.copyWith(updatedAt: DateTime.now());
        await _local.saveQueue(updated);
      }
      return Success(transaction);
    }
    try {
      return Success(await _remote.update(transaction));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    if (id.startsWith('local-')) {
      final queue = await _local.loadQueue();
      await _local.saveQueue(queue.where((t) => t.id != id).toList());
      return const Success(null);
    }
    try {
      await _remote.delete(id);
      return const Success(null);
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<int>> syncPending() async {
    var synced = 0;
    final queue = await _local.loadQueue();
    if (queue.isEmpty) return const Success(0);
    if (!await _networkInfo.isConnected) return Failure(NetworkFailure());

    try {
      await _remote.verifyReachability();
    } catch (e, stackTrace) {
      final failure = mapExceptionToFailure(e);
      log(
        'Sinkronisasi antrean gagal saat reachability check.',
        name: 'ScanWallet.TransactionSync',
        error: e,
        stackTrace: stackTrace,
      );
      return Failure(failure);
    }

    for (final transaction in queue) {
      try {
        await _remote.insert(transaction);
        synced++;
      } catch (e, stackTrace) {
        // Stop at first failure; remaining items stay queued for next attempt.
        if (synced == 0) {
          final failure = mapExceptionToFailure(e);
          log(
            'Sinkronisasi transaksi pending gagal.',
            name: 'ScanWallet.TransactionSync',
            error: e,
            stackTrace: stackTrace,
          );
          return Failure(failure);
        }
        break;
      }
    }
    if (synced > 0) {
      await _local.saveQueue(queue.skip(synced).toList());
    }
    return Success(synced);
  }

  void _logQueued(String reason, {Object? error, StackTrace? stackTrace}) {
    log(
      'Transaksi disimpan ke antrean offline: $reason',
      name: 'ScanWallet.TransactionSync',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<Result<TransactionEntity>> _queueTransaction(
    TransactionEntity transaction, {
    required String reason,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    _logQueued(reason, error: error, stackTrace: stackTrace);
    try {
      return Success(await _enqueue(transaction));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  Future<TransactionEntity> _enqueue(TransactionEntity transaction) async {
    final now = DateTime.now();
    final pending = transaction.copyWith(
      id: transaction.id.isEmpty
          ? 'local-${now.microsecondsSinceEpoch}'
          : transaction.id,
      userId: transaction.userId,
      syncStatus: SyncStatus.pendingSync,
      createdAt: now,
      updatedAt: now,
    );
    final queue = await _local.loadQueue();
    await _local.saveQueue([...queue, pending]);
    return pending;
  }

  List<TransactionEntity> _merge(
    List<TransactionEntity> queued,
    List<TransactionEntity> fetched,
  ) {
    if (queued.isEmpty) return fetched;
    final merged = [...queued, ...fetched];
    merged.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
    return merged;
  }
}
