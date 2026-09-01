import '../../../../core/utils/result.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUsecase {
  const GetTransactionsUsecase(this._repository);

  final TransactionRepository _repository;

  Future<Result<List<TransactionEntity>>> call() {
    return _repository.getTransactions();
  }
}
