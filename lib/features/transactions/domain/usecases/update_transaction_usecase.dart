import '../../../../core/utils/result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUsecase {
  const UpdateTransactionUsecase(this._repository);

  final TransactionRepository _repository;

  Future<Result<TransactionEntity>> call(TransactionEntity transaction) {
    return _repository.updateTransaction(transaction);
  }
}
