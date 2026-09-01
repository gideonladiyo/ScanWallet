import '../../../../core/utils/result.dart';
import '../repositories/account_repository.dart';

class DeleteAccountUsecase {
  const DeleteAccountUsecase(this._repository);

  final AccountRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteAccount(id);
  }
}
