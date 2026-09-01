import '../../../../core/utils/result.dart';
import '../entities/account_entity.dart';
import '../repositories/account_repository.dart';

class CreateAccountUsecase {
  const CreateAccountUsecase(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountEntity>> call(
    String name,
    AccountType accountType, {
    String? color,
  }) {
    return _repository.createAccount(name, accountType, color: color);
  }
}
