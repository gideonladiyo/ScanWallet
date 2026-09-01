import '../../../../core/utils/result.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Result<List<TransactionEntity>>> getTransactions();
  Future<Result<TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );
  Future<Result<TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );
  Future<Result<void>> deleteTransaction(String id);

  /// Drains the offline queue. Returns the number of synced items.
  Future<Result<int>> syncPending();
}
