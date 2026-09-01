import '../../../../core/utils/result.dart';
import '../entities/account_entity.dart';
import '../repositories/account_repository.dart';

class GetAccountsUsecase {
  const GetAccountsUsecase(this._repository);

  final AccountRepository _repository;

  Future<Result<List<AccountEntity>>> call() {
    return _repository.getAccounts();
  }
}
