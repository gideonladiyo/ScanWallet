import '../../../../core/utils/result.dart';
import '../entities/account_entity.dart';
import '../repositories/account_repository.dart';

class UpdateAccountUsecase {
  const UpdateAccountUsecase(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountEntity>> call(AccountEntity account) {
    return _repository.updateAccount(account);
  }
}
