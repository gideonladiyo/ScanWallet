import 'package:flutter_test/flutter_test.dart';
import 'package:scan_wallet/features/transactions/data/models/transaction_model.dart';
import 'package:scan_wallet/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  test('TransactionModel round-trips through JSON', () {
    final entity = TransactionEntity(
      id: 'tx-1',
      userId: 'user-1',
      accountId: 'acc-1',
      categoryId: 'cat-1',
      type: TransactionType.income,
      amount: 150000.5,
      date: DateTime(2026, 1, 12),
      note: 'Gaji Januari',
      merchant: 'PT Maju',
      source: 'manual',
      syncStatus: SyncStatus.synced,
      createdAt: DateTime(2026, 1, 12, 8),
      updatedAt: DateTime(2026, 1, 12, 8, 30),
    );

    final restored = TransactionModel.fromJson(
      Map<String, dynamic>.from(TransactionModel.toJson(entity)),
    );

    expect(restored, entity);
  });

  test('insert payload carries no id and marks synced', () {
    final entity = TransactionEntity(
      id: '',
      userId: 'user-1',
      accountId: 'acc-1',
      categoryId: 'cat-1',
      type: TransactionType.expense,
      amount: 25000,
      date: DateTime(2026, 1, 12),
      syncStatus: SyncStatus.pendingSync,
      createdAt: DateTime(2026, 1, 12),
      updatedAt: DateTime(2026, 1, 12),
    );

    final payload = TransactionModel.toInsertJson(entity, 'user-1');

    expect(payload.containsKey('id'), isFalse);
    expect(payload['sync_status'], 'synced');
    expect(payload['user_id'], 'user-1');
    expect(payload['date'], '2026-01-12');
  });
}
