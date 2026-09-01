import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';

/// Transaction direction. Mirrors the Postgres `transaction_type` enum
/// (PLANNING.md §1.1).
enum TransactionType {
  income,
  expense;

  String get wireName => name;

  static TransactionType fromWire(String value) {
    return value == 'income' ? TransactionType.income : TransactionType.expense;
  }
}

/// Offline sync state. Mirrors the Postgres `sync_status` enum.
enum SyncStatus {
  pendingSync,
  synced;

  String get wireName => name;

  static SyncStatus fromWire(String value) {
    return value == 'synced' ? SyncStatus.synced : SyncStatus.pendingSync;
  }
}

/// A single financial transaction (PLANNING.md §1.5).
@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required String id,
    required String userId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? note,
    String? merchant,
    String? source,
    @Default(SyncStatus.pendingSync) SyncStatus syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionEntity;
}
