import '../../../../core/utils/result.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionUsecase {
  const DeleteTransactionUsecase(this._repository);

  final TransactionRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteTransaction(id);
  }
}
