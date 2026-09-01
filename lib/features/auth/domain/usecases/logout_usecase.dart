import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class LogoutUsecase {
  const LogoutUsecase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() {
    return _repository.logout();
  }
}
