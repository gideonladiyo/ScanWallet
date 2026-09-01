import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scan_wallet/core/error/exceptions.dart';
import 'package:scan_wallet/core/error/failures.dart';
import 'package:scan_wallet/core/network/network_info.dart';
import 'package:scan_wallet/core/utils/result.dart';
import 'package:scan_wallet/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:scan_wallet/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:scan_wallet/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:scan_wallet/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  late FakeRemote remote;
  late FakeLocal local;
  late FakeNetwork network;
  late TransactionRepositoryImpl repository;

  setUp(() {
    remote = FakeRemote();
    local = FakeLocal();
    network = FakeNetwork(true);
    repository = TransactionRepositoryImpl(remote, local, network);
  });

  test('queues immediately when no network interface is available', () async {
    network.connected = false;

    final result = await repository.createTransaction(transaction());

    expect(result, isA<Success<TransactionEntity>>());
    expect(
      (result as Success<TransactionEntity>).data.syncStatus,
      SyncStatus.pendingSync,
    );
    expect(local.queue, hasLength(1));
    expect(remote.verifyCalls, 0);
    expect(remote.insertCalls, 0);
  });

  test('checks Supabase reachability before inserting online', () async {
    final result = await repository.createTransaction(transaction());

    expect(result, isA<Success<TransactionEntity>>());
    expect(
      (result as Success<TransactionEntity>).data.syncStatus,
      SyncStatus.synced,
    );
    expect(remote.verifyCalls, 1);
    expect(remote.insertCalls, 1);
    expect(local.queue, isEmpty);
  });

  test('queues when the interface is up but Supabase is unreachable', () async {
    remote.verifyError = const SocketException('offline');

    final result = await repository.createTransaction(transaction());

    expect(result, isA<Success<TransactionEntity>>());
    expect(
      (result as Success<TransactionEntity>).data.syncStatus,
      SyncStatus.pendingSync,
    );
    expect(local.queue, hasLength(1));
    expect(remote.insertCalls, 0);
  });

  test(
    'queues when upload loses the network after reachability succeeds',
    () async {
      remote.insertError = const SocketException('connection dropped');

      final result = await repository.createTransaction(transaction());

      expect(result, isA<Success<TransactionEntity>>());
      expect(
        (result as Success<TransactionEntity>).data.syncStatus,
        SyncStatus.pendingSync,
      );
      expect(local.queue, hasLength(1));
    },
  );

  test(
    'surfaces server errors instead of falsely reporting offline success',
    () async {
      remote.verifyError = const ServerException('RLS denied');

      final result = await repository.createTransaction(transaction());

      expect(result, isA<Failure<TransactionEntity>>());
      expect(
        (result as Failure<TransactionEntity>).failure,
        isA<ServerFailure>(),
      );
      expect(local.queue, isEmpty);
    },
  );

  test('retains queue when sync reachability check fails', () async {
    local.queue.add(transaction(id: 'local-1'));
    remote.verifyError = const SocketException('offline');

    final result = await repository.syncPending();

    expect(result, isA<Failure<int>>());
    expect((result as Failure<int>).failure, isA<NetworkFailure>());
    expect(local.queue, hasLength(1));
  });
}

TransactionEntity transaction({String id = ''}) {
  final now = DateTime(2026, 1, 1);
  return TransactionEntity(
    id: id,
    userId: 'user-1',
    accountId: 'account-1',
    categoryId: 'category-1',
    type: TransactionType.expense,
    amount: 12500,
    date: now,
    syncStatus: SyncStatus.pendingSync,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeNetwork implements NetworkInfo {
  FakeNetwork(this.connected);

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class FakeLocal implements TransactionLocalDatasource {
  final queue = <TransactionEntity>[];
  final cache = <TransactionEntity>[];

  @override
  Future<List<TransactionEntity>> loadQueue() async => List.of(queue);

  @override
  Future<void> saveQueue(List<TransactionEntity> transactions) async {
    queue
      ..clear()
      ..addAll(transactions);
  }

  @override
  Future<List<TransactionEntity>> loadCache() async => List.of(cache);

  @override
  Future<void> saveCache(List<TransactionEntity> transactions) async {
    cache
      ..clear()
      ..addAll(transactions);
  }
}

class FakeRemote implements TransactionRemoteDatasource {
  int verifyCalls = 0;
  int insertCalls = 0;
  Object? verifyError;
  Object? insertError;

  @override
  Future<void> verifyReachability() async {
    verifyCalls++;
    if (verifyError != null) throw verifyError!;
  }

  @override
  Future<TransactionEntity> insert(TransactionEntity value) async {
    insertCalls++;
    if (insertError != null) throw insertError!;
    return value.copyWith(syncStatus: SyncStatus.synced);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async => const [];

  @override
  Future<TransactionEntity> update(TransactionEntity value) async => value;

  @override
  Future<void> delete(String id) async {}
}
