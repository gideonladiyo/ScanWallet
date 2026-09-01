import '../../domain/entities/transaction_entity.dart';

/// Serialization for the `transactions` table (PLANNING.md §1.5).
class TransactionModel {
  const TransactionModel._();

  static TransactionEntity fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      categoryId: json['category_id'] as String,
      type: TransactionType.fromWire(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      merchant: json['merchant'] as String?,
      source: json['source'] as String?,
      syncStatus: SyncStatus.fromWire(
        json['sync_status'] as String? ?? 'synced',
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(TransactionEntity transaction) {
    return {
      'id': transaction.id,
      'user_id': transaction.userId,
      'account_id': transaction.accountId,
      'category_id': transaction.categoryId,
      'type': transaction.type.wireName,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String().substring(0, 10),
      if (transaction.note != null) 'note': transaction.note,
      if (transaction.merchant != null) 'merchant': transaction.merchant,
      if (transaction.source != null) 'source': transaction.source,
      'sync_status': transaction.syncStatus.wireName,
      'created_at': transaction.createdAt.toIso8601String(),
      'updated_at': transaction.updatedAt.toIso8601String(),
    };
  }

  /// Payload for remote inserts. The server generates id/timestamps.
  static Map<String, dynamic> toInsertJson(
    TransactionEntity transaction,
    String userId,
  ) {
    return {
      'user_id': userId,
      'account_id': transaction.accountId,
      'category_id': transaction.categoryId,
      'type': transaction.type.wireName,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String().substring(0, 10),
      if (transaction.note != null) 'note': transaction.note,
      if (transaction.merchant != null) 'merchant': transaction.merchant,
      if (transaction.source != null) 'source': transaction.source,
      'sync_status': 'synced',
    };
  }

  static Map<String, dynamic> toUpdateJson(TransactionEntity transaction) {
    return {
      'account_id': transaction.accountId,
      'category_id': transaction.categoryId,
      'type': transaction.type.wireName,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String().substring(0, 10),
      if (transaction.note != null) 'note': transaction.note,
      if (transaction.merchant != null) 'merchant': transaction.merchant,
      if (transaction.source != null) 'source': transaction.source,
    };
  }
}
